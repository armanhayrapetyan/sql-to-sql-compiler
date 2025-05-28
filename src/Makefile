CC = gcc
CFLAGS = -g

# Flex and Bison files paths
FLEX_LEXER_PATH = ./lexer
BISON_PARSER_PATH = ./parser

# Source files
LEXERS = select_form function_form trigger_form
PARSERS = select_form function_form trigger_form

all: sql_parser

sql_parser: $(addprefix $(BISON_PARSER_PATH)/, $(addsuffix .tab.c, $(PARSERS))) \
            $(addprefix $(FLEX_LEXER_PATH)/, $(addsuffix .yy.c, $(LEXERS))) \
            main.c
	$(CC) $(CFLAGS) $^ -lfl -o $@

# Generate Bison parser files
$(BISON_PARSER_PATH)/%.tab.c $(BISON_PARSER_PATH)/%.tab.h: $(BISON_PARSER_PATH)/%.y
	bison -d -o $(@:.h=.tab.c) $<

# Generate Flex lexer files
$(FLEX_LEXER_PATH)/%.yy.c: $(FLEX_LEXER_PATH)/%.l $(BISON_PARSER_PATH)/%.tab.h
	flex -o $@ $<

clean:
	rm -f sql_parser \
		$(BISON_PARSER_PATH)/*.tab.c \
		$(BISON_PARSER_PATH)/*.tab.h \
		$(FLEX_LEXER_PATH)/*.yy.c \
		a.out
