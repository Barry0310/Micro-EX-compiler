%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
int yylex();
void yyerror(const char *s);
char varList[10][10]={};
int varCount=0;
char varType[10][10]={"Integer", "Float"};
FILE* file=NULL;
void ProgramStart(char name[]);
void StoreVar(char name[]);
void DeclareVariable(int type);
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
Start: PROGRAM Vname {ProgramStart($2);} Begin Stmt_List ';' END;

Stmt_List: Stmt
		 | Stmt_List ';' Stmt;

Stmt: DECLARE Vlist	AS TYPE {DeclareVariable($4);};

Vlist: Vname {StoreVar($1);}
	 | Vlist ',' Vname {StoreVar($3);};	 
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

void StoreVar(char name[]) {
	strcpy(varList[varCount], name);
	varCount++;
}

void DeclareVariable(int type) {
	for(int i=0;i<varCount;++i) {
		char* left=strstr(varList[i], "[");
		if(left!=NULL) {
			char* right=strstr(varList[i], "]");
			*left='\0';
			*right='\0';
			fprintf(file, "Declare %s,%s_array,%s\n", varList[i], varType[type], left+1);
			continue;
		}
		fprintf(file, "Declare %s,%s\n", varList[i], varType[type]);
	}
	varCount=0;
}