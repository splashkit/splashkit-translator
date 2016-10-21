program TestProgram;
uses SplashKit;

// procedure __sklib__say_yay(); cdecl; external;
//
// procedure SayYay();
// begin
//   __sklib__say_yay();
// end;

procedure Main();
begin
  SayYay();
  SayYayInt(1);
  SayYayUInt(2);
  SayYayShort(3);
  SayYayUShort(4);
  SayYayFloat(5.5);
  SayYayDouble(6.6);
  SayYayLong(7);
  SayYayChar('A');
  SayYayUChar('A');
  SayYayBool(true);
  SayYayBool(false);

end;

begin
  Main();
end.
