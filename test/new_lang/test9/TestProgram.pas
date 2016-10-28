program TestProgram;
uses SplashKit;

procedure Main();
var
  sPtr: StructPtr;
begin
  sPtr := GetStruct();
  PrintStruct(sPtr);
  WriteLn('Calling update func!');
  UpdateStruct(sPtr);
  PrintStruct(sPtr);
end;

begin
  Main();
end.
