# Calculator_by_Lex_Yacc_laba5_sys
--Oss trumayte comandy dlya compilatsii moei labki nomer 5 po sisprozi--



flex lexer.l

bison -d parser.y

g++ lex.yy.c parser.tab.c -o parser -lstdc++

./parser
