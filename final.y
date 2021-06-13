%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "symt.h"
int yylex();
void yyerror(const char *s);
struct symtab *varList[20]={};
int varCount=0;
char varType[10][10]={"Integer", "Float"};
FILE* file=NULL;
void ProgramStart(char name[]);
void StoreVar(struct symtab *var);
void DeclareVariable(int type);
%}
%union {
	int vint;
	float vfloat;
	char* str;
	struct symtab *symp;
}
%token PROGRAM Begin DECLARE AS END ASSIGN
%token FOREND FOR TO DOWNTO
%token IF THEN ELSE IFEND
%token GT LW GE LE EQ NE
%token <vint> TYPE INT
%token <symp> NAME
%left '+' '-'
%left '*' '/'

%%
Start: PROGRAM NAME { ProgramStart($2->name); } Begin Stmt_List END { printf("Program Finish\n"); };

Stmt_List: Stmt_List Stmt
		 | ;

Stmt: AssignStmt
	| DeclStmt
	| ForStmt
	| IfStmt;

AssignStmt: AssignExpr ';' { printf("expr\n"); };

AssignExpr: NAME ASSIGN Expr {};

Expr: Expr '+' Expr { printf("+\n"); }
	| Expr '-' Expr { printf("-\n"); }
	| Expr '*' Expr { printf("*\n"); }
	| Expr '/' Expr { printf("/\n"); }
	| NAME { printf("%s\n", $1->name); }
	| INT { printf("%d\n", $1); };

DeclStmt: DECLARE Vlist	AS TYPE ';' { DeclareVariable($4); };

Vlist: NAME { StoreVar($1); }
	 | Vlist ',' NAME { StoreVar($3); };

ForStmt: ForHead Stmt_List FOREND {};

ForHead: FOR '(' AssignExpr Dt INT ')';
	 
Dt: TO|DOWNTO;

IfStmt: IF '(' Cond ')' THEN Stmt_List ElseSec IFEND { printf("IF\n"); };

ElseSec: ELSE Stmt_List { printf("ELSE\n"); }
	   | ;

Cond: Expr Comp Expr { printf("COMP\n"); };

Comp: GT
	| LW
	| GE
	| LE
	| EQ
	| NE;
	

%%

int main() {
	file=fopen("output.txt", "w");
	if(file==NULL) {
		printf("file error");
		return -1;
	}
	yyparse();
	fclose(file);
	return 0;
}

void ProgramStart(char programName[]) {
	fprintf(file, "START %s\n", programName);
}

void StoreVar(struct symtab *var) {
	varList[varCount]=var;
	varCount++;
}

void DeclareVariable(int type) {
	for(int i=0;i<varCount;++i) {
		varList[i]->type=type;
		struct symtab temp=*varList[i];
		char* left=strstr(temp.name, "[");
		if(left!=NULL) {
			char* right=strstr(temp.name, "]");
			*left='\0';
			*right='\0';
			fprintf(file, "Declare %s,%s_array,%s\n", temp.name, varType[temp.type], left+1);
			continue;
		}
		fprintf(file, "Declare %s,%s\n", temp.name, varType[temp.type]);
	}
	varCount=0;
}

struct symtab *
symlook(s)
char *s;
{
	char *p;
	struct symtab *sp;
	
	for(sp = symtab; sp < &symtab[NSYMS]; sp++) {
		/* is it already here? */
		if(sp->name && !strcmp(sp->name, s))
			return sp;
		
		/* is it free */
		if(!sp->name) {
			sp->name = strdup(s);
			return sp;
		}
		/* otherwise continue to next */
	}
	yyerror("Too many symbols");
	exit(1);	/* cannot continue */
} /* symlook */
