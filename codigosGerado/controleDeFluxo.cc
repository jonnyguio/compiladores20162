#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

using namespace std;

double referencia;
int b[12];
char string1[256];
char string2[256];
char char1;
int Teste5(int arg ) {
int b;
double y;
int resultado;
int tb_1;
double td_2;
int tb_3;
int ti_4;
int tb_5;
int ti_6;
int tb_7;
  tb_7 = arg == 2;
  if(tb_7) 
   goto l_case_7;
  goto l_not_case_10;
 l_case_7:
  cout << 2;
  cout << endl;

  goto l_leave_9;
  l_not_case_10:;
  tb_7 = arg == 1;
  if(tb_7) 
   goto l_case_8;
  goto l_not_case_11;
 l_case_8:
  b = 0;
  ti_4 = 10;
l_teste_for_3:;
  tb_5 = b >= ti_4;
  if( tb_5 ) goto l_fim_for_4;
  y = 5.0;
  l_teste_while_1:
    tb_1 = y > 0.0;
  tb_3 = !tb_1;
  if( tb_3 )
  goto l_fim_while_2;
    td_2 = y - 1.5;
  y = td_2;
  goto l_teste_while_1;
  l_fim_while_2:;
  b = b + 1;
  goto l_teste_for_3;
l_fim_for_4:;
  cout << 1;
  cout << endl;

  goto l_leave_9;
  l_not_case_11:;
    ti_6 = 0 - 1;
  cout << ti_6;
  cout << endl;

  l_leave_9:;
 return resultado;
}

int main() { 
int tb_8;
int ti_9;
int tb_10;
int tb_11;
int tb_12;
int tb_13;
int tb_14;
int tb_15;
int tb_16;
char tc_17;
char tc_18;
char ts_19[256];
int tb_20;
char ts_21[256];
char ts_22[256];
int tb_23;
int tb_24;
char tc_25;
char tc_26;
char ts_27[256];
int tb_28;
char ts_29[256];
char ts_30[256];
int ti_31;
int ti_32;
int ti_33;
int ti_34;
  tb_10 = 3 >= 3;
  tb_11 = 3 <= 5;
  tb_12 = 4 >= 1;
  tb_13 = 4 <= 4;
  tb_14 = tb_10 && tb_11;
  tb_14 = tb_14 && tb_12;
  tb_14 = tb_14 && tb_13;
  if( tb_14 ) goto l_limite_array_ok_14;
    printf( "Limite de array ultrapassado: %d <= %d <= %d, %d <= %d <= %d", 3 ,3, 5, 1, 4, 0 );
  cout << endl;
  exit( 1 );
  l_limite_array_ok_14:;
  ti_9 = 3 - 3;
  ti_9 = ti_9 * 4;
  ti_9 = ti_9 + 4;
  ti_9 = ti_9 - 1;
  b[ti_9] = 2;
  strncpy( string1, "a", 256 );
  strncpy( string2, "bc", 256 );
  char1 = 97;
  tc_17 = string1[0];
  tc_18 = string1[1];
  tb_15 = tc_17 == char1;
  tb_16 = tc_18 == 0;
  tb_15 = tb_15 && tb_16;
  tb_15 = !tb_15;

  if( tb_15 ) goto l_else_15;
  strncpy( ts_19, string1, 256 );
  strncat( ts_19, " igual a ", 256 );
  ts_22[0] = char1;
  ts_22[1] = 0;
  strncpy( ts_21, ts_19, 256 );
  strncat( ts_21, ts_22, 256 );
  cout << ts_21;
  cout << endl;
  goto l_end_16;
l_else_15:;
l_end_16:;
  tc_25 = string1[0];
  tc_26 = string1[1];
  tb_23 = tc_25 != char1;
  tb_24 = tc_26 != 0;
  tb_23 = tb_23 && tb_24;
  tb_23 = !tb_23;

  if( tb_23 ) goto l_else_17;
  strncpy( ts_27, string1, 256 );
  strncat( ts_27, " diferente de ", 256 );
  ts_30[0] = char1;
  ts_30[1] = 0;
  strncpy( ts_29, ts_27, 256 );
  strncat( ts_29, ts_30, 256 );
  cout << ts_29;
  cout << endl;
  goto l_end_18;
l_else_17:;
l_end_18:;
  ti_31 = Teste5( 1 );
  ti_32 = Teste5( 5 );
  ti_33 = Teste5( 4 );
  ti_34 = Teste5( 2 );
}

