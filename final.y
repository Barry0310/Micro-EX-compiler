%{
#include <stdio.h>
int yylex();
void yyerror(const char *s);
char var[10][10]={};
%}
%union {
	int vint;
	float vfloat;
	char* str;
}
%token PROGRAM Begin DECLARE AS END
%token <str> Vname
%token <vint> TYPE

%%
Start: PROGRAM Vname Begin Stmt_List ';' END {printf("1\n");};

Stmt_List: Stmt {printf("2\n");}
		 | Stmt_List ';' Stmt {printf("2\n");};

Stmt: DECLARE Vlist	AS TYPE {printf("3\n");};

Vlist: Vname {printf("4\n");}
	 | Vlist ',' Vname {printf("4\n");};	 
%%

int main() {
	yyparse();
	return 0;
}