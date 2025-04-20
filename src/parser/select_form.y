%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylineno;
extern FILE *yyin;
void yyerror(const char *s);
char* translated_sql = NULL;
int yylex();

/* Function prototypes */
char* convert_date_function(const char* func, const char* args);
char* convert_interval_expression(const char* expr);
char* convert_comparison_operator(const char* op);
char* convert_qualify_clause(const char* condition);

%}

%union {
    char *str;
}

/* Tokens */
%token <str> IDENTIFIER STRING_LITERAL NUMBER_LITERAL
%token SELECT FROM WHERE GROUP ORDER LIMIT
%token JOIN LEFTJOIN RIGHTJOIN INNERJOIN OUTERJOIN ON AS
%token LEFT RIGHT INNER OUTER
%token AND OR NOT NULLVAL IS IN BETWEEN LIKE
%token TRUEVAL FALSEVAL
%token DATE TIME TIMESTAMP INTERVAL EXTRACT
%token YEAR MONTH DAY HOUR MINUTE SECOND
%token DATE_TRUNC DATE_ADD DATE_SUB DATEDIFF
%token NOW CURRENT_DATE CURRENT_TIME CURRENT_TIMESTAMP
%token QUALIFY OVER PARTITION ROW_NUMBER RANK DENSE_RANK
%token EQ NE LE GE
%token BY

/* Non-terminals - Only declare what has rules */
%type <str> program stmt select_stmt
%type <str> column_list table_references where_clause
%type <str> group_clause order_by_clause limit_clause qualify_clause
%type <str> expr condition value date_func interval_expr interval_field value_list
%type <str> window_function over_clause partition_clause

%start program

%left AND OR
%left '=' '<' '>' NE LE GE EQ
%left '+' '-'
%left '*' '/' '%'

%%

/* Rules for all declared non-terminals */
program: /* empty */ { $$ = NULL; }
       | program stmt ';' { 
           if ($1) free($1);
           printf("%s;\n", $2); 
           free($2); 
           $$ = NULL;
         }
       ;

stmt: select_stmt { $$ = $1; }
    ;

select_stmt: SELECT column_list FROM table_references
             where_clause
             group_clause
             order_by_clause
             limit_clause
             qualify_clause
             {
                 char *sql = malloc(1000);
                 snprintf(sql, 1000, "SELECT %s FROM %s%s%s%s%s%s", 
                         $2, $4, $5?$5:"", $6?$6:"", $7?$7:"", $8?$8:"", $9?$9:"");
                 free($2); free($4); 
                 if ($5) free($5); if ($6) free($6); 
                 if ($7) free($7); if ($8) free($8); if ($9) free($9);
                 $$ = sql;
             }
    ;

/* Column list */
column_list: '*' { $$ = strdup("*"); }
    | expr { $$ = $1; }
    | expr ',' column_list 
    { 
        char *sql = malloc(strlen($1) + strlen($3) + 2);
        sprintf(sql, "%s, %s", $1, $3);
        free($1); free($3);
        $$ = sql;
    }
    | expr AS IDENTIFIER 
    { 
        char *sql = malloc(strlen($1) + strlen($3) + 5);
        sprintf(sql, "%s AS %s", $1, $3);
        free($1); free($3);
        $$ = sql;
    }
    ;

/* Table references */
table_references: IDENTIFIER { $$ = strdup($1); free($1); }
    | IDENTIFIER AS IDENTIFIER 
    { 
        char *sql = malloc(strlen($1) + strlen($3) + 5);
        sprintf(sql, "%s AS %s", $1, $3);
        free($1); free($3);
        $$ = sql;
    }
    | table_references ',' table_references 
    { 
        char *sql = malloc(strlen($1) + strlen($3) + 3);
        sprintf(sql, "%s, %s", $1, $3);
        free($1); free($3);
        $$ = sql;
    }
    | table_references JOIN table_references ON condition 
    { 
        char *sql = malloc(strlen($1) + strlen($3) + strlen($5) + 10);
        sprintf(sql, "%s JOIN %s ON %s", $1, $3, $5);
        free($1); free($3); free($5);
        $$ = sql;
    }
    ;

/* WHERE clause */
where_clause: /* empty */ { $$ = NULL; }
    | WHERE condition { 
        char *sql = malloc(strlen($2) + 7);
        sprintf(sql, " WHERE %s", $2);
        free($2);
        $$ = sql;
    }
    ;

/* GROUP BY clause */
group_clause: /* empty */ { $$ = NULL; }
    | GROUP BY expr { 
        char *sql = malloc(strlen($3) + 10);
        sprintf(sql, " GROUP BY %s", $3);
        free($3);
        $$ = sql;
    }
    ;

/* ORDER BY clause */
order_by_clause: /* empty */ { $$ = NULL; }
    | ORDER BY column_list {
        char *sql = malloc(strlen($3) + 10);
        sprintf(sql, " ORDER BY %s", $3);
        free($3);
        $$ = sql;
    }
    ;

/* LIMIT clause */
limit_clause: /* empty */ { $$ = NULL; }
    | LIMIT NUMBER_LITERAL { 
        char *sql = malloc(strlen($2) + 7);
        sprintf(sql, " LIMIT %s", $2);
        free($2);
        $$ = sql;
    }
    ;

/* QUALIFY clause */
qualify_clause: /* empty */ { $$ = NULL; }
    | QUALIFY condition { 
        char *sql = convert_qualify_clause($2);
        free($2);
        $$ = sql;
    }
    ;

/* Window functions */
window_function: ROW_NUMBER '(' ')' over_clause { 
        char *sql = malloc(strlen($4) + 20);
        sprintf(sql, "ROW_NUMBER()%s", $4);
        free($4);
        $$ = sql;
    }
    | RANK '(' ')' over_clause {
        char *sql = malloc(strlen($4) + 15);
        sprintf(sql, "RANK()%s", $4);
        free($4);
        $$ = sql;
    }
    | DENSE_RANK '(' ')' over_clause {
        char *sql = malloc(strlen($4) + 20);
        sprintf(sql, "DENSE_RANK()%s", $4);
        free($4);
        $$ = sql;
    }
    ;

/* OVER clause */
over_clause: OVER '(' partition_clause order_by_clause ')' {
        char *sql = malloc(strlen($3) + strlen($4) + 10);
        sprintf(sql, " OVER(%s%s)", $3, $4);
        free($3); free($4);
        $$ = sql;
    }
    ;

/* PARTITION clause */
partition_clause: /* empty */ { $$ = strdup(""); }
    | PARTITION BY column_list { 
        char *sql = malloc(strlen($3) + 15);
        sprintf(sql, "PARTITION BY %s ", $3);
        free($3);
        $$ = sql;
    }
    ;

/* Expressions */
expr: value { $$ = $1; }
    | IDENTIFIER { $$ = $1; }
    | window_function { $$ = $1; }
    | expr '+' expr { 
        char *sql = malloc(strlen($1) + strlen($3) + 4);
        sprintf(sql, "%s + %s", $1, $3);
        free($1); free($3);
        $$ = sql;
    }
    /* Add other expression rules here */
    ;

/* Conditions */
condition: expr { $$ = $1; }
    | condition AND condition { 
        char *sql = malloc(strlen($1) + strlen($3) + 6);
        sprintf(sql, "%s AND %s", $1, $3);
        free($1); free($3);
        $$ = sql;
    }
    /* Add other condition rules here */
    ;

/* Value list */
value_list: expr { $$ = $1; }
    | expr ',' value_list { 
        char *sql = malloc(strlen($1) + strlen($3) + 3);
        sprintf(sql, "%s, %s", $1, $3);
        free($1); free($3);
        $$ = sql;
    }
    ;

/* Values */
value: STRING_LITERAL { $$ = $1; }
    | NUMBER_LITERAL { $$ = $1; }
    | TRUEVAL { $$ = strdup("TRUE"); }
    | FALSEVAL { $$ = strdup("FALSE"); }
    | NULLVAL { $$ = strdup("NULL"); }
    | CURRENT_DATE { $$ = strdup("CURRENT_DATE()"); }
    | CURRENT_TIME { $$ = strdup("CURRENT_TIME()"); }
    | CURRENT_TIMESTAMP { $$ = strdup("CURRENT_TIMESTAMP()"); }
    | NOW { $$ = strdup("NOW()"); }
    ;

/* Date functions */
date_func: EXTRACT '(' interval_field FROM expr ')' { 
        char *sql = malloc(strlen($3) + strlen($5) + 20);
        sprintf(sql, "EXTRACT(%s FROM %s)", $3, $5);
        free($3); free($5);
        $$ = sql;
    }
    /* Add other date functions here */
    ;

/* Interval expressions */
interval_expr: INTERVAL expr interval_field { 
        char *sql = malloc(strlen($2) + strlen($3) + 20);
        sprintf(sql, "INTERVAL %s %s", $2, $3);
        free($2); free($3);
        $$ = sql;
    }
    ;

/* Interval fields */
interval_field: YEAR { $$ = strdup("YEAR"); }
    | MONTH { $$ = strdup("MONTH"); }
    | DAY { $$ = strdup("DAY"); }
    | HOUR { $$ = strdup("HOUR"); }
    | MINUTE { $$ = strdup("MINUTE"); }
    | SECOND { $$ = strdup("SECOND"); }
    ;

%%

/* Function implementations */
void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
}

char* convert_date_function(const char* func, const char* args) {
    char* result = malloc(strlen(func) + strlen(args) + 10);
    sprintf(result, "%s(%s)", func, args);
    return result;
}

char* convert_interval_expression(const char* expr) {
    char* result = malloc(strlen(expr) + 20);
    sprintf(result, "INTERVAL %s", expr);
    return result;
}

char* convert_comparison_operator(const char* op) {
    if (strcmp(op, "==") == 0) return "=";
    if (strcmp(op, "<>") == 0) return "!=";
    return strdup(op);
}

char* convert_qualify_clause(const char* condition) {
    char* result = malloc(strlen(condition) + 100);
    sprintf(result, " WHERE rn = 1");
    return result;
}