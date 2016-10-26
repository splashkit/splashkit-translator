program TestProgram;
uses SplashKit;

procedure Main();
begin
  WriteLn(GetInt());
  WriteLn(GetInt(1));
  WriteLn(GetUInt(2));
  WriteLn(GetShort(3));
  WriteLn(GetUShort(4));
  WriteLn(GetFloat(5.55):4:2);
  WriteLn(GetDouble(6.66):4:2);
  WriteLn(GetLong(7));
  WriteLn(GetChar('A'));
  WriteLn(GetUChar('a'));
  WriteLn(GetBool(true));
  WriteLn(GetBool(false));
end;

begin
  Main();
end.
