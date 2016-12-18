Program HelloWorld;

Var a : Array [1 .. 10] Of Integer;

Function MDC( a, b : Integer; teste : Real ): Integer;
Begin
  If a Mod b = 0 Then
    Result := b
  Else
    Result := MDC( b, a Mod b, 1.0 );
End;

Function Teste( c : Integer; d : Integer): Boolean;
Begin
    If c >= d Then
      Result := 1
    Else
      Result := Not 0;
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
  a[11] := 0;
  Teste5(2);
  WriteLn( MDC( 48, 32, 1.0 ) );
End.
