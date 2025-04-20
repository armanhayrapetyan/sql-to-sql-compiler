#include <stdio.h>
#include <stdlib.h>
#include "./parser/select_form.tab.h"

extern int yyparse();
extern FILE *yyin;

// Add this external declaration for the translated SQL output
extern char* translated_sql;

int read_file(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        perror("Error opening file");
        return 1;
    }

    yyin = file;
    yyparse();
    
    fclose(file);
    return 0;
}

int main(int argc, char **argv) {
    printf("SQL to SQL Translator\n");

    if (argc >= 2) {
        // Read from file
        int result = read_file(argv[1]);
        if (translated_sql) {
            printf("Translated SQL:\n%s\n", translated_sql);
            free(translated_sql);  // Don't forget to free the memory
        }
        return result;
    } else {
        // Read from standard input
        printf("Enter SQL statements (end with ;) or Ctrl-D to exit\n");
        yyparse();
        if (translated_sql) {
            printf("Translated SQL:\n%s\n", translated_sql);
            free(translated_sql);
        }
    }

    return 0;
}