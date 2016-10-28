program TestProgram;
uses SplashKit;

procedure Main();
var
  a1: Array1D;
  a2: Array2D;
begin
  a1.values[0] := 0;
  a1.values[1] := 10;
  WriteLn('Updating a1.values[1] from: ', a1.values[1]);
  Update1D(a1);
  WriteLn('It is now: ', a1.values[1]);
  a2.values[0,0] := 0;
  a2.values[1,2] := 30;
  WriteLn('Updating a2.values[1,2] from: ', a2.values[1,2]);
  Update2D(a2);
  WriteLn('It is now: ', a2.values[1,2]);
end;

begin
  Main();
end.
