%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "symt.h"
int yylex();
void yyerror(const char *s);

struct symtab *varList[50]={};
char labelList[10][11]={};
char paramList[10][11]={};
int varCount=0;
int tempCount=1;
int paramCount=0;
int labelCount=0;
int labelNum=0;
char varType[10][11]={"Integer", "Float"};
char opType[4][5]={"ADD", "SUB", "MUL", "DIV"};
FILE* file=NULL;

void ProgramStart(char programName[]);
void VarToTable(struct symtab *var);
void DeclareVariable(int type);
void StoreVar(struct symtab *var, struct symtab *expr);
struct symtab *CreateTemp();
struct symtab *Operation(struct symtab *left, int op, struct symtab *right);
struct symtab *Variable(struct symtab *var);
struct symtab *Integer(char num[]);
struct symtab *Float(char num[]);
struct symtab *Uminus(struct symtab *num);
void CreateLabel();
void PrintLabel(int num);
void LabelEnd();
void ForJump(struct symtab *var, char *dt, struct symtab *expr, struct symtab *step);
void WhileJump(char jump[]);
void WhileEndJump();
void ParamToTable(char parm[]);
void Condition(struct symtab *left, char comp[], struct symtab *right);
void IfJump(char jump[]);
void ElseJump();
void CallPrint();
void ProgramEnd(char programName[]);
void DeclTemp();
%}
%union {
	int vint;
	char* str;
	struct symtab *symp;
}
%token PROGRAM Begin DECLARE AS END ASSIGN PRINT
%token FOREND FOR TO DOWNTO WHILE WHILEEND STEP
%token IF THEN ELSE IFEND
%token GT LW GE LE EQ NE
%token <vint> TYPE
%token <str>  FLOAT INT
%token <symp> NAME
%type <symp> Expr AssignExpr ForStep
%type <str> Dt Param Comp Cond

%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%%
Start: PROGRAM NAME{ ProgramStart($2->name); } Begin StmtList END{ ProgramEnd($2->name); DeclTemp(); } ;

StmtList: StmtList Stmt
        | ;

Stmt: AssignStmt
    | DeclStmt
		| ForStmt
		| WhileStmt;
		| IfStmt
		| PrintStmt;

AssignStmt: AssignExpr ';' ;

AssignExpr: NAME ASSIGN Expr{ $$=$1; StoreVar($1, $3); } ;

Expr: Expr '+' Expr{ $$=Operation($1, 0, $3); }
    | Expr '-' Expr{ $$=Operation($1, 1, $3); }
		| Expr '*' Expr{ $$=Operation($1, 2, $3); }
		| Expr '/' Expr{ $$=Operation($1, 3, $3); }
		| '-' Expr %prec UMINUS{ $$=Uminus($2); }
		| NAME{ $$=Variable($1); }
		| INT{ $$=Integer($1); }
		| FLOAT{ $$=Float($1); };

DeclStmt: DECLARE Vlist	AS TYPE ';'{ DeclareVariable($4); };

Vlist: NAME{ VarToTable($1); }
     | Vlist ',' NAME{ VarToTable($3); };

ForStmt: FOR '(' AssignExpr Dt Expr ForStep ')'{ CreateLabel(); PrintLabel(labelCount); } StmtList FOREND{ ForJump($3, $4, $5, $6); LabelEnd(); };

ForStep: STEP Expr{ $$=$2; }
       |{ $$=NULL; };

Dt: TO{ $$="To"; }
  | DOWNTO{ $$="DownTo"; };

WhileStmt: WHILE '('{ CreateLabel(); PrintLabel(labelCount); } Cond{ CreateLabel(); WhileJump($4); } ')' StmtList WHILEEND{ WhileEndJump(); PrintLabel(labelCount); LabelEnd(); LabelEnd(); };

IfStmt: IF '(' Cond ')'{ CreateLabel(); IfJump($3); } THEN StmtList ElseSec IFEND{ LabelEnd(); };

ElseSec: ELSE{ CreateLabel(); ElseJump(); PrintLabel(labelCount-1); } StmtList{ PrintLabel(labelCount); LabelEnd(); }
       | ;

Cond: Expr Comp Expr{ $$=$2; Condition($1, $2, $3); };

Comp: GT{ $$="JLE"; }
    | LW{ $$="JGE"; }
		| GE{ $$="JL"; }
		| LE{ $$="JG"; }
		| EQ{ $$="JNE"; }
		| NE{ $$="JE"; } ;

PrintStmt: PRINT '(' ParamList ')' ';'{ CallPrint(); } ;

ParamList: ParamList ',' Param{ ParamToTable($3); }
         | Param{ ParamToTable($1); } ;

Param: Expr{ $$=$1->name; } ;


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
	fprintf(file, "\tSTART %s\n", programName);
}

void VarToTable(struct symtab *var) {
	varList[varCount]=var;
	varCount++;
}

void DeclareVariable(int type) {
	for(int i=0;i<varCount;++i) {
		varList[i]->type=type;
		char* left=strstr(varList[i]->name, "[");
		if(left!=NULL) {
			char* right=strstr(varList[i]->name, "]");
			*left='\0';
			*right='\0';
			fprintf(file, "\tDeclare %s,%s_array,%s\n", varList[i]->name, varType[varList[i]->type], left+1);
			continue;
		}
		fprintf(file, "\tDeclare %s,%s\n", varList[i]->name, varType[varList[i]->type]);
	}
	varCount=0;
}

void StoreVar(struct symtab *var, struct symtab *expr) {
	if(var->type) fprintf(file, "\tF_STORE %s,%s\n", expr->name, var->name);
	else fprintf(file, "\tI_STORE %s,%s\n", expr->name, var->name);
}

struct symtab *CreateTemp() {
	char num[10]={};
	sprintf(num, "T&%d", tempCount);
	tempCount++;
	return symlook(num);
}

struct symtab *Operation(struct symtab *left, int op, struct symtab *right) {
	struct symtab *temp=CreateTemp();
	temp->type=left->type&right->type;
	fprintf(file, "\t%c_%s %s,%s,%s\n", varType[temp->type][0], opType[op], left->name, right->name, temp->name);
	return temp;
}

struct symtab *Uminus(struct symtab *num) {
	struct symtab *temp=CreateTemp();
	temp->type=num->type;
	fprintf(file, "\t%c_UMINUS %s,%s\n", varType[temp->type][0], num->name, temp->name);
	return temp;
}

struct symtab *Variable(struct symtab *var) {
	char temp[11]={};
	strcpy(temp, var->name);
	char* left=strstr(temp, "[");
	if(left!=NULL) *left='\0';
	var->type=symlook(temp)->type;
	return var;
}

struct symtab *Integer(char num[]) {
	struct symtab *sp=symlook(num);
	sp->type=0;
	return sp;
}

struct symtab *Float(char num[]) {
	struct symtab *sp=symlook(num);
	sp->type=1;
	return sp;
}

void CreateLabel() {
	char num[10]={};
	sprintf(labelList[labelCount++], "lb&%d", ++labelNum);
}

void PrintLabel(int num) {
	fprintf(file, "%s:", labelList[num-1]);
}

void LabelEnd() {
	--labelCount;
}

void ForJump(struct symtab *var, char *dt, struct symtab *expr, struct symtab *step) {
	if(step==NULL) fprintf(file, "\t%s %s\n", dt=="To"?"INC":"DEC", var->name);
	else {
		struct symtab *temp=CreateTemp();
		fprintf(file, "\tI_%s %s,%s,%s\n", dt=="To"?"ADD":"SUB", var->name, step->name, temp->name);
		fprintf(file, "\tI_STORE %s,%s\n", temp->name, var->name);
	}
	fprintf(file, "\tI_CMP %s,%s\n", var->name, expr->name);
	fprintf(file, "\tJL %s\n", labelList[labelCount-1]);
}

void WhileJump(char jump[]) {
	fprintf(file, "\t%s %s\n", jump, labelList[labelCount-1]);
}

void WhileEndJump() {
	fprintf(file, "\tJ %s\n", labelList[labelCount-2]);
}

void DeclTemp() {
	for(int i=1;i<tempCount;++i) {
		char num[10]={};
		sprintf(num, "T&%d", i);
		struct symtab *sp=symlook(num);
		VarToTable(sp);
		DeclareVariable(sp->type);
	}
}

void ParamToTable(char parm[]) {
	strcpy(paramList[paramCount], parm);
	paramCount++;
}

void Condition(struct symtab *left, char comp[], struct symtab *right) {
	fprintf(file, "\t%c_CMP %s,%s\n", varType[left->type&right->type][0], left->name, right->name);
}

void IfJump(char jump[]) {
	fprintf(file, "\t%s %s\n", jump, labelList[labelCount-1]);
}

void ElseJump() {
	fprintf(file, "\tJ %s\n", labelList[labelCount-1]);
}

void ProgramEnd(char programName[]) {
	fprintf(file, "\tHALT %s\n", programName);
}

void CallPrint() {
	fprintf(file, "\tCALL print");
	for(int i=0;i<paramCount;++i) {
		fprintf(file, ",%s", paramList[i]);
	}
	fprintf(file, "\n");
	paramCount=0;
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
