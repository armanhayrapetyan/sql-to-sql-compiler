#include "index_conv.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void convert_index(char *name, char *table, char **columns, int column_count, 
                 int is_unique, char *type) {
    printf("-- Converted from Teradata to MySQL index\n");
    
    if (is_unique) {
        printf("CREATE UNIQUE INDEX %s\n", name);
    } else {
        printf("CREATE INDEX %s\n", name);
    }
    
    printf("ON %s (", table);
    
    for (int i = 0; i < column_count; i++) {
        if (i > 0) printf(", ");
        printf("%s", columns[i]);
    }
    
    printf(")");
    
    // Handle index type (MySQL uses BTREE by default)
    if (type != NULL && strcmp(type, "HASH") == 0) {
        printf(" USING HASH");
    }
    
    printf(";\n\n");
}

void free_index_definition(IndexDefinition *def) {
    if (def == NULL) return;
    free(def->index_name);
    free(def->table_name);
    for (int i = 0; i < def->column_count; i++) {
        free(def->columns[i]);
    }
    free(def->columns);
    free(def->index_type);
    free(def);
}