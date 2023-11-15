%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h" // Make sure this file exists and has the necessary token definitions.

extern int yylex();
extern int yyparse();
extern FILE *yyin;

void yyerror(const char *s) {
  fprintf(stderr, "Error: %s\n", s);
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
    printf("Assignment to %s\n", $1);
    free($1); // Assuming variable is dynamically allocated in the lexer
  }
;

variable:
  IDENTIFIER
;

expression:
  INTEGER {
    $$ = $1;
  }
| variable {
    // Lookup the variable value here, for now just print
    printf("Variable reference: %s\n", $1);
    free($1);
  }
| expression PLUS expression {
    $$ = $1 + $3;
  }
| expression MINUS expression {
    $$ = $1 - $3;
  }
| expression TIMES expression {
    $$ = $1 * $3;
  }
| expression DIVIDE expression {
    if ($3 == 0) {
        yyerror("Division by zero");
        $$ = 0;
    } else {
        $$ = $1 / $3;
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

