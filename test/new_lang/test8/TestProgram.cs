using static SplashKitSDK.SplashKit;
using static System.Console;
using System.Collections.Generic;

public class Program
{
  private static int AFunc(int x)
  {
    WriteLine("Hello {0}", x);
    return x + 10;
  }

  private static void AProc(int x)
  {
    WriteLine("Hello World {0}", x);
  }

  public static void Main()
  {
    RunFunc(AFunc);
    RunProc(AProc);
  }
}
