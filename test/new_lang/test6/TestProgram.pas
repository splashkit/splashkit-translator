program TestProgram;
uses SplashKit;

procedure Main();
var
  v: Vector2D;
begin
  v := GetVector();
  PrintVector(v);
  WriteLn('Matches: ', v.x, ',', v.y, ' and ', v.MultiName);
end;

begin
  Main();
end.
