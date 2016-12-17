%{
#include <string>
#include <iostream>
#include <vector>
#include <stdio.h>
#include <stdlib.h>
#include <map>

using namespace std;

int yylex();
void yyerror( const char* st );

// Faz o mapeamento dos tipos dos operadores
map< string, string > tipo_opr;

// Pilha de variáveis temporárias para cada bloco
vector< string > var_temp;

struct Atributos {
  string v, t, c; // Valor, tipo e código gerado.
  vector<string> lista; // Uma lista auxiliar.
  
  Atributos() {} // Constutor vazio
  Atributos( string valor ) {
    v = valor;
  }

  Atributos( string valor, string tipo ) {
    v = valor;
    t = tipo;
  }
};

// Declarar todas as funções que serão usadas.
string consulta_ts( string nome_var );
string gera_nome_var_temp( string tipo );
string gera_label( string tipo );
void debug( string producao, Atributos atr );

Atributos gera_codigo_operador( Atributos s1, string opr, Atributos s3 );
Atributos gera_codigo_if( Atributos expr, string cmd_then, string cmd_else );

string traduz_nome_tipo_pascal( string tipo_pascal );
string traduz_nome_tipo_interno( string tipo_interno );

string includes = 
"#include <iostream>\n"
"#include <stdio.h>\n"
"#include <stdlib.h>\n"
"\n"
"using namespace std;\n";


#define YYSTYPE Atributos

%}

%token TK_ID TK_CINT TK_CDOUBLE TK_VAR TK_PROGRAM TK_BEGIN TK_END TK_ATRIB
%token TK_WRITELN TK_CSTRING
%token TK_MAIG TK_MEIG TK_DIF TK_IF TK_THEN TK_ELSE TK_AND

%left TK_AND
%nonassoc '<' '>' TK_MAIG TK_MEIG '=' TK_DIF 
%left '+' '-'
%left '*' '/'

%%

S : PROGRAM DECLS MAIN 
    {
      cout << includes << endl;
      cout << $2.c << endl;
      cout << $3.c << endl;
    }
  ;
  
PROGRAM : TK_PROGRAM TK_ID ';' 
          { $$.c = ""; }
        ; 

DECLS : DECL DECLS
        { $$.c = $1.c + $2.c; }
      | 
        { $$.c = ""; }
      ;  

DECL : TK_VAR VARS
       { $$.c = $2.c; }
     ;
     
VARS : VAR ';' VARS
       { $$.c = $1.c + $3.c; }
     | 
       { $$.c = ""; }
     ;     
     
VAR : IDS ':' TK_ID 
      {
        string tipo = traduz_nome_tipo_pascal( $3.v ); 
        $$ = Atributos();
        
        for( int i = 0; i < $1.lista.size(); i ++ )
          $$.c += tipo + " " + $1.lista[i] + ";\n";
      }
    ;
    
IDS : IDS ',' TK_ID 
      { $$  = $1;
        $$.lista.push_back( $3.v ); }
    | TK_ID 
      { $$ = Atributos();
        $$.lista.push_back( $1.v ); }
    ;          

MAIN : BLOCO '.'
       { $$.c = "int main()\n" + $1.c; } 
     ;
     
BLOCO : TK_BEGIN { var_temp.push_back( "" );} CMDS TK_END
        { string vars = var_temp[var_temp.size()-1];
          var_temp.pop_back();
          $$.c = "{\n" + vars + $3.c + "}\n"; }
      ;  
      
CMDS : CMD ';' CMDS
       { $$.c = $1.c + $3.c; }
     |
     ;  
     
CMD : WRITELN
    | ATRIB 
    | CMD_IF
    | BLOCO
    ;     
    
CMD_IF : TK_IF E TK_THEN CMD
         { $$ = gera_codigo_if( $2, $4.c, "" ); }  
       | TK_IF E TK_THEN CMD TK_ELSE CMD 
         { $$ = gera_codigo_if( $2, $4.c, $6.c ); }  
       ;
 

WRITELN : TK_WRITELN '(' E ')' 
          { $$.c = $3.c + 
                   "  cout << " + $3.v + ";\n"
                   "  cout << endl;\n";
            $$.t = "";
            $$.v = ""; }
        ;
  
ATRIB : TK_ID TK_ATRIB E 
        { $$.c = $3.c + "  " + $1.v + " = " + $3.v + ";\n"; 
          debug( "ATRIB : TK_ID TK_ATRIB E ';'", $$ );
        } 
      ;   

E : E '+' E
    { $$ = gera_codigo_operador( $1, "+", $3 ); }
  | E '-' E
    { $$ = gera_codigo_operador( $1, "-", $3 ); }
  | E '*' E
    { $$ = gera_codigo_operador( $1, "*", $3 ); }
  | E '/' E
    { $$ = gera_codigo_operador( $1, "/", $3 ); }
  | E '<' E
    { $$ = gera_codigo_operador( $1, "<", $3 ); }
  | E '>' E
    { $$ = gera_codigo_operador( $1, ">", $3 ); }
  | E TK_MEIG E
    { $$ = gera_codigo_operador( $1, "<=", $3 ); }
  | E TK_MAIG E
    { $$ = gera_codigo_operador( $1, ">=", $3 ); }
  | E '=' E
    { $$ = gera_codigo_operador( $1, "==", $3 ); }
  | E TK_DIF E
    { $$ = gera_codigo_operador( $1, "!=", $3 ); }
  | E TK_AND E
    { $$ = gera_codigo_operador( $1, "&&", $3 ); }
  | '(' E ')'
    { $$ = $2; }
  | F
  ;
  
F : TK_ID 
    { $$.v = $1.v; $$.t = consulta_ts( $1.v ); $$.c = $1.c; };
  | TK_CINT 
    { $$.v = $1.v; $$.t = "i"; $$.c = $1.c; };
  | TK_CDOUBLE
    { $$.v = $1.v; $$.t = "d"; $$.c = $1.c; };
  | TK_CSTRING
    { $$.v = $1.v; $$.t = "s"; $$.c = $1.c; };
  ;
  
%%
int nlinha = 1;

#include "lex.yy.c"

int yyparse();

void debug( string producao, Atributos atr ) {
/*
  cerr << "Debug: " << producao << endl;
  cerr << "  t: " << atr.t << endl;
  cerr << "  v: " << atr.v << endl;
  cerr << "  c: " << atr.c << endl;
*/  
}

void yyerror( const char* st )
{
  puts( st );
  printf( "Linha: %d, [%s]\n", nlinha, yytext );
}

void erro( string msg ) {
  cerr << "Erro: " << msg << endl; 
  fprintf( stderr, "Linha: %d, [%s]\n", nlinha, yytext );
  exit(1);
}

void inicializa_operadores() {
  // Resultados para o operador "+"
  tipo_opr["i+i"] = "i";
  tipo_opr["i+d"] = "d";
  tipo_opr["d+i"] = "d";
  tipo_opr["d+d"] = "d";
  tipo_opr["s+s"] = "s";
  tipo_opr["c+s"] = "s";
  tipo_opr["s+c"] = "s";
  tipo_opr["c+c"] = "s";
 
  // Resultados para o operador "-"
  tipo_opr["i-i"] = "i";
  tipo_opr["i-d"] = "d";
  tipo_opr["d-i"] = "d";
  tipo_opr["d-d"] = "d";
  
  // Resultados para o operador "*"
  tipo_opr["i*i"] = "i";
  tipo_opr["i*d"] = "d";
  tipo_opr["d*i"] = "d";
  tipo_opr["d*d"] = "d";
  
  // Resultados para o operador "/"
  tipo_opr["i/i"] = "d";
  tipo_opr["i/d"] = "d";
  tipo_opr["d/i"] = "d";
  tipo_opr["d/d"] = "d";
  
  // Resultados para o operador "<"
  tipo_opr["i<i"] = "b";
  tipo_opr["i<d"] = "b";
  tipo_opr["d<i"] = "b";
  tipo_opr["d<d"] = "b";
  tipo_opr["c<c"] = "b";
  tipo_opr["i<c"] = "b";
  tipo_opr["c<i"] = "b";
//  tipo_opr["c<s"] = "b";
//  tipo_opr["s<c"] = "b";
//  tipo_opr["s<s"] = "b";

  // Resultados para o operador "And"
  tipo_opr["b&&b"] = "b";
}

string consulta_ts( string nome_var ) {
  // fake. Deveria ser ts[nome_var], onde ts é um map.
  // Antes de retornar, tem que verificar se a variável existe.
  return "i";
}

string toString( int n ) {
  char buff[100];
  
  sprintf( buff, "%d", ++n ); 
  
  return buff;
}

string gera_nome_var_temp( string tipo ) {
  static int n = 0;
  string nome = "t" + tipo + "_" + toString( ++n );
  
  var_temp[var_temp.size()-1] += traduz_nome_tipo_interno( tipo ) + " " + nome + ";\n";
  
  return nome;
}

string gera_label( string tipo ) {
  static int n = 0;
  string nome = "l_" + tipo + "_" + toString( ++n );
  
  return nome;
}

string tipo_resultado( string t1, string opr, string t3 ) {
  string aux = tipo_opr[ t1 + opr + t3 ];
  
  if( aux == "" ) 
    erro( "O operador " + opr + " não está definido para os tipos '" +
          t1 + "' e '" + t3 + "'.");
  
  return aux;
} 

Atributos gera_codigo_operador( Atributos s1, string opr, Atributos s3 ) {
  Atributos ss;
  
  ss.t = tipo_resultado( s1.t, opr, s3.t );
  ss.v = gera_nome_var_temp( ss.t );
  ss.c = s1.c + s3.c + // Codigo das expressões dos filhos da arvore.
          "  " + ss.v + " = " + s1.v + " " + opr + " " + s3.v + ";\n"; 
  
  debug( "E: E " + opr + " E", ss );
  return ss;
}

Atributos gera_codigo_if( Atributos expr, string cmd_then, string cmd_else ) {
  Atributos ss;
  string label_else = gera_label( "else" );
  string label_end = gera_label( "end" );
  
  ss.c = expr.c + 
         "  " + expr.v + " = !" + expr.v + ";\n\n" +
         "  if( " + expr.v + " ) goto " + label_else + ";\n" +
         cmd_then +
         "  goto " + label_end + ";\n" +
         label_else + ":;\n" +
         cmd_else +
         label_end + ":;\n";
         
  return ss;       
}


string traduz_nome_tipo_pascal( string tipo_pascal ) {
  // No caso do Pascal, a comparacao deveria ser case-insensitive
  
  if( tipo_pascal == "Integer" )
    return "int";
  else if( tipo_pascal == "Boolean" )
    return "int";
  else if( tipo_pascal == "Real" )
    return "double";  
  else if( tipo_pascal == "Char" )
    return "char";  
  else 
    erro( "Tipo inválido: " + tipo_pascal );
}

string traduz_nome_tipo_interno( string tipo_interno ) {
  if( tipo_interno == "i" )
    return "int";
  else if( tipo_interno == "b" )
    return "int";
  else if( tipo_interno == "d" )
    return "double";  
  else if( tipo_interno == "c" )
    return "char";  
  else 
    erro( "Tipo inválido: " + tipo_interno );
}


int main( int argc, char* argv[] )
{
  inicializa_operadores();
  yyparse();
}
