%{
#include "y.tab.h"

%}

%%
\%\%.*	{printf("%s\n",yytext);}
[ \t\n\r]+
[Pp][Rr][Oo][Gg][Rr][Aa][Mm]	{ return PROGRAM; }
[Bb][Ee][Gg][Ii][Nn]	{ return Begin; }
[Dd][Ee][Cc][Ll][Aa][Rr][Ee]	{ return DECLARE; }
[Aa][Ss]	{ return AS; }
[Ee][Nn][Dd]	{ return END; }
[Ii][Nn][Tt][Ee][Gg][Ee][Rr]	{ yylval.vint=1; return TYPE; }
[Ff][Ll][Oo][Aa][Tt]	{ yylval.vint=1; return TYPE; }\
[a-zA-Z][a-zA-Z0-9\_]*(\[[1-9][0-9]*\])*	{ printf("%s\n",yytext);yylval.str=yytext; return Vname; }
.	{ return yytext[0]; }
%%