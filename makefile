exe = compile
name = final

all: lex.yy.c y.tab.c y.tab.h
	gcc -o $(exe) y.tab.c lex.yy.c -ly -lfl

lex.yy.c: $(exe).l
	lex $(name).l

y.tab.c y.tab.h: $(exe).y
	yacc -d $(name).y


.PHONY: clean
clean:
	rm -rf lex.yy.c y.tab.c y.tab.h
