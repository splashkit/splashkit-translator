program TestProgram;
uses SplashKit;

procedure Main();
var
  s: Array of String;
  i: Integer;
begin
  for i := 0 to 10000 do
  begin
    s := GetStrings();
    PrintStrings(s);
    AddString(s, 'Yay');
    PrintStrings(s);
  end;
  ReadLn();
end;

begin
  Main();
end.
