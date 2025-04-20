CC = gcc
CFLAGS = -g

# Flex and Bison files paths
FLEX_LEXER_PATH = ./lexer
BISON_PARSER_PATH = ./parser

all: sql_parser

sql_parser: flex bison
	$(CC) $(CFLAGS) ${FLEX_LEXER_PATH}/lex.yy.c ${BISON_PARSER_PATH}/select_form.tab.c main.c -o sql_parser

flex:
	cd lexer && flex select_form.l

bison:
	cd parser && bison -d select_form.y

clean:
	rm -f sql_parser ./parser/select_form.tab.c ./parser/select_form.tab.h ./lexer/lex.yy.c a.out sql_parser
