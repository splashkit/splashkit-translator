program TestProgram;
uses SplashKit;

function AFunc(x: Integer): Integer; cdecl;
begin
  WriteLn('Hello', x);
  result := x + 10;
end;

procedure AProc(x: Integer); cdecl;
begin
  WriteLn('Hello World', x);
end;

procedure Main();
begin
  RunFunc(@AFunc);
  RunProc(@AProc);
end;

begin
  Main();
end.
