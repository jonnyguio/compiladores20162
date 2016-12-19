Program HelloWorld;

Var a : Array [3 .. 10] Of Integer;
Var b : Array [1 .. 5] [1 .. 5] Of Integer;
Var string1, string2 : String;
Var char1 : Char;
Var space : String;

Function MDC( a, b : Integer; teste : Real ): Integer;
Begin
  If a Mod b = 0 Then
    Begin
      Result := b;
    End
  Else
    Begin
      Result := MDC( b, a Mod b, 1.0 );
    End;
End;

Function Teste( c : Integer; d : Integer): Boolean;
Begin
    If c >= d Then
      Begin
        Result := 1;
        End
    Else
      Begin
        Result := Not 0;
      End;
End;

Function Teste3(d : Integer): Integer;
Var fim : String;
Begin
    Do
    Begin
        While d > 5 Do
        Begin
          WriteLn(d);
          d := d - 1;
        End;
        fim := 'Chega';
        WriteLn(fim);
        WriteLn(d);
        d := d - 1;
    End While d > 0;
End;

Function Teste5(arg : Integer): Integer;
Var x : Integer;
Var y : Real;
Begin
    Switch arg
    Case : 1
      Begin
        For x := 0 To 10 Do
        Begin
          y := 5.0;
          While y > 0.0 Do
          Begin
            WriteLn(y);
            y := y - 1.5;
          End;
          WriteLn(x);
        End;
      End
    Case : 2
      Begin
        WriteLn(2);
      End
    Default
      Begin
        WriteLn(0);
      End;
End;

Begin
  b[3][5] := 2;
  string1 := 'abc';
  string2 := 'bbc';
  char1 := 97;
  space := ' ';
  If string1 = char1 Then
  Begin
    WriteLn(string1 + char1);
  End;
  If string1 > string2 Then
  Begin
    WriteLn('Maior' + string1);
  End;
  If string1 < string2 Then
  Begin
    WriteLn('Menor' + string2);
  End;
  Teste5(b[3][5]);
  WriteLn( MDC( 48, 32, 1.0 ) );
End.
