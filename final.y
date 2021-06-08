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
%token PROGRAM BEGIN DECLARE AS END
%token <str> Vname
%token <>

%%
Start: PROGRAM VName BEGIN Stmt_List ';' END {};

Stmt_List: Stmt {}
		 | Stmt_List ';' Stmt {};

Stmt: DECLARE Vlist	AS TYPE {};

Vlist: Vname {}
	 | Vlist ',' Vname {};	 
%%

int main() {
	yyparse();
	return 0;
}