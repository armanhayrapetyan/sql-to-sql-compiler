%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "trigger_conv.h"
#include "index_conv.h"

extern FILE *yyin;
extern int yylex();
extern int yyparse();
void yyerror(const char *s);

%}

%union {
    int num;
    char *str;
}

%token <num> NUMBER
%token <str> IDENTIFIER QUOTED_STRING
%token CREATE REPLACE TRIGGER INDEX ON FOR EACH ROW
%token BEFORE AFTER INSERT UPDATE DELETE ACTIVATE WHEN
%token BEGIN END UNIQUE PRIMARY REFERENCES USING HASH BTREE
%token SEMICOLON LPAREN RPAREN COMMA DOT

%%

program:
    | program statement SEMICOLON
    ;

statement:
    create_trigger
    | create_index
    ;

create_trigger:
    CREATE TRIGGER trigger_name ON table_name trigger_time trigger_event 
    [ ACTIVATE WHEN '(' condition ')' ] trigger_body
    {
        convert_trigger($3, $5, $6, $7, $9, $11);
    }
    ;

trigger_name: IDENTIFIER | QUOTED_STRING;
table_name: IDENTIFIER | IDENTIFIER DOT IDENTIFIER;

trigger_time: BEFORE | AFTER;
trigger_event: INSERT | UPDATE | DELETE;

trigger_body: BEGIN statement_list END | single_statement;

create_index:
    CREATE [UNIQUE] INDEX index_name ON table_name 
    '(' column_list ')' [index_type]
    {
        convert_index($3, $5, $7, $9, $11);
    }
    ;

index_name: IDENTIFIER | QUOTED_STRING;
column_list: column_name | column_list COMMA column_name;
column_name: IDENTIFIER | QUOTED_STRING;
index_type: USING (HASH | BTREE);

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}