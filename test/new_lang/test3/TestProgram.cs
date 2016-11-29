using static SplashKitSDK.SplashKit;
using static System.Console;

public class Program
{
    public static void Main()
    {
        WriteLine(GetInt());
        WriteLine(GetInt(1));
        WriteLine(GetUint(2));
        WriteLine(GetShort(3));
        WriteLine(GetUshort(4));
        WriteLine(GetFloat(5.55f));
        WriteLine(GetDouble(6.66));
        WriteLine(GetLong(-1));
        WriteLine(GetChar('A'));
        WriteLine(GetUchar('a'));
        WriteLine(GetBool(true));
        WriteLine(GetBool(false));
    }
}
