#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

using namespace std;

char nomes1[256];
char nomes2[256];
char resultado[256];
int formata(char a[256], char b[256], char c[256] ) {
int resultado;
int tb_1;
int tb_2;
char ts_3[256];
int tb_4;
char ts_5[256];
int tb_6;
char ts_7[256];
int tb_8;
char ts_9[256];
int tb_10;
char ts_11[256];
int tb_12;
char ts_13[256];
int tb_14;
   tb_2 = strcmp( a, b); 
   tb_1 = tb_2 >  0 ;
  tb_1 = !tb_1;

  if( tb_1 ) goto l_else_1;
  strncpy( ts_3, "Sr(a). ", 256 );
  strncat( ts_3, a, 256 );
  strncpy( ts_5, ts_3, 256 );
  strncat( ts_5, ", ", 256 );
  strncpy( ts_7, ts_5, 256 );
  strncat( ts_7, b, 256 );
  strncpy( c, ts_7, 256 );
  goto l_end_2;
l_else_1:;
  strncpy( ts_9, "Ms (a). ", 256 );
  strncat( ts_9, b, 256 );
  strncpy( ts_11, ts_9, 256 );
  strncat( ts_11, ", ", 256 );
  strncpy( ts_13, ts_11, 256 );
  strncat( ts_13, a, 256 );
  strncpy( c, ts_13, 256 );
l_end_2:;
 return resultado;
}

int main() { 
int ti_15;
char ts_16[256];
int tb_17;
char ts_18[256];
int tb_19;
int ti_20;
char ts_21[256];
int tb_22;
char ts_23[256];
int tb_24;
int ti_25;
char ts_26[256];
int tb_27;
  cout << "digite o seu nome:";
  cin >> nomes1;
  cout << "digite o seu sobrenome:";
  cin >> nomes2;
  cout << "\n";
  ti_15 = formata( nomes1, nomes2, resultado );
  strncpy( ts_16, "Bom dia, ", 256 );
  strncat( ts_16, resultado, 256 );
  cout << ts_16;
  cout << endl;
  strncpy( ts_18, nomes1, 256 );
  strncat( ts_18, nomes2, 256 );
  ti_20 = formata( "", ts_18, resultado );
  strncpy( ts_21, "Bom dia, ", 256 );
  strncat( ts_21, resultado, 256 );
  cout << ts_21;
  cout << endl;
  strncpy( ts_23, " ", 256 );
  strncat( ts_23, nomes2, 256 );
  ti_25 = formata( nomes1, ts_23, resultado );
  strncpy( ts_26, "Bom dia, ", 256 );
  strncat( ts_26, resultado, 256 );
  cout << ts_26;
  cout << endl;
}

