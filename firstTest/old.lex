%{

char* troca_aspas( char* lexema );

%}

DELIM   [\t ]
LINHA   [\n]
NUMERO  [0-9]
LETRA   [A-Za-z_]
INT     {NUMERO}+
DOUBLE  {NUMERO}+("."{NUMERO}+)?
ID      {LETRA}({LETRA}|{NUMERO})*
CSTRING "'"([^\n']|"''")*"'"

%%

{LINHA}    { nlinha++; }
{DELIM}    {}

"Var"      	{ yylval = Atributos( yytext ); return TK_VAR; }
"Program"  	{ yylval = Atributos( yytext ); return TK_PROGRAM; }
"Hora do Barulho" 	{ yylval = Atributos( yytext ); return TK_BEGIN; }
"Hoje, na sessao da tarde" 	{ yylval = Atributos( yytext ); return TK_END; }
"Escreva"  	{ yylval = Atributos( yytext ); return TK_WRITELN; }
"Se"       	{ yylval = Atributos( yytext ); return TK_IF; }
"Entao"       { yylval = Atributos( yytext ); return TK_THEN; }
"So que nao"{ yylval = Atributos( yytext ); return TK_ELSE; }

"="       { yylval = Atributos( yytext ); return TK_ATRIB; }

"<="       { yylval = Atributos( yytext ); return TK_MEIG; }
">="       { yylval = Atributos( yytext ); return TK_MAIG; }
"!="       { yylval = Atributos( yytext ); return TK_DIF; }
"&&"       { yylval = Atributos( yytext ); return TK_AND; }


{CSTRING}  { yylval = Atributos( troca_aspas( yytext ), "string" ); 
             return TK_CSTRING; }
{ID}       { yylval = Atributos( yytext ); return TK_ID; }
{INT}      { yylval = Atributos( yytext, "int" ); return TK_CINT; }
{DOUBLE}   { yylval = Atributos( yytext, "double" ); return TK_CDOUBLE; }

.          { yylval = Atributos( yytext ); return *yytext; }

%%

char* troca_aspas( char* lexema ) {
  int n = strlen( lexema );
  lexema[0] = '"';
  lexema[n-1] = '"';
  
  return lexema;
}

 


