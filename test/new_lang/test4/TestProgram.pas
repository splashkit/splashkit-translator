program TestProgram;
uses SplashKit;

procedure Main();
var
  i: Integer;
  ui: Cardinal;
  f: Single;
  d: Double;
  sh: ShortInt;
  ush: Word;
  l: Int64;
  ch: Char;
  uch: Char;
  b: Boolean;
begin
  i := 10;
  f := 1.11;
  d := 2.22;
  sh := -3;
  ush := 4;
  l := 5;
  ch := 'a';
  uch := 'B';
  b := true;
  ui := 50;


  WriteLn(i, ' get ', GetAndUpdateInt(i), ' updated int ', i);

  Write(i, ' ');
  UpdateInt(i);
  WriteLn('Updated int: ', i);

  Write(ui, ' ');
  UpdateUInt(ui);
  WriteLn('Updated uint: ', ui);

  Write(sh, ' ');
  UpdateShort(sh);
  WriteLn('Updated short int: ', sh);

  Write(ush, ' ');
  UpdateUShort(ush);
  WriteLn('Updated short int: ', ush);

  Write(f:4:2, ' ');
  UpdateFloat(f);
  WriteLn('Updated float: ', f:4:2);

  Write(d:4:2, ' ');
  UpdateDouble(d);
  WriteLn('Updated double: ', d:4:2);

  Write(l, ' ');
  UpdateLong(l);
  WriteLn('Updated long: ', l);

  Write(ch, ' ');
  UpdateChar(ch);
  WriteLn('Updated char: ', ch);

  Write(uch, ' ');
  UpdateChar(uch);
  WriteLn('Updated char: ', uch);

  Write(b, ' ');
  UpdateBool(b);
  WriteLn('Updated bool: ', b);
end;

begin
  Main();
end.
