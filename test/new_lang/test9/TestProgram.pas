program TestProgram;
uses SplashKit;

procedure Main();
var
  s: AStruct;
  sPtr: StructPtr;
begin
  s.value := 10;
  sPtr := @s;
  WriteLn('The value of struct value is: ', s.value);
  WriteLn('Calling update func!');
  UpdateStruct(sPtr);
  WriteLn('The value of struct value is: ', s.value);
end;

begin
  Main();
end.
