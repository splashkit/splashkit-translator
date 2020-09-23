using SplashKitSDK;
using static SplashKitSDK.SplashKit;
using static System.Console;
using System.Collections.Generic;

public class Program
{
  public static void Main()
  {
    WriteLine("Enter to start...");
    ReadLine();

    List<string> s = new List<string>();
    s.Add("Hello");

    for (int i = 0; i < 10000; i++)
    {
      // s = GetStrings();
      PrintStrings(s);
      // AddString(ref s, "Yay");
      // PrintStrings(s);
    }

    ReadLine();
  }
}
