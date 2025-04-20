#include "trigger_conv.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void convert_trigger(char *name, char *table, char *time, char *event, 
                    char *condition, char *body) {
    printf("-- Converted from Teradata to MySQL trigger\n");
    printf("DELIMITER //\n");
    printf("CREATE TRIGGER %s\n", name);
    printf("%s %s ON %s\n", time, event, table);
    printf("FOR EACH ROW\n");
    
    if (condition != NULL) {
        printf("WHEN (%s)\n", condition);
    }
    
    printf("BEGIN\n");
    
    // Convert Teradata specific syntax to MySQL
    // This is a simple example - real implementation would need more complex conversion
    char *mysql_body = strdup(body);
    // Replace Teradata specific syntax with MySQL equivalents
    // Example: Replace :NEW. with NEW.
    char *teradata_new = strstr(mysql_body, ":NEW.");
    while (teradata_new != NULL) {
        memmove(teradata_new, teradata_new + 1, strlen(teradata_new));
        teradata_new = strstr(mysql_body, ":NEW.");
    }
    
    printf("%s\n", mysql_body);
    free(mysql_body);
    
    printf("END//\n");
    printf("DELIMITER ;\n\n");
}

void free_trigger_definition(TriggerDefinition *def) {
    if (def == NULL) return;
    free(def->trigger_name);
    free(def->table_name);
    free(def->trigger_time);
    free(def->trigger_event);
    free(def->condition);
    free(def->body);
    free(def);
}