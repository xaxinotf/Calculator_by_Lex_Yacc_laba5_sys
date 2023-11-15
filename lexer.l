%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"  // Include the Bison-generated header.
extern char *strdup(const char *);;

int yycolumn = 1;
%}

%option noyywrap
%option yylineno

DIGIT       [0-9]
LETTER      [a-zA-Z_]
NUMBER      {DIGIT}+   /* Matches an integer number */
IDENTIFIER  {LETTER}({LETTER}|{DIGIT})*  /* Matches an identifier */

%%

({DIGIT})+ {
    yylval.intValue = atoi(yytext); // Convert string to integer
    return INTEGER;                 // Return the INTEGER token
}

({LETTER})({LETTER}|{DIGIT})* {
    yylval.stringValue = strdup(yytext); // Duplicate the string
    return IDENTIFIER;                   // Return the IDENTIFIER token
}

"+"     { return PLUS; }
"-"     { return MINUS; }
"*"     { return TIMES; }
"/"     { return DIVIDE; }
"="     { return ASSIGN; }
"("     { return LPAREN; }
")"     { return RPAREN; }
";"     { return SEMICOLON; }

[ \t]   { /* Skip whitespaces */ }
\n      { /* Increment line number and reset column */ yycolumn = 1; ++yylineno; }
.       { /* Catch all for any other character not matched */
            /* Print an error message or handle the unexpected character */
            fprintf(stderr, "Line %d, Column %d: Error: Unexpected character '%s'\n", yylineno, yycolumn, yytext);
            ++yycolumn;
        }

%%

// This section can contain additional C functions used by the lexer.
/*
int main(int argc, char **argv) {
    // This main function is only for testing the lexer independently.
    // When using the lexer with Bison, you won't compile with this main function.
    while (yylex());
    return 0;
}
*/

