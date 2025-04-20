%{
#include "parser.tab.h"
#include "trigger_conv.h"
#include "index_conv.h"
#include <string.h>
#include <stdlib.h>

void remove_quotes(char* text);
%}

%option noyywrap

DIGIT       [0-9]
LETTER      [a-zA-Z_]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT})*
QUOTED_STR  '([^']*)'

%%

"CREATE"        { return CREATE; }
"REPLACE"       { return REPLACE; }
"TRIGGER"       { return TRIGGER; }
"INDEX"         { return INDEX; }
"ON"            { return ON; }
"FOR"           { return FOR; }
"EACH"          { return EACH; }
"ROW"           { return ROW; }
"BEFORE"        { return BEFORE; }
"AFTER"         { return AFTER; }
"INSERT"        { return INSERT; }
"UPDATE"        { return UPDATE; }
"DELETE"        { return DELETE; }
"ACTIVATE"      { return ACTIVATE; }
"WHEN"          { return WHEN; }
"BEGIN"         { return BEGIN; }
"END"           { return END; }
"UNIQUE"        { return UNIQUE; }
"PRIMARY"       { return PRIMARY; }
"REFERENCES"    { return REFERENCES; }
"USING"         { return USING; }
"HASH"          { return HASH; }
"BTREE"         { return BTREE; }

{IDENTIFIER}    { yylval.str = strdup(yytext); return IDENTIFIER; }
{QUOTED_STR}    { remove_quotes(yytext); yylval.str = strdup(yytext); return QUOTED_STRING; }
[0-9]+          { yylval.num = atoi(yytext); return NUMBER; }
[ \t\n]         ; /* ignore whitespace */
";"             { return SEMICOLON; }
"("             { return LPAREN; }
")"             { return RPAREN; }
","             { return COMMA; }
"."             { return DOT; }

.               { printf("Unknown token: %s\n", yytext); }

%%

void remove_quotes(char* text) {
    size_t len = strlen(text);
    if (len >= 2 && text[0] == '\'' && text[len-1] == '\'') {
        memmove(text, text+1, len-2);
        text[len-2] = '\0';
    }
}