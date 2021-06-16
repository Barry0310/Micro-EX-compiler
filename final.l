%{
#include "y.tab.h"
#include "symt.h"
%}

%%
\%\%.*
[ \t\n\r]+
":="	{ return ASSIGN; }
'>'	{ return GT; }
'<'	{ return LW; }
">="	{ return GE; }
"<="	{ return LE; }
"=="	{ return EQ; }
"!="	{ return NE; }
[Pp][Rr][Oo][Gg][Rr][Aa][Mm]	{ return PROGRAM; }
[Bb][Ee][Gg][Ii][Nn]	{ return Begin; }
[Dd][Ee][Cc][Ll][Aa][Rr][Ee]	{ return DECLARE; }
[Aa][Ss]	{ return AS; }
[Ee][Nn][Dd]	{ return END; }
[Ii][Nn][Tt][Ee][Gg][Ee][Rr]	{ yylval.vint=0; return TYPE; }
[Ff][Ll][Oo][Aa][Tt]	{ yylval.vint=1; return TYPE; }
[Ee][Nn][Dd][Ff][Oo][Rr]	{ return FOREND; }
[Ff][Oo][Rr]	{ return FOR; }
[Tt][Oo]	{ return TO; }
[Dd][Oo][Ww][Nn][Tt][Oo]	{ return DOWNTO; }
[Ss][Tt][Ee][Pp] { return STEP; }
[Ii][Ff]	{ return IF; }
[Tt][Hh][Ee][Nn]	{ return THEN; }
[Ee][Nn][Dd][Ii][Ff]	{ return IFEND; }
[Ee][Ll][Ss][Ee]	{ return ELSE; }
[Pp][Rr][Ii][Nn][Tt] { return PRINT; }
[Ww][Hh][Ii][Ll][Ee] { return WHILE; }
[Ee][Nn][Dd][Ww][Hh][Ii][Ll][Ee] { return WHILEEND; }
[0-9]+	{ yylval.str = yytext; return INT; }
([0-9]*\.[0-9]+)|([0-9]+\.[0-9]*)	{ yylval.str = yytext; return FLOAT; }
[a-zA-Z][a-zA-Z0-9\_]*(\[[1-9][0-9]*\])*	{
		struct symtab *sp=symlook(yytext);
		yylval.symp=sp;
		return NAME; }
[a-zA-Z][a-zA-Z0-9\_]*(\[[a-zA-Z][a-zA-Z0-9\_]*\])*	{
		struct symtab *sp=symlook(yytext);
		yylval.symp=sp;
		return NAME; }
.	{ return yytext[0]; }
%%
