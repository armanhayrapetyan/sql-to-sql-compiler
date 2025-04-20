%{
#include "teradata2mysql.tab.h"
#include <string.h>
%}

%option noyywrap

DIGIT       [0-9]
LETTER      [a-zA-Z_]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT})*

%%

"PROCEDURE"     { return PROCEDURE; }
"FUNCTION"      { return FUNCTION; }
"BEGIN"         { return BEGIN; }
"END"           { return END; }
"DECLARE"       { return DECLARE; }
"RETURNS"       { return RETURNS; }
"RETURN"        { return RETURN; }
"IF"            { return IF; }
"THEN"          { return THEN; }
"ELSE"          { return ELSE; }
"END IF"        { return ENDIF; }
"WHILE"         { return WHILE; }
"FOR"           { return FOR; }
"LOOP"          { return LOOP; }
"CREATE"        { return CREATE; }
"REPLACE"       { return REPLACE; }
"SET"           { return SET; }
"AS"            { return AS; }

{IDENTIFIER}    { yylval.str = strdup(yytext); return IDENTIFIER; }
[0-9]+          { yylval.num = atoi(yytext); return NUMBER; }
[ \t\n]         ; /* ignore whitespace */
";"             { return SEMICOLON; }
":"             { return COLON; }
"="             { return EQUALS; }
"("             { return LPAREN; }
")"             { return RPAREN; }
","             { return COMMA; }

.               { printf("Unknown token: %s\n", yytext); }

%%