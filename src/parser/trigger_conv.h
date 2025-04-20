#ifndef TRIGGER_CONV_H
#define TRIGGER_CONV_H

typedef struct {
    char *trigger_name;
    char *table_name;
    char *trigger_time;
    char *trigger_event;
    char *condition;
    char *body;
} TriggerDefinition;

void convert_trigger(char *name, char *table, char *time, char *event, 
                    char *condition, char *body);
void free_trigger_definition(TriggerDefinition *def);

#endif