#ifndef INDEX_CONV_H
#define INDEX_CONV_H

typedef struct {
    char *index_name;
    char *table_name;
    char **columns;
    int column_count;
    int is_unique;
    char *index_type;
} IndexDefinition;

void convert_index(char *name, char *table, char **columns, int column_count, 
                  int is_unique, char *type);
void free_index_definition(IndexDefinition *def);

#endif