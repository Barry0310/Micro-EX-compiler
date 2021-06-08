%{
#include "y.tab.h"
extern int yylval;
%}

%%
[ \t\n]+	;
[Pp][Rr][Oo][Gg][Rr][Aa][Mm]	return PROGRAM;
[Bb][Ee][Gg][Ii][Nn]	return BEGIN;
[Dd][Ee][Cc][Ll][Aa][Rr][Ee]	return DECLARE;
[Aa][Ss]	return AS;
[Ee][Nn][Dd]	return END;
[a-zA-Z][a-zA-Z0-9\_]*	{return Vname;}

.	return yytext[0];
%%