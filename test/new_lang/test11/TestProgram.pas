program TestProgram;
uses SplashKit;

procedure Main();
var
  s: String;
begin
  s := GetString();
  PrintString(s);
  s := 'Now its this';
  PrintString(s);
end;

begin
  Main();
end.
