Program HelloWorld;

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
      Result := 0;
End;

Begin
  WriteLn( Teste(10, 2) );
  WriteLn( MDC( 48, 32, 1.0 ) );
End.
