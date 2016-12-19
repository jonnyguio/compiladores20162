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

"var"       { yylval = Atributos( yytext ); return TK_VAR; }
"programa"  { yylval = Atributos( yytext ); return TK_PROGRAM; }
"comeca"    { yylval = Atributos( yytext ); return TK_BEGIN; }
"{"         { yylval = Atributos( yytext ); return TK_BEGIN; }
"fim"   { yylval = Atributos( yytext ); return TK_END; }
"}"         { yylval = Atributos( yytext ); return TK_END; }
"escreval"  { yylval = Atributos( yytext ); return TK_WRITELN; }
"escreva"   { yylval = Atributos( yytext ); return TK_WRITE; }
"leia"      { yylval = Atributos( yytext ); return TK_READ; }
"se"        { yylval = Atributos( yytext ); return TK_IF; }
"entao"     { yylval = Atributos( yytext ); return TK_THEN; }
"senao"     { yylval = Atributos( yytext ); return TK_ELSE; }
"para"      { yylval = Atributos( yytext ); return TK_FOR; }
"ate"       { yylval = Atributos( yytext ); return TK_TO; }
"faca"      { yylval = Atributos( yytext ); return TK_DO; }
"array"     { yylval = Atributos( yytext ); return TK_ARRAY; }
"de"        { yylval = Atributos( yytext ); return TK_OF; }
"funcao"    { yylval = Atributos( yytext ); return TK_FUNCTION; }
"modulo"    { yylval = Atributos( yytext ); return TK_MOD; }
"enquanto"  { yylval = Atributos( yytext ); return TK_WHILE; }
"escolher"  { yylval = Atributos( yytext ); return TK_SWITCH; }
"caso"      { yylval = Atributos( yytext ); return TK_CASE; }
"padrao"    { yylval = Atributos( yytext ); return TK_DEFAULT; }
"ref"       { yylval = Atributos( yytext ); return TK_REF; }
"->"        { yylval = Atributos( yytext ); return TK_ARROW; }
"dentro"    { yylval = Atributos( yytext ); return TK_IN; }

".."       { yylval = Atributos( yytext ); return TK_PTPT; }
"="       { yylval = Atributos( yytext ); return TK_ATRIB; }
"<="       { yylval = Atributos( yytext ); return TK_MEIG; }
">="       { yylval = Atributos( yytext ); return TK_MAIG; }
"<"       { yylval = Atributos( yytext ); return TK_MENO; }
">"       { yylval = Atributos( yytext ); return TK_MAIO; }
"<>"       { yylval = Atributos( yytext ); return TK_DIF; }
"=="       { yylval = Atributos( yytext ); return TK_EQUAL; }
"e"       { yylval = Atributos( yytext ); return TK_AND; }
"ou"       { yylval = Atributos( yytext ); return TK_OR; }
"nao"       { yylval = Atributos( yytext ); return TK_NOT; }


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
