program TestProgram;
uses SplashKit;

procedure Main();
var
  a1: Array1D;
  a2: Array2D;
begin
  a1[0] := 0;
  a1[1] := 10;
  WriteLn('Updating a1[1] from: ', a1[1]);
  Update1D(a1);
  WriteLn('It is now: ', a1[1]);
  a2[0,0] := 0;
  a2[1,2] := 30;
  WriteLn('Updating a2[1,0] from: ', a2[1,2]);
  Update2D(a2);
  WriteLn('It is now: ', a2[1,2]);
end;

begin
  Main();
end.
