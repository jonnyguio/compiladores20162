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

COMMENT "(*"([^*]|"*"[^)])*"*)"

%%

{LINHA}    { nlinha++; }
{DELIM}    {}
{COMMENT}  {}

"Var"      { yylval = Atributos( yytext ); return TK_VAR; }
"Program"  { yylval = Atributos( yytext ); return TK_PROGRAM; }
"Begin"    { yylval = Atributos( yytext ); return TK_BEGIN; }
"End"      { yylval = Atributos( yytext ); return TK_END; }
"WriteLn"  { yylval = Atributos( yytext ); return TK_WRITELN; }
"Read"     { yylval = Atributos( yytext ); return TK_READ; }
"If"       { yylval = Atributos( yytext ); return TK_IF; }
"Then"     { yylval = Atributos( yytext ); return TK_THEN; }
"Else"     { yylval = Atributos( yytext ); return TK_ELSE; }
"For"      { yylval = Atributos( yytext ); return TK_FOR; }
"To"       { yylval = Atributos( yytext ); return TK_TO; }
"Do"       { yylval = Atributos( yytext ); return TK_DO; }
"Array"    { yylval = Atributos( yytext ); return TK_ARRAY; }
"Of"       { yylval = Atributos( yytext ); return TK_OF; }
"Function" { yylval = Atributos( yytext ); return TK_FUNCTION; }
"Mod"      { yylval = Atributos( yytext ); return TK_MOD; }
"While"    { yylval = Atributos( yytext ); return TK_WHILE; }
"Switch"   { yylval = Atributos( yytext ); return TK_SWITCH; }
"Case"     { yylval = Atributos( yytext ); return TK_CASE; }
"Default"  { yylval = Atributos( yytext ); return TK_DEFAULT; }

".."       { yylval = Atributos( yytext ); return TK_PTPT; }
":="       { yylval = Atributos( yytext ); return TK_ATRIB; }
"<="       { yylval = Atributos( yytext ); return TK_MEIG; }
">="       { yylval = Atributos( yytext ); return TK_MAIG; }
"<"       { yylval = Atributos( yytext ); return TK_MENO; }
">"       { yylval = Atributos( yytext ); return TK_MAIO; }
"<>"       { yylval = Atributos( yytext ); return TK_DIF; }
"="       { yylval = Atributos( yytext ); return TK_EQUAL; }
"And"       { yylval = Atributos( yytext ); return TK_AND; }
"Or"       { yylval = Atributos( yytext ); return TK_OR; }
"Not"       { yylval = Atributos( yytext ); return TK_NOT; }


{CSTRING}  { yylval = Atributos( troca_aspas( yytext ), Tipo( "string" ) );
             return TK_CSTRING; }
{ID}       { yylval = Atributos( yytext ); return TK_ID; }
{INT}      { yylval = Atributos( yytext, Tipo( "int" ) ); return TK_CINT; }
{DOUBLE}   { yylval = Atributos( yytext, Tipo( "double" ) ); return TK_CDOUBLE; }

.          { yylval = Atributos( yytext ); return *yytext; }

%%

char* troca_aspas( char* lexema ) {
  int n = strlen( lexema );
  lexema[0] = '"';
  lexema[n-1] = '"';

  return lexema;
}
