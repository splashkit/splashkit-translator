program TestProgram;
uses SplashKit;

procedure Main();
var
  v: Flag;
  v1: BasicFlag;
begin
  v1 := GetBasicFlag();
  PrintBasicFlag(v1);

  PrintBasicFlag(OPTION_1);
  PrintBasicFlag(OPTION_2);
  PrintBasicFlag(A_OPTION);

  WriteLn('---');
  v := GetFlag();
  PrintFlag(v);

  PrintFlag(FLAG_1);
  PrintFlag(FLAG_10);
end;

begin
  Main();
end.
