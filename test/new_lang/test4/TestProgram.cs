using static SplashKitSDK.SplashKit;
using static System.Console;

public class Program
{
  public static void Main()
  {
    int i;
    uint ui;
    float f;
    double d;
    short sh;
    ushort ush;
    long l;
    char ch;
    byte uch;
    bool b;

    i = 10;
    f = 1.11f;
    d = 2.22;
    sh = -3;
    ush = 4;
    l = 5;
    ch = 'a';
    uch = (byte)'B';
    b = true;
    ui = 50;


    WriteLine("{0} get {1} updated int {2}", i, GetAndUpdateInt(ref i), i);

    Write("{0} ", i);
    UpdateInt(ref i);
    WriteLine("Updated int: {0}", i);

    Write("{0} ", ui);
    UpdateUint(ref ui);
    WriteLine("Updated uint: {0}", ui);

    Write("{0} ", sh);
    UpdateShort(ref sh);
    WriteLine("Updated short int: {0}", sh);

    Write("{0} ", ush);
    UpdateUshort(ref ush);
    WriteLine("Updated short int: {0}", ush);

    Write("{0} ", f);
    UpdateFloat(ref f);
    WriteLine("Updated float: {0}", f);

    Write("{0} ", d);
    UpdateDouble(ref d);
    WriteLine("Updated double: {0}", d);

    Write("{0} ", l);
    UpdateLong(ref l);
    WriteLine("Updated long: {0}", l);

    Write("{0} ", ch);
    UpdateChar(ref ch);
    WriteLine("Updated char: {0}", ch);

    Write("{0} ", uch);
    UpdateUchar(ref uch);
    WriteLine("Updated char: {0}", uch);

    Write("{0} ", b);
    UpdateBool(ref b);
    WriteLine("Updated bool: {0}", b);
  }
}
