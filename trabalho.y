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
void erro( string msg );

// Faz o mapeamento dos tipos dos operadores
map< string, string > tipo_opr;

// Pilha de variáveis temporárias para cada bloco
vector< string > var_temp;


#define MAX_DIM 2

enum TIPO { FUNCAO = -1, BASICO = 0, VETOR = 1, MATRIZ = 2 };

struct Tipo {
  string tipo_base;
  TIPO ndim;
  int inicio[MAX_DIM];
  int fim[MAX_DIM];
  vector<Tipo> retorno; // usando vector por dois motivos:
  // 1) Para não usar ponteiros
  // 2) Para ser genérico. Algumas linguagens permitem mais de um valor
  //    de retorno.
  vector<Tipo> params;
  bool isRef = false; // se é usado como referencia

  Tipo() {} // Construtor Vazio

  Tipo( string tipo ) {
    tipo_base = tipo;
    ndim = BASICO;
    this->inicio[0] = -1;
    this->fim[0] = -1;
  }

  Tipo( string base, int inicio, int fim  ) {
    tipo_base = base;
    ndim = VETOR;
    this->inicio[0] = inicio;
    this->fim[0] = fim;
  }

  Tipo( string base, int inicio_1, int fim_1, int inicio_2, int fim_2  ) {
    tipo_base = base;
    ndim = MATRIZ;
    this->inicio[0] = inicio_1;
    this->fim[0] = fim_1;
    this->inicio[1] = inicio_2;
    this->fim[1] = fim_2;
  }

  Tipo( Tipo retorno, vector<Tipo> params ) {
    ndim = FUNCAO;
    this->retorno.push_back( retorno );
    this->params = params;
  }
};

struct Atributos {
  string v, c; // Valor, tipo e código gerado.
  Tipo t;
  vector<string> lista_str; // Uma lista auxiliar de strings.
  vector<Tipo> lista_tipo; // Uma lista auxiliar de tipos.
  // Auxiliares de switch
  vector<string> label_cases;
  vector<string> label_cmds;
  vector<string> cmds;
  vector<string> values;
  bool isRef = false; // se é usado como referencia
  bool dflt = false;

  Atributos() {} // Constutor vazio
  Atributos( string valor ) {
    v = valor;
  }

  Atributos( string valor, Tipo tipo ) {
    v = valor;
    t = tipo;
  }
};


// Declarar todas as funções que serão usadas.
void insere_var_ts( string nome_var, Tipo tipo );
void insere_funcao_ts( string nome_func, Tipo retorno, vector<Tipo> params );
Tipo consulta_ts( string nome_var );
vector<Tipo> consulta_retorno( string nome_func );
vector<Tipo> consulta_params( string nome_func );
string declara_variavel( string nome, Tipo tipo );
string declara_funcao( string nome, Tipo retorno,
                       vector<string> nomes, vector<Tipo> tipos );

void empilha_ts();
void desempilha_ts();

void empilha_references();
void desempilha_references();

void insere_reference( string nome_var, bool isRef );
bool consulta_references( string nome_var );

string gera_nome_var_temp( string tipo );
string gera_nome_array_temp( string tipo, int inicio, int fim );
string gera_label( string tipo );
string gera_teste_limite_array( string indice_1, Tipo tipoArray );
string gera_teste_limite_matriz( string indice_1, string indice_2,
                                Tipo tipoArray );

void print( string debug );
void debug( string producao, Atributos atr );
int toInt( string valor );
string toString( int n );

bool podeAtribuir( string tipo1, string tipo2 );

Atributos gera_codigo_not( Atributos s1 );
Atributos gera_codigo_operador( Atributos s1, string opr, Atributos s3 );
Atributos gera_codigo_if( Atributos expr, string cmd_then, string cmd_else );

string traduz_nome_tipo( string tipo_pascal );

map<string, string> inicializaMapEmC();

string includes =
"#include <iostream>\n"
"#include <stdio.h>\n"
"#include <stdlib.h>\n"
"#include <string.h>\n"
"\n"
"using namespace std;\n";


#define YYSTYPE Atributos

%}

%token TK_ID TK_CINT TK_CDOUBLE TK_VAR TK_PROGRAM TK_BEGIN TK_END TK_ATRIB TK_REF
%token TK_WRITELN TK_WRITE TK_READ TK_CSTRING TK_FUNCTION TK_MOD
%token TK_MAIG TK_MEIG TK_MENO TK_MAIO TK_DIF TK_EQUAL TK_IF TK_THEN TK_ELSE TK_AND TK_OR TK_NOT
%token TK_FOR TK_TO TK_DO TK_ARRAY TK_OF TK_PTPT TK_WHILE TK_IN
%token TK_SWITCH TK_CASE TK_DEFAULT TK_ARROW

%left TK_AND TK_OR TK_NOT
%nonassoc TK_MENO TK_MAIO TK_MAIG TK_MEIG '=' TK_DIF TK_EQUAL
%left '+' '-'
%left '*' '/' TK_MOD

%%

S : PROGRAM DECLS MAIN
    {
      cout << includes << endl;
      cout << $2.c << endl;
      cout << $3.c << endl;
    }
  ;

PROGRAM : TK_PROGRAM TK_ID ';'
          { $$.c = "";
            empilha_ts(); }
        ;

DECLS : DECL DECLS
        { $$.c = $1.c + $2.c; }
      |
        { $$.c = ""; }
      ;

DECL : TK_VAR VARS
       { $$.c = $2.c; }
     | FUNCTION
     ;

FUNCTION : { empilha_ts(); empilha_references(); }  CABECALHO ';' CORPO { desempilha_ts(); desempilha_references(); } ';'
           { $$.c = $2.c + " {\n" + $4.c +
                    " return resultado;\n}\n"; }
         ;

CABECALHO : TK_FUNCTION TK_ID OPC_PARAM TK_ARROW TK_ID
            {
              Tipo tipo( traduz_nome_tipo( $5.v ) );

              $$.c = declara_funcao( $2.v, tipo, $3.lista_str, $3.lista_tipo );
              insere_funcao_ts( $2.v, tipo, $3.lista_tipo);
            }
          ;

OPC_PARAM : '(' PARAMS ')'
            { $$ = $2; }
          |
            { $$ = Atributos(); }
          ;

PARAMS : PARAM ';' PARAMS
         { $$.c = $1.c + $3.c;
           // Concatenar as listas.
           $$.lista_tipo = $1.lista_tipo;
           $$.lista_tipo.insert( $$.lista_tipo.end(),
                                 $3.lista_tipo.begin(),
                                 $3.lista_tipo.end() );
           $$.lista_str = $1.lista_str;
           $$.lista_str.insert( $$.lista_str.end(),
                                $3.lista_str.begin(),
                                $3.lista_str.end() );
         }
       | PARAM
       ;

PARAM : IDS TK_ARROW TK_ID
      {
        Tipo tipo = Tipo( traduz_nome_tipo( $3.v ) );

        $$ = Atributos();
        $$.lista_str = $1.lista_str;

        for( int i = 0; i < $1.lista_str.size(); i ++ )
          $$.lista_tipo.push_back( tipo );
      }
    | IDS TK_ARROW TK_ARRAY '[' TK_CINT TK_PTPT TK_CINT ']' TK_OF TK_ID
      {
        Tipo tipo = Tipo( traduz_nome_tipo( $10.v ),
                          toInt( $5.v ), toInt( $7.v ) );

        $$ = Atributos();
        $$.lista_str = $1.lista_str;

        for( int i = 0; i < $1.lista_str.size(); i ++ )
          $$.lista_tipo.push_back( tipo );
      }
    | IDS TK_ARROW TK_ARRAY '[' TK_CINT TK_PTPT TK_CINT ']' '[' TK_CINT TK_PTPT TK_CINT ']' TK_OF TK_ID
      {
        Tipo tipo = Tipo( traduz_nome_tipo( $15.v ),
                        toInt( $5.v ), toInt( $7.v ), toInt( $10.v ), toInt( $12.v ));

        $$ = Atributos();
        $$.lista_str = $1.lista_str;

        for( int i = 0; i < $1.lista_str.size(); i ++ )
            $$.lista_tipo.push_back( tipo );
      }
    | TK_REF IDS TK_ARROW TK_ID
    {
        Tipo tipo = Tipo( traduz_nome_tipo( $4.v ) );

        $$ = Atributos();

        $$.lista_str = $2.lista_str;

        tipo.isRef = true;
        tipo.ndim = VETOR;
        tipo.fim[0] = 1;
        tipo.inicio[0] = 1;
        for ( int i = 0; i < $2.lista_str.size(); i++ ) {
            // print("aqui bugou");
            // print($2.lista_str[i]);
            insere_reference($2.lista_str[i], true);
            $$.lista_tipo.push_back( tipo );
        }
    }
    |
    {
        $$ = Atributos();
    }
    ;

CORPO : TK_VAR VARS CORPO
        { $$.c = $2.c + $3.c; }
      | BLOCO
        { $$.c = declara_variavel( "resultado", consulta_ts( "resultado" ) ) + ";\n" +
                 $1.c; }
      ;

VARS : VAR ';' VARS
       { $$.c = $1.c + $3.c; }
     |
       { $$ = Atributos(); }
     ;

VAR : IDS TK_ARROW TK_ID
      {
        Tipo tipo = Tipo( traduz_nome_tipo( $3.v ) );

        $$ = Atributos();

        for( int i = 0; i < $1.lista_str.size(); i ++ ) {
          $$.c += declara_variavel( $1.lista_str[i], tipo ) + ";\n";
          insere_var_ts( $1.lista_str[i], tipo );
        }
      }
    | IDS TK_ARROW TK_ARRAY '[' TK_CINT TK_PTPT TK_CINT ']' TK_OF TK_ID
      {
        Tipo tipo = Tipo( traduz_nome_tipo( $10.v ),
                          toInt( $5.v ), toInt( $7.v ) );

        $$ = Atributos();

        for( int i = 0; i < $1.lista_str.size(); i ++ ) {
          $$.c += declara_variavel( $1.lista_str[i], tipo ) + ";\n";
          insere_var_ts( $1.lista_str[i], tipo );
        }
      }
    | IDS TK_ARROW TK_ARRAY '[' TK_CINT TK_PTPT TK_CINT ']' '[' TK_CINT TK_PTPT TK_CINT ']' TK_OF TK_ID
      {
        Tipo tipo = Tipo( traduz_nome_tipo( $15.v ),
                        toInt( $5.v ), toInt( $7.v ), toInt( $10.v ), toInt( $12.v ));

        $$ = Atributos();

        for( int i = 0; i < $1.lista_str.size(); i ++ ) {
            $$.c += declara_variavel( $1.lista_str[i], tipo ) + ";\n";
            insere_var_ts( $1.lista_str[i], tipo );
        }
      }
    ;

IDS : IDS ',' TK_ID
      { $$  = $1;
        $$.lista_str.push_back( $3.v ); }
    | TK_ID
      { $$ = Atributos();
        $$.lista_str.push_back( $1.v ); }
    ;

MAIN : BLOCO '.'
       { $$.c = "int main() { \n" + $1.c + "}\n"; }
     ;

BLOCO : TK_BEGIN { var_temp.push_back( "" );} CMDS TK_END
        {
          string vars = var_temp[var_temp.size()-1];
          var_temp.pop_back();
          $$.c = vars + $3.c;
        }
      ;

CMDS : CMD ';' CMDS
       { $$.c = $1.c + $3.c; }
     | { $$.c = ""; }
     ;

CMD : WRITELN
    | WRITE
    | ATRIB
    | READ
    | CMD_IF
    | BLOCO
    | CMD_FOR
    | CMD_WHILE
    | DO
    | CMD_SWITCH
    | E
    ;

CMD_SWITCH : TK_SWITCH F BLOCK_CASE
             {
                 string leave_label = gera_label( "leave" );
                 string condicao = gera_nome_var_temp( "b" );

                 Tipo tipo = consulta_ts($2.v);

                 if (tipo.tipo_base != "i" && tipo.tipo_base != "c")
                    erro("Não é possível fazer switch com tipos diferentes de inteiros ou chars.");

                 for (int i = ($3.dflt) ? 1 : 0; i < $3.label_cases.size(); i++) {
                     string else_label = gera_label( "not_case" );
                     $$.c = $$.c +
                        "  " + condicao + " = " + $2.v + + " == " + $3.values[i] + ";\n"
                        "  if(" + condicao + ") \n" +
                        "   goto " + $3.label_cases[i] + ";\n" +
                        "  goto " + else_label + ";\n" +
                        " " + $3.label_cases[i] + ":\n" +
                        $3.cmds[i] + "\n" +
                        "  goto " + leave_label + ";\n" +
                        "  " + else_label + ":;\n";
                 }

                 if ($3.dflt)
                    $$.c = $$.c +
                        "  "  + $3.cmds[0] + "\n";
                 $$.c = $$.c +
                    "  " + leave_label + ":;\n";
             }
             ;

BLOCK_CASE : TK_CASE TK_ARROW E TK_BEGIN CMDS TK_END BLOCK_CASE
             {
                 string label_case = gera_label( "case" );

                 $$.label_cases = $7.label_cases;
                 $$.label_cases.push_back(label_case);
                 $$.cmds = $7.cmds;
                 $$.cmds.push_back($5.c);
                 $$.values = $7.values;
                 $$.values.push_back($3.v);
                 $$.dflt = $7.dflt;
             }
           | TK_CASE TK_ARROW E TK_BEGIN CMDS TK_END
             {
                 string label_case = gera_label( "case" );
                 string label_cmd = gera_label( "cmd" );

                 $$.label_cases.push_back(label_case);
                 $$.label_cmds.push_back(label_cmd);
                 $$.cmds.push_back($5.c);
                 $$.values.push_back($3.v);
             }
           | TK_DEFAULT TK_BEGIN CMDS TK_END
             {
                 string label_default = gera_label( "default" );
                 string label_cmd = gera_label( "cmd" );

                 $$.label_cases.push_back(label_default);
                 $$.label_cmds.push_back(label_cmd);
                 $$.cmds.push_back($3.c);
                 $$.values.push_back("-1");
                 $$.dflt = true;
             }
           ;

DO : TK_DO TK_BEGIN CMDS TK_END TK_WHILE E
        {
            string label_teste = gera_label( "teste_while" );
            string label_fim = gera_label( "fim_while" );
            string condicao = gera_nome_var_temp( "b" );

            $$.c =
                "  " + label_teste + ":\n" +
                "  " + $3.c +
                "  " + $6.c +
                "  " + condicao + " = !" + $6.v + ";\n" +
                "  " + "if( " + condicao + " ) goto " + label_fim + ";\n" +
                "  goto " + label_teste  + ";\n"+
                "  " + label_fim + ":;\n";
        }
    ;

CMD_WHILE : TK_WHILE E TK_DO TK_BEGIN CMDS TK_END
            {
                string label_teste = gera_label( "teste_while" );
                string label_fim = gera_label( "fim_while" );
                string condicao = gera_nome_var_temp( "b" );


                $$.c =
                    "  " + label_teste + ":\n" +
                    "  " + $2.c +
                    "  " + condicao + " = !" + $2.v + ";\n" +
                    "  " + "if( " + condicao + " )\n" +
                    "  goto " + label_fim + ";\n" +
                    "  " + $5.c +
                    "  goto " + label_teste  + ";\n"+
                    "  " + label_fim + ":;\n";
            }
            ;

CMD_FOR : TK_FOR NOME_VAR TK_ATRIB E TK_TO E TK_DO TK_BEGIN CMDS TK_END
          {
            string var_fim = gera_nome_var_temp( $2.t.tipo_base );
            string label_teste = gera_label( "teste_for" );
            string label_fim = gera_label( "fim_for" );
            string condicao = gera_nome_var_temp( "b" );

            if ($4.t.tipo_base != "i" || $6.t.tipo_base != "i")
                erro("Tentando fazer for com um numero não inteiro!");

            $$.c =  $4.c + $6.c +
                    "  " + $2.v + " = " + $4.v + ";\n" +
                    "  " + var_fim + " = " + $6.v + ";\n" +
                    label_teste + ":;\n" +
                    "  " +condicao+" = "+$2.v + " >= " + var_fim + ";\n" +
                    "  " + "if( " + condicao + " ) goto " + label_fim +
                    ";\n" +
                    $9.c +
                    "  " + $2.v + " = " + $2.v + " + 1;\n" +
                    "  goto " + label_teste + ";\n" +
                    label_fim + ":;\n";
          }
        ;

CMD_IF : TK_IF E TK_THEN TK_BEGIN CMDS TK_END
         { $$ = gera_codigo_if( $2, $5.c, "" ); }
       | TK_IF E TK_THEN TK_BEGIN CMDS TK_END TK_ELSE TK_BEGIN CMDS TK_END
         { $$ = gera_codigo_if( $2, $5.c, $9.c ); }
       | TK_IF TK_ID TK_IN TK_ID TK_THEN TK_BEGIN CMDS TK_END
         {
             Tipo tipo1 = consulta_ts($2.v);
             Tipo tipo3 = consulta_ts($4.v);

             string aux;
             string fim = gera_label( "fim" );
             string var = gera_nome_var_temp( "b" );
             string condicao = gera_nome_var_temp ( "b" );
             string value1 = gera_nome_var_temp ( tipo1.tipo_base );
             string value2 = gera_nome_var_temp ( tipo3.tipo_base );

             bool isRef = consulta_references($2.v);

             if (tipo1.tipo_base != tipo3.tipo_base) {
                 erro("Clasula 'in' deve ser feito com operadores de mesmo tipo.");
             }
             if (tipo3.ndim == 0) {
                 erro("Clasula 'in' deve ser feita com um array.");
             }

             aux +=
                 "  " + var + " = 0;\n";

             for (int i = tipo3.inicio[0]; i < tipo3.fim[0]; i++) {
                 string label_proximo = gera_label( "proximo" );

                 aux +=
                    "  " + value1 + " = " + $2.v + ((isRef) ? "[0]" : "") + ";\n" +
                    "  " + value2 + " = " + $4.v + "[" + toString(i - tipo3.inicio[0]) + "];\n" +
                    "  " + condicao + " = " + value1 + " != " + value2 + ";\n" +
                    "  if (" + condicao + ") \n" +
                    "   goto " + label_proximo + ";\n" +
                    "  "  + var + " = 1;\n" +
                    "  " + label_proximo + ":;\n";
             }

             $$.c =
                 $2.c + $4.c + aux +
                 "  " + var + " = !" + var + ";\n" +
                 "  if(" + var + ")\n" +
                 "   goto " + fim + ";\n" +
                 $7.c +
                 "  " + fim + ":;\n";
        }
        | TK_IF TK_ID TK_IN TK_ID TK_THEN TK_BEGIN CMDS TK_END TK_ELSE TK_BEGIN CMDS TK_END
          {
              Tipo tipo1 = consulta_ts($2.v);
              Tipo tipo3 = consulta_ts($4.v);

              string aux;
              string fim = gera_label( "fim" );
              string fim_else = gera_label( "fim_else" );
              string var = gera_nome_var_temp( "b" );
              string condicao = gera_nome_var_temp ( "b" );
              string value1 = gera_nome_var_temp ( tipo1.tipo_base );
              string value2 = gera_nome_var_temp ( tipo3.tipo_base );

              bool isRef = consulta_references($2.v);

              if (tipo1.tipo_base != tipo3.tipo_base) {
                  erro("Clasula 'in' deve ser feito com operadores de mesmo tipo.");
              }
              if (tipo3.ndim == 0) {
                  erro("Clasula 'in' deve ser feita com um array.");
              }

              aux +=
                  "  " + var + " = 0;\n";

              for (int i = tipo3.inicio[0]; i < tipo3.fim[0]; i++) {
                  string label_proximo = gera_label( "proximo" );

                  aux +=
                     "  " + value1 + " = " + $2.v + ((isRef) ? "[0]" : "") + ";\n" +
                     "  " + value2 + " = " + $4.v + "[" + toString(i - tipo3.inicio[0]) + "];\n" +
                     "  " + condicao + " = " + value1 + " != " + value2 + ";\n" +
                     "  if (" + condicao + ") \n" +
                     "   goto " + label_proximo + ";\n" +
                     "  "  + var + " = 1;\n" +
                     "  " + label_proximo + ":;\n";
              }

              $$.c =
                  $2.c + $4.c + aux +
                  "  " + var + " = !" + var + ";\n" +
                  "  if(" + var + ")\n" +
                  "   goto " + fim_else + ";\n" +
                  $7.c +
                  "  goto " + fim + ";\n" +
                  "  " + fim_else + ":;\n" +
                  $11.c +
                  "  " + fim + ":;\n";
         }
        ;


WRITELN : TK_WRITELN '(' E ')'
          { $$.c = $3.c +
                   "  cout << " + $3.v + ";\n" +
                   "  cout << endl;\n";
          }
        ;

WRITE : TK_WRITE '(' E ')'
          { $$.c = $3.c +
                   "  cout << " + $3.v + ";\n";
          }
        ;

READ : TK_READ '(' E ')'
        {
            $$.c = $3.c + "  cin >> " + $3.v + ";\n";
        }
     ;


ATRIB : TK_ID TK_ATRIB E
        {
            static map<string, string> em_C = inicializaMapEmC();

            $1.t = consulta_ts( $1.v ) ; // checa se existe e retorna tipo
            Tipo tipo1 = $1.t, tipo2 = $3.t;
            //   print("attr");
            //   print($1.v);
            //   print($3.v);
            if (!podeAtribuir(em_C[tipo1.tipo_base], em_C[tipo2.tipo_base]))
            erro("Variaveis de diferentes tipos nao podem ser atribuidas:" + $1.t.tipo_base + " != " + $3.t.tipo_base);

            if( $1.t.tipo_base == "s" ) {
            //   print($1.t.tipo_base);
            //   print($1.v);
              $$.c = $3.c + "  strncpy( " + $1.v + ", " + $3.v + ", 256 );\n";
            }
            else {

                // print($1.v + $3.v);

                bool isRef = consulta_references($1.v);
                // print(toString(isRef));

                $$.c =
                    $3.c +
                    "  " + $1.v + ((isRef) ? "[0]" : "") + " = " + $3.v + ";\n";
            }

            debug( "ATRIB : TK_ID TK_ATRIB E ';'", $$ );
        }
      | TK_ID '[' E ']' TK_ATRIB E
        {
            static map<string, string> em_C = inicializaMapEmC();

            string condicao = gera_nome_var_temp( "b" );
            string finish = gera_label( "finish" );
            string continua = gera_label( "continua" );

            $1.t = consulta_ts( $1.v ); // checa se existe e retorna tipo

            Tipo tipo1 = $1.t, tipo2 = $6.t;

            if (!podeAtribuir(em_C[tipo1.tipo_base], em_C[tipo2.tipo_base])) {
                erro("Variaveis de diferentes tipos não podem ser atribuidas." + em_C[tipo1.tipo_base] + " - " + em_C[tipo2.tipo_base]);
            }

            if ($3.t.tipo_base != "i")
                erro("Indexando array sem ser por inteiro.");

            string indice = gera_nome_var_temp( "i" );
            $$.c =
                $3.c + $6.c +
                gera_teste_limite_array( $3.v, tipo1 ) +
                "  " + indice + " = " + $3.v + " - " + toString(tipo1.inicio[0]) + ";\n" +
                "  " + $1.v + "[" + indice + "] = " + $6.v + ";\n";
        }
      | TK_ID '[' E ']' '[' E ']' TK_ATRIB E
      {
          static map<string, string> em_C = inicializaMapEmC();

          string condicao = gera_nome_var_temp( "b" );
          string finish = gera_label( "finish" );
          string continua = gera_label( "continua" );

          $1.t = consulta_ts( $1.v ); // checa se existe e retorna tipo

          Tipo tipo1 = $1.t, tipo2 = $9.t;

        //   print($1.t.tipo_base);

          if (!podeAtribuir(em_C[tipo1.tipo_base], em_C[tipo2.tipo_base])) {
              erro("Variaveis de diferentes tipos não podem ser atribuidas." + em_C[tipo1.tipo_base] + " - " + em_C[tipo2.tipo_base]);
          }

          if ($3.t.tipo_base != "i" || $6.t.tipo_base != "i")
              erro("Indexando array sem ser por inteiro.");

          int size = tipo1.fim[1] - tipo1.inicio[1] + 1;
        //   print($1.v);
        //   print(toString(tipo1.inicio[0]));
        //   print(toString(tipo1.fim[0]));
        //   print(toString(tipo1.inicio[1]));
        //   print(toString(tipo1.fim[1]));

          string indice = gera_nome_var_temp( "i" );
          $$.c =
              $3.c + $6.c + $9.c +
              gera_teste_limite_matriz( $3.v, $6.v, tipo1 ) +
              "  " + indice + " = " + $3.v + " - " + toString(tipo1.inicio[0]) + ";\n" +
              "  " + indice + " = " + indice + " * " + toString(size) + ";\n" +
              "  " + indice + " = " + indice + " + " + $6.v + ";\n" +
              "  " + indice + " = " + indice + " - " + toString(tipo1.inicio[1]) + ";\n" +
              "  " + $1.v + "[" + indice + "] = " + $9.v + ";\n";
      }
      ;

E : E '+' E
    { $$ = gera_codigo_operador( $1, "+", $3 ); }
  | E '-' E
    { $$ = gera_codigo_operador( $1, "-", $3 ); }
  | E '*' E
    { $$ = gera_codigo_operador( $1, "*", $3 ); }
  | E TK_MOD E
    {
        // print($1.v); print($3.v);
        $$ = gera_codigo_operador( $1, "%", $3 ); }
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
  | E TK_MAIO E
    { $$ = gera_codigo_operador( $1, ">", $3 ); }
  | E TK_MENO E
    { $$ = gera_codigo_operador( $1, "<", $3 ); }
  | E TK_EQUAL E
    { $$ = gera_codigo_operador( $1, "==", $3 ); }
  | E TK_DIF E
    { $$ = gera_codigo_operador( $1, "!=", $3 ); }
  | E TK_AND E
    { $$ = gera_codigo_operador( $1, "&&", $3 ); }
  | E TK_OR E
    { $$ = gera_codigo_operador( $1, "||", $3 ); }
  | TK_NOT E
    { $$ = gera_codigo_not( $2 ); }
  | '(' E ')'
    { $$ = $2; }
  | F
  ;

F : TK_CINT
    { $$.v = $1.v; $$.t = Tipo( "i" ); $$.c = $1.c; }
  | TK_CDOUBLE
    { $$.v = $1.v; $$.t = Tipo( "d" ); $$.c = $1.c; }
  | TK_CSTRING
    {
        // string x = $1.v;
        // for (string::iterator it = x.begin(); it != x.end(); ++it) {
        //     printf("%s\n", *it);
        // }
        $$.v = $1.v; $$.t = Tipo( "s" ); $$.c = $1.c; }
  | '-' TK_CINT
  {
      string minus = gera_nome_var_temp( "i" );
      $$.c =
        "  " + minus + " = 0 - " + $2.v + ";\n" +
        $2.c;
      $$.v = minus; $$.t = Tipo( "i" );
  }
  | '-' TK_CDOUBLE
  {
      string minus = gera_nome_var_temp( "i" );
      $$.c =
        "  " + minus + " = 0 - " + $2.v + ";\n" +
        $2.c;
      $$.v = minus; $$.t = Tipo( "d" );
  }
  | TK_ID '[' E ']'
    {
      Tipo tipoArray = consulta_ts( $1.v );
      if( tipoArray.ndim != 1 )
        erro( "Variável " + $1.v + " não é array de uma dimensão" );

      if( $3.t.ndim != 0 || $3.t.tipo_base != "i" )
        erro( "Indice de array deve ser integer de zero dimensão: " +
              $3.t.tipo_base + "/" + toString( $3.t.ndim ) );


      string indice = gera_nome_var_temp( "i" );
      $$.t = Tipo( tipoArray.tipo_base );
      $$.v = gera_nome_var_temp( $$.t.tipo_base );
      $$.c = $3.c +
             gera_teste_limite_array( $3.v, tipoArray ) +
             "  " + indice + " = " + $3.v + " - " + toString(tipoArray.inicio[0]) + ";\n" +
             "  " + $$.v + " = " + $1.v + "[" + indice + "];\n";
    }
  | TK_ID '[' E ']' '[' E ']'
    {
      // Implementar: vai criar uma temporaria int para o índice e
      // outra do tipoBase do array para o valor recuperado.
      string indice = gera_nome_var_temp( "i" );

      Tipo tipoArray = consulta_ts( $1.v );
      $$.t = Tipo( tipoArray.tipo_base );

      if( tipoArray.ndim != 2 )
        erro( "Variável " + $1.v + " não é array de duas dimensões" );

      if( $3.t.ndim != 0 || $3.t.tipo_base != "i"  || $6.t.tipo_base != "i" || $6.t.ndim != 0)
        erro( "Indices da array de duas dimensoes devem ser dois integer de zero dimensão: " +
            $3.t.tipo_base + "/" + toString( $3.t.ndim ) +
            $6.t.tipo_base + "/" + toString( $6.t.ndim ) );

      int size0 = tipoArray.fim[1] - tipoArray.inicio[1] + 1;
      $$.v = gera_nome_var_temp( tipoArray.tipo_base );
      $$.c = $3.c + $6.c +
             gera_teste_limite_matriz( $3.v, $6.v, tipoArray ) +
             "  " + indice + " = " + $3.v + " - " + toString(tipoArray.inicio[0]) + ";\n" +
             "  " + indice + " = " + indice + " * " + toString(size0) + ";\n" +
             "  " + indice + " = " + indice + " + " + $6.v + ";\n" +
             "  " + indice + " = " + indice + " - " + toString(tipoArray.inicio[1]) + ";\n" +
             "  " + $$.v + " = " + $1.v + "[" + indice + "];\n";
    }
  | TK_ID
    { $$.v = $1.v; $$.t = consulta_ts( $1.v ); $$.c = $1.c; }
  | TK_ID '(' EXPRS ')'
    {
        vector<Tipo> params = consulta_params($1.v);
        $$.t = consulta_retorno($1.v)[0]; // consulta_ts( $1.v );
        $$.v = gera_nome_var_temp( $$.t.tipo_base );

        string post = "";

        //   print($1.v);
        for (int i = 0; i < params.size(); i++) {
            // print(params[i].tipo_base + " " + $3.lista_tipo[i].tipo_base);
            if (params[i].tipo_base != $3.lista_tipo[i].tipo_base)
                erro("Parametros incorretos." + params[i].tipo_base + " - " + $3.lista_tipo[i].tipo_base + " i:" + toString(i));
            if (params[i].isRef) {
                string ref = gera_nome_array_temp( params[i].tipo_base, 1, 1);
                $3.c +=
                    "  " + ref + "[0] = " + $3.lista_str[i] + ";\n";
                post +=
                    "  " + $3.lista_str[i] + " = " + ref + "[0];\n";
                $3.lista_str[i] = ref;
            }
        }

        $$.c = $3.c +
            "  " + $$.v + " = " + $1.v + "( ";
        for( int i = 0; i < $3.lista_str.size() - 1; i++ ) {
        //   print(params[i].tipo_base + " " + $3.lista_tipo[i].tipo_base);
        if (params[i].tipo_base != $3.lista_tipo[i].tipo_base)
            erro("Parametros incorretos." + params[i].tipo_base + " - " + $3.lista_tipo[i].tipo_base);
        $$.c += $3.lista_str[i] + ", ";
        }

        //   print(params[$3.lista_str.size() - 1].tipo_base + " " + $3.lista_tipo[$3.lista_str.size() - 1].tipo_base);
        if (params[$3.lista_str.size() - 1].tipo_base != $3.lista_tipo[$3.lista_str.size() - 1].tipo_base)
            erro("Parametros incorretos." + params[$3.lista_str.size() - 1].tipo_base + " - " + $3.lista_tipo[$3.lista_str.size() - 1].tipo_base);
        $$.c += $3.lista_str[$3.lista_str.size()-1] + " );\n";
        $$.c += post;
    }
    | TK_ID '(' ')'
    {
        // print($1.v);
        $$.t = consulta_retorno($1.v)[0];
        $$.v = gera_nome_var_temp( $$.t.tipo_base );
        $$.c =
            "  " + $$.v + " = " + $1.v + "();\n";
    }
  ;

EXPRS : EXPRS ',' E
        { $$ = Atributos();
          $$.c = $1.c + $3.c;
          $$.lista_tipo = $1.lista_tipo;
          $$.lista_tipo.push_back( $3.t );
          $$.lista_str = $1.lista_str;
          $$.lista_str.push_back( $3.v ); }
      | E
        { $$ = Atributos();
          $$.c = $1.c;
          $$.lista_tipo.push_back( $1.t );
          $$.lista_str.push_back( $1.v ); }
      ;

NOME_VAR : TK_ID
           { $$.v = $1.v; $$.t = consulta_ts( $1.v ); $$.c = $1.c; }
         ;

%%
int nlinha = 1;

#include "lex.yy.c"

int yyparse();

void print( string msg ) {
    cerr << msg << endl;
}

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
  printf( "%s", st );
  printf( "Linha: %d, \"%s\"\n", nlinha, yytext );
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

  // Resultados para o operador "%"
  tipo_opr["i%i"] = "i";

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
  tipo_opr["s<s"] = "b";

  // Resultados para o operador ">"
  tipo_opr["i>i"] = "b";
  tipo_opr["i>d"] = "b";
  tipo_opr["d>i"] = "b";
  tipo_opr["d>d"] = "b";
  tipo_opr["c>c"] = "b";
  tipo_opr["i>c"] = "b";
  tipo_opr["c>i"] = "b";
  tipo_opr["s>s"] = "b";

  // Resultados para o operador "<="
  tipo_opr["i<=i"] = "b";
  tipo_opr["i<=d"] = "b";
  tipo_opr["d<=i"] = "b";
  tipo_opr["d<=d"] = "b";
  tipo_opr["c<=c"] = "b";
  tipo_opr["i<=c"] = "b";
  tipo_opr["c<=i"] = "b";

  // Resultados para o operador ">="
  tipo_opr["i>=i"] = "b";
  tipo_opr["i>=d"] = "b";
  tipo_opr["d>=i"] = "b";
  tipo_opr["d>=d"] = "b";
  tipo_opr["c>=c"] = "b";
  tipo_opr["i>=c"] = "b";
  tipo_opr["c>=i"] = "b";

  // Resultados para o operador "And"
  tipo_opr["b&&b"] = "b";
  // Resultados para o operador "OR"
  tipo_opr["b||b"] = "b";

  // Resultados para o operador "=="
  tipo_opr["i==i"] = "b";
  tipo_opr["i==d"] = "b";
  tipo_opr["d==i"] = "b";
  tipo_opr["d==d"] = "b";
  tipo_opr["s==s"] = "b";
  tipo_opr["s==c"] = "b";
  tipo_opr["c==s"] = "b";
  tipo_opr["c==c"] = "b";

  // Resultados para o operador "!="
  tipo_opr["i!=i"] = "b";
  tipo_opr["i!=d"] = "b";
  tipo_opr["d!=i"] = "b";
  tipo_opr["d!=d"] = "b";
  tipo_opr["s!=s"] = "b";
  tipo_opr["s!=c"] = "b";
  tipo_opr["c!=s"] = "b";
  tipo_opr["c!=c"] = "b";

}

// Uma tabela de símbolos para cada escopo
vector< map< string, Tipo > > ts;

// Faz mapeamento de variaveis usadas como referencia.
vector< map< string, bool > > references;

void empilha_ts() {
  map< string, Tipo > novo;
  ts.push_back( novo );
}

void desempilha_ts() {
  ts.pop_back();
}


void empilha_references() {
  map< string, bool > novo;
  references.push_back( novo );
}

void desempilha_references() {
  references.pop_back();
}

Tipo consulta_ts( string nome_var ) {

    for( int i = ts.size()-1; i >= 0; i-- )
        if( ts[i].find( nome_var ) != ts[i].end() ) {
            return ts[i][ nome_var ];
        }

    erro( "Variável não declarada: " + nome_var );

    return Tipo();
}

bool consulta_references( string nome_var ) {

    for ( int i = references.size() - 1; i >= 0; i-- ) {
        if( references[i].find( nome_var ) != references[i].end() ) {
            return references[i][ nome_var ];
        }
    }

    return false;
}

vector<Tipo> consulta_retorno( string nome_func ) {
  for( int i = ts.size()-1; i >= 0; i-- )
  if( ts[i].find( nome_func ) != ts[i].end() )
      return ts[i][ nome_func ].retorno;

  erro( "Função não declarada: " + nome_func );

  return vector<Tipo>();
}

vector<Tipo> consulta_params( string nome_func ) {
  for( int i = ts.size()-1; i >= 0; i-- )
    if( ts[i].find( nome_func ) != ts[i].end() )
      return ts[i][ nome_func ].params;

  erro( "Função não declarada: " + nome_func );

  return vector<Tipo>();
}

void insere_reference( string nome_var, bool isRef ) {
    if( references[references.size()-1].find( nome_var ) != references[references.size()-1].end() ) {
      erro( "Referencia já declarada: " + nome_var + " (" + toString(references[references.size()-1][ nome_var ]) + ")" );
    }

    references[references.size()-1][ nome_var ] = isRef;
    // print(nome_var + " " + toString(isRef));

}

void insere_var_ts( string nome_var, Tipo tipo ) {
  if( ts[ts.size()-1].find( nome_var ) != ts[ts.size()-1].end() )
    erro( "Variável já declarada: " + nome_var +
          " (" + ts[ts.size()-1][ nome_var ].tipo_base + ")" );

  ts[ts.size()-1][ nome_var ] = tipo;
}

void insere_funcao_ts( string nome_func,
                       Tipo retorno, vector<Tipo> params ) {
  if( ts[ts.size()-2].find( nome_func ) != ts[ts.size()-2].end() )
    erro( "Função já declarada: " + nome_func );

  ts[ts.size()-2][ nome_func ] = Tipo( retorno, params );
}

string toString( int n ) {
  char buff[100];

  sprintf( buff, "%d", n );

  return buff;
}

int toInt( string valor ) {
  int aux = -1;

  if( sscanf( valor.c_str(), "%d", &aux ) != 1 )
    erro( "Numero inválido: " + valor );

  return aux;
}
string gera_nome_var_temp( string tipo ) {
  static int n = 0;
  string nome = "t" + tipo + "_" + toString( ++n );

  var_temp[var_temp.size()-1] += declara_variavel( nome, Tipo( tipo ) ) + ";\n";

  return nome;
}

string gera_nome_array_temp( string tipo, int inicio, int fim ) {
  static int n = 0;
  string nome = "a" + tipo + "_" + toString( ++n );

  var_temp[var_temp.size()-1] += declara_variavel( nome, Tipo( tipo, inicio, fim ) ) + ";\n";

  return nome;
}

string gera_label( string tipo ) {
  static int n = 0;
  string nome = "l_" + tipo + "_" + toString( ++n );

  return nome;
}

Tipo tipo_resultado( Tipo t1, string opr, Tipo t3, bool isRef1, bool isRef3 ) {
  if(( t1.ndim == 0 && t3.ndim == 0) || (t1.ndim == 0 && isRef3) || (isRef1 && t3.ndim == 0)) {
    string aux = tipo_opr[ t1.tipo_base + opr + t3.tipo_base ];

    if( aux == "" )
      erro( "O operador " + opr + " não está definido para os tipos '" +
            t1.tipo_base + "' e '" + t3.tipo_base + "'.");

    return Tipo( aux );
  }
  else { // Testes para os operadores de comparacao de array
      return Tipo();
  }
}

Atributos gera_codigo_not( Atributos s1 ) {
    Atributos ret;

    bool isRef = consulta_references(s1.v);

    ret.t = Tipo("b");
    ret.v = gera_nome_var_temp( "b" );
    ret.c = s1.c + " " + ret.v + (isRef ? "[0]" : "") + " = !" + s1.v + ";\n";

    return ret;
}

Atributos gera_codigo_operador( Atributos s1, string opr, Atributos s3 ) {
    Atributos ss;

    bool isRef1 = consulta_references(s1.v);
    bool isRef3 = consulta_references(s3.v);

    ss.t = tipo_resultado( s1.t, opr, s3.t, isRef1, isRef3);
    // print(ss.t.tipo_base);
    ss.v = gera_nome_var_temp( ss.t.tipo_base );

    if( s1.t.tipo_base == "s" && s3.t.tipo_base == "s" ) {
        string cmp = gera_nome_var_temp( "b" );
        if( opr == "==" || opr == "!=") {
            ss.c =
            s1.c + s3.c +
            "  " + cmp + " = strcmp( " + s1.v + ", " + s3.v + "); \n" +
            "  " + ss.v + " = " + cmp + ((opr == "==") ? "==" : "!=") + " 0 " + ";\n";
        }
        else if( opr == "+")
        {
          ss.c = s1.c + s3.c + // Codigo das expressões dos filhos da arvore.
                 "  strncpy( " + ss.v + ", " + s1.v + ", 256 );\n" +
                 "  strncat( " + ss.v + ", " + s3.v + ", 256 );\n";
        }
        else if (opr == "<" || opr == ">")
        {
            ss.c =  s1.c + s3.c +
                    "   " + cmp + " = strcmp( " + s1.v + ", " + s3.v + "); \n" +
                    "   " + ss.v + " = " + cmp + ((opr == ">")? " > " : " < ") + " 0 ;\n";
        }
    }
    else if( s1.t.tipo_base == "s" && s3.t.tipo_base == "c" ) {
        if (opr == "==" || opr == "!=") {
            string size = gera_nome_var_temp( "b" );
            string firstChar = gera_nome_var_temp( "c" );
            string secondChar = gera_nome_var_temp( "c" );

            ss.c =
                s1.c + s3.c +
                "  " + firstChar + " = " + s1.v + "[0];\n" +
                "  " + secondChar + " = " + s1.v + "[1];\n" +
                "  " + ss.v + " = " + firstChar + " " + ((opr == "==") ? "==" : "!=") + " " + s3.v + ";\n" +
                "  " + size + " = " + secondChar + " " + ((opr == "==") ? "==" : "!=") + " 0;\n" +
                "  " + ss.v + " = " + ss.v + " && " + size + ";\n";
        }
        else if ( opr == "+" ) {
            string temp = gera_nome_var_temp( "s" );

            ss.c =
                s1.c + s3.c + // Codigo das expressões dos filhos da arvore.
                "  " + temp + "[0] = " + s3.v + ";\n" +
                "  " + temp + "[1] = 0;\n" +
                "  strncpy( " + ss.v + ", " + s1.v + ", 256 );\n" +
                "  strncat( " + ss.v + ", " + temp + ", 256 );\n";
        }

    }
    else if( s1.t.tipo_base == "c" && s3.t.tipo_base == "s" ) {
        if (opr == "==" || opr == "!=") {
            string size = gera_nome_var_temp( "b" );
            string firstChar = gera_nome_var_temp( "c" );
            string secondChar = gera_nome_var_temp( "c" );
            ss.c =
                s1.c + s3.c +
                "  " + firstChar + " = " + s1.v + "[0];\n" +
                "  " + secondChar + " = " + s1.v + "[1];\n" +
                "  " + ss.v + " = " + firstChar + " " + ((opr == "==") ? "==" : "!=")  + " " + s3.v + ";\n" +
                "  " + size + " = " + secondChar + " " + ((opr == "==") ? "==" : "!=")  + " 0;\n" +
                "  " + ss.v + " = " + ss.v + " && " + size + ";\n";
        }
        else if ( opr == "+" ) {
            string temp = gera_nome_var_temp( "s" );

            ss.c =
                s1.c + s3.c + // Codigo das expressões dos filhos da arvore.
                "  " + temp + "[0] = " + s1.v + ";\n"+
                "  " + temp + "[1] = 0;\n" +
                "  strncpy( " + ss.v + ", " + s3.v + ", 256 );\n" +
                "  strncat( " + ss.v + ", " + temp + ", 256 );\n";
        }
    }
    else if (isRef1) {
        string temp = gera_nome_var_temp( s1.t.tipo_base );
        ss.c =
            s1.c + s3.c + // Codigo das expressões dos filhos da arvore.
            "  " + temp + " = " + s1.v + "[0];\n" +
            "  " + ss.v + " = " + temp + " " + opr + " " + s3.v + ";\n";
    }
    else if (isRef3) {
        string temp = gera_nome_var_temp( s1.t.tipo_base );
        ss.c =
            s1.c + s3.c + // Codigo das expressões dos filhos da arvore.
            "  " + temp + " = " + s3.v + "[0];\n" +
            "  " + ss.v + " = " + s1.v + " " + opr + " " + temp + ";\n";
    }
    else {
        ss.c =
            s1.c + s3.c + // Codigo das expressões dos filhos da arvore.
            "  " + ss.v + " = " + s1.v + " " + opr + " " + s3.v + ";\n";
    }
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


string traduz_nome_tipo( string tipo_pascal ) {
  // No caso do Pascal, a comparacao deveria ser case-insensitive

  if( tipo_pascal == "inteiro" )
    return "i";
  else if( tipo_pascal == "booleano" )
    return "b";
  else if( tipo_pascal == "real" )
    return "d";
  else if( tipo_pascal == "caracter" )
    return "c";
  else if( tipo_pascal == "string" )
    return "s";
  else
    erro( "Tipo inválido: " + tipo_pascal );
}

map<string, string> inicializaMapEmC() {
  map<string, string> aux;
  aux["i"] = "int ";
  aux["b"] = "int ";
  aux["d"] = "double ";
  aux["c"] = "char ";
  aux["s"] = "char ";
  return aux;
}

map<string, string> inicializaMapEmCFunc() {
  map<string, string> aux;
  aux["i"] = "int ";
  aux["b"] = "int ";
  aux["d"] = "double ";
  aux["c"] = "char ";
  aux["s"] = "char ";
  return aux;
}
string declara_funcao( string nome, Tipo tipo,
                       vector<string> nomes, vector<Tipo> tipos ) {
  static map<string, string> em_C = inicializaMapEmCFunc();

  if( em_C[ tipo.tipo_base ] == "" ) {
    erro( "Func - Tipo inválido: " + tipo.tipo_base );
  }

  insere_var_ts( "resultado", tipo );

  if( nomes.size() != tipos.size() )
    erro( "Bug no compilador! Nomes e tipos de parametros diferentes." );

    string aux = "";

    for( int i = 0; i < nomes.size(); i++ ) {
    //   print(nomes[i]);
        aux += declara_variavel( nomes[i], tipos[i] ) +
            (i == nomes.size()-1 ? " " : ", ");
        insere_var_ts( nomes[i], tipos[i] );
    }


  return em_C[ tipo.tipo_base ] + nome + "(" + aux + ")";
}

string declara_variavel( string nome, Tipo tipo ) {
  static map<string, string> em_C = inicializaMapEmC();

  if( em_C[ tipo.tipo_base ] == "" ) {
    // print(nome);
    erro( "Var - Tipo inválido: " + tipo.tipo_base );
  }

  string indice, aux;

  switch( tipo.ndim ) {
    case 0: indice = (tipo.tipo_base == "s" ? "[256]" : "");
            break;

    case 1: indice = "[" + toString(
                  (tipo.fim[0]-tipo.inicio[0]+1) *
                  (tipo.tipo_base == "s" ? 256 : 1)
                ) + "]";
            break;

    case 2: indice = "[" + toString(
                    (tipo.fim[0] - tipo.inicio[0] + 1) *
                    (tipo.tipo_base == "s" ? 256 : 1)
                    *
                    (tipo.fim[1] - tipo.inicio[1] + 1) *
                    (tipo.tipo_base == "s" ? 256 : 1)
                ) + "]";
            break;

    default:
       erro( "Bug muito sério..." );
  }

  return em_C[ tipo.tipo_base ] + nome + indice;
}

string gera_teste_limite_matriz( string indice_1, string indice_2, Tipo tipoArray) {
    string var_teste_inicio1 = gera_nome_var_temp( "b" );
    string var_teste_fim1 = gera_nome_var_temp( "b" );
    string var_teste_inicio2 = gera_nome_var_temp( "b" );
    string var_teste_fim2 = gera_nome_var_temp( "b" );
    string var_teste = gera_nome_var_temp( "b" );
    string label_end = gera_label( "limite_array_ok" );

    string codigo = "  " + var_teste_inicio1 + " = " + indice_1 + " >= " +
                    toString( tipoArray.inicio[0] ) + ";\n" +
                    "  " + var_teste_fim1 + " = " + indice_1 + " <= " +
                    toString( tipoArray.fim[0] ) + ";\n" +
                    "  " + var_teste_inicio2 + " = " + indice_2 + " >= " +
                    toString( tipoArray.inicio[1] ) + ";\n" +
                    "  " + var_teste_fim2 + " = " + indice_2 + " <= " +
                    toString( tipoArray.fim[1] ) + ";\n" +
                    "  " + var_teste + " = " + var_teste_inicio1 + " && " + var_teste_fim1 + ";\n" +
                    "  " + var_teste + " = " + var_teste + " && " + var_teste_inicio2 + ";\n" +
                    "  " + var_teste + " = " + var_teste + " && " + var_teste_fim2 + ";\n";

    codigo +=
            "  if( " + var_teste + " ) goto " + label_end + ";\n" +
            "    printf( \"Limite de array ultrapassado: %d <= %d <= %d, %d <= %d <= %d\", " +
            toString( tipoArray.inicio[0] ) + " ," +
            indice_1 + ", " +
            toString( tipoArray.fim[0] ) + ", " +
            toString( tipoArray.inicio[1] ) + ", " +
            indice_2 + ", " +
            toString( tipoArray.fim[2] ) + " );\n" +
            "  cout << endl;\n" +
            "  exit( 1 );\n" +
            "  " + label_end + ":;\n";

    return codigo;
}

string gera_teste_limite_array( string indice_1, Tipo tipoArray ) {
  string var_teste_inicio = gera_nome_var_temp( "b" );
  string var_teste_fim = gera_nome_var_temp( "b" );
  string var_teste = gera_nome_var_temp( "b" );
  string label_end = gera_label( "limite_array_ok" );

  string codigo = "  " + var_teste_inicio + " = " + indice_1 + " >= " +
                  toString( tipoArray.inicio[0] ) + ";\n" +
                  "  " + var_teste_fim + " = " + indice_1 + " <= " +
                  toString( tipoArray.fim[0] ) + ";\n" +
                  "  " + var_teste + " = " + var_teste_inicio + " && " +
                                             var_teste_fim + ";\n";

  codigo += "  if( " + var_teste + " ) goto " + label_end + ";\n" +
          "    printf( \"Limite de array ultrapassado: %d <= %d <= %d\", "+
               toString( tipoArray.inicio[0] ) + " ," + indice_1 + ", " +
               toString( tipoArray.fim[0] ) + " );\n" +
               "  cout << endl;\n" +
               "  exit( 1 );\n" +
            "  " + label_end + ":;\n";

  return codigo;
}

bool podeAtribuir( string tipo1, string tipo2 ) {
    return tipo1 == tipo2 || (tipo1 == "double " && tipo2 == "int ") || (tipo1 == "int " && tipo2 == "char ") || (tipo1 == "char " && tipo2 == "int ");
}

int main( int argc, char* argv[] )
{
  inicializa_operadores();
  yyparse();
}
