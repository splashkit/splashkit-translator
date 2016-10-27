program TestProgram;
uses SplashKit;

procedure Main();
var
  arr: array of Integer;
begin
  SetLength(arr, 2);
  arr[0] := 1;
  arr[0] := -100;

  PrintAll(arr);
end;

begin
  Main();
end.
