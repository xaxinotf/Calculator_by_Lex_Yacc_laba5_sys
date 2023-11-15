%{
#include <stdio.h>
#include <stdlib.h>
#include <map>
#include <string>
#include "parser.tab.h"

extern int yylex();
extern int yyparse();
extern FILE *yyin;

std::map<std::string, int> symbolTable;

void yyerror(const char *s) {
  fprintf(stderr, "Error: %s\n", s);
}

int getValueFromSymbolTable(const char* variable) {
    std::string varStr(variable);
    if (symbolTable.find(varStr) == symbolTable.end()) {
        fprintf(stderr, "Error: Undefined variable '%s'\n", variable);
        return 0; // def to 0 if var is not found
    }
    return symbolTable[varStr];
}

void assignValueToSymbolTable(const char* variable, int value) {
    std::string varStr(variable);
    symbolTable[varStr] = value;
}

%}

%union {
    int intValue;
    char *stringValue;
}

%token <intValue> INTEGER
%token <stringValue> IDENTIFIER
%token PLUS MINUS TIMES DIVIDE ASSIGN LPAREN RPAREN SEMICOLON

%type <intValue> expression
%type <stringValue> variable

%%
/* The grammar follows here */

program:
  statement_list
;

statement_list:
  statement
| statement_list statement
;

statement:
  variable ASSIGN expression SEMICOLON {
    assignValueToSymbolTable($1, $3);
    printf("Assignment to %s\n", $1);
    free($1);
  }
;

variable:
  IDENTIFIER
;

expression:
  INTEGER {
      $$ = $1;
      printf("Integer: %d\n", $$);
    }
| variable {
    $$ = getValueFromSymbolTable($1);
    printf("Variable reference: %s with value %d\n", $1, $$);
    free($1);
  }
| expression PLUS expression {
    $$ = $1 + $3;
    printf("%d + %d = %d\n", $1, $3, $$);
  }
| expression MINUS expression {
    $$ = $1 - $3;
    printf("%d - %d = %d\n", $1, $3, $$);
  }
| expression TIMES expression {
    $$ = $1 * $3;
    printf("%d * %d = %d\n", $1, $3, $$);
  }
| expression DIVIDE expression {
    if ($3 == 0) {
        yyerror("Division by zero");
        $$ = 0;
    } else {
        $$ = $1 / $3;
        printf("%d / %d = %d\n", $1, $3, $$);
    }
  }
| LPAREN expression RPAREN {
    $$ = $2;
  }
;



%%
/* C code */
int main(int argc, char **argv) {
  if (argc > 1) {
    if (!(yyin = fopen(argv[1], "r"))) {
      perror(argv[1]);
      return 1;
    }
  }

  yyparse();
  fclose(yyin);
  return 0;
}

