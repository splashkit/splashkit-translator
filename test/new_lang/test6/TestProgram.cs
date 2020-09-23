using static SplashKitSDK.SplashKit;
using static System.Console;
using System.Collections.Generic;

public class Program
{
  public static void Main()
  {
    Vector2D v;

    v = GetVector();
    PrintVector(v);
    WriteLine("Matches: {0},{1} and {2} is mapped {3}", v.x, v.y, v.multiName, v.mapped);
  }
}
