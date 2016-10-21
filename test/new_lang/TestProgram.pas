program TestProgram;
// using SplashKit;

procedure __sklib__say_yay(); cdecl; external;

procedure SayYay();
begin
  __sklib__say_yay();
end;

procedure Main();
begin
  SayYay();
end;

begin
  Main();
end.
