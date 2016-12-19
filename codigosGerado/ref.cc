#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

using namespace std;

double a;
int TesteRef(double args[1] ) {
double y;
int resultado;
double td_1;
double td_2;
  td_2 = args[0];
  td_1 = td_2 * 7;
  y = td_1;
  args[0] = y;
 return resultado;
}

int main() { 
int ti_3;
double ad_1[1];
  a = 5;
  ad_1[0] = a;
  ti_3 = TesteRef( ad_1 );
  a = ad_1[0];
  cout << a;
  cout << endl;
}

