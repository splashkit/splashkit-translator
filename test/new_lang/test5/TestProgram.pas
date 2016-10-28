program TestProgram;
uses SplashKit;

procedure Main();
var
  arr: array of Boolean;
begin
  arr := GetBools();
  PrintAll(arr);
  WriteLn('Adding false');
  AddBool(arr, false);
  PrintAll(arr);
end;

begin
  Main();
end.
