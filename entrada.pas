Program HelloWorld;

Var y : Boolean;

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
Begin
    Do
    Begin
        WriteLn(d);
        d := d - 1;
    End While d > 0;
End;

Function Teste4(d : Integer): Integer;
Begin
    While d > 0 Do
    Begin
        WriteLn(d);
        d := d - 1;
    End;
End;

Begin
  Teste3(0);
  Teste4(0);
  WriteLn( MDC( 48, 32, 1.0 ) );
End.
