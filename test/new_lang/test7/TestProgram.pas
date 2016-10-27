program TestProgram;
uses SplashKit;

procedure Main();
var
  v: Flag;
begin
  v := GetFlag();
  PrintFlag(v);

  PrintFlag(FLAG_1);
  PrintFlag(FLAG_10);
end;

begin
  Main();
end.
