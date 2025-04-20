%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../parser/select_form.tab.h"

void yyerror(const char *s);
%}

%option noyywrap
%option yylineno

DIGIT    [0-9]
LETTER   [a-zA-Z]
ID       ({LETTER}|_)({LETTER}|{DIGIT}|_)*
STRING   \'([^\'\\]|\\.)*\'
NUMBER   {DIGIT}+(\.{DIGIT}+)?([eE][-+]?{DIGIT}+)?

%%

"SELECT"        { return SELECT; }
"FROM"          { return FROM; }
"WHERE"         { return WHERE; }
"GROUP"         { return GROUP; }
"BY"            { return BY; }
"ORDER"         { return ORDER; }
"LIMIT"         { return LIMIT; }
"JOIN"          { return JOIN; }
"LEFT"          { return LEFT; }
"RIGHT"         { return RIGHT; }
"INNER"         { return INNER; }
"OUTER"         { return OUTER; }
"LEFT JOIN"    { return LEFTJOIN; }
"RIGHT JOIN"   { return RIGHTJOIN; }
"INNER JOIN"   { return INNERJOIN; }
"OUTER JOIN"   { return OUTERJOIN; }
"ON"            { return ON; }
"AS"            { return AS; }
"AND"           { return AND; }
"OR"            { return OR; }
"NOT"           { return NOT; }
"NULL"          { return NULLVAL; }
"IS"            { return IS; }
"IN"            { return IN; }
"BETWEEN"       { return BETWEEN; }
"LIKE"          { return LIKE; }
"TRUE"          { return TRUEVAL; }
"FALSE"         { return FALSEVAL; }
"DATE"          { return DATE; }
"TIME"          { return TIME; }
"TIMESTAMP"     { return TIMESTAMP; }
"INTERVAL"      { return INTERVAL; }
"EXTRACT"       { return EXTRACT; }
"YEAR"          { return YEAR; }
"MONTH"         { return MONTH; }
"DAY"           { return DAY; }
"HOUR"          { return HOUR; }
"MINUTE"        { return MINUTE; }
"SECOND"        { return SECOND; }
"DATE_TRUNC"    { return DATE_TRUNC; }
"DATE_ADD"      { return DATE_ADD; }
"DATE_SUB"      { return DATE_SUB; }
"DATEDIFF"      { return DATEDIFF; }
"NOW"           { return NOW; }
"CURRENT_DATE"  { return CURRENT_DATE; }
"CURRENT_TIME"  { return CURRENT_TIME; }
"CURRENT_TIMESTAMP" { return CURRENT_TIMESTAMP; }
"QUALIFY"       { return QUALIFY; }
"OVER"          { return OVER; }
"PARTITION"     { return PARTITION; }
"ROW_NUMBER"    { return ROW_NUMBER; }
"RANK"          { return RANK; }
"DENSE_RANK"    { return DENSE_RANK; }

"=="            { return EQ; }
"!="            { return NE; }
"<>"            { return NE; }
"<="            { return LE; }
">="            { return GE; }

[+\-*/%=<>(),.;] { return yytext[0]; }  /* Single-character operators */

{ID}            { yylval.str = strdup(yytext); return IDENTIFIER; }
{STRING}        { yylval.str = strdup(yytext); return STRING_LITERAL; }
{NUMBER}        { yylval.str = strdup(yytext); return NUMBER_LITERAL; }

[ \t\n]         ; /* ignore whitespace */
"--".*          ; /* ignore single line comments */
"/*"([^*]|"*"+[^*/])*"*"+"/" ; /* ignore multi-line comments */

.               { 
                  char err[100];
                  snprintf(err, 100, "Invalid character '%s'", yytext);
                  yyerror(err); 
                }

%%