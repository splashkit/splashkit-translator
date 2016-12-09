using SplashKitSDK;
using static SplashKitSDK.SplashKit;
using static System.Console;
using System.Collections.Generic;

public class Program
{
  public static void Main()
  {
    Array1D a1;
    Array2D a2;

    a1.values = new int[2];
    a2.values = new int[2,3];

    a1.values[0] = 0;
    a1.values[1] = 10;
    WriteLine("Updating a1.values[1] from: {0}", a1.values[1]);
    Update1D(ref a1);
    WriteLine("It is now: {0}", a1.values[1]);
    a2.values[0,0] = 0;
    a2.values[1,2] = 30;
    WriteLine("Updating a2.values[1,2] from: {0}", a2.values[1,2]);
    Update2D(ref a2);
    WriteLine("It is now: {0}", a2.values[1,2]);

    Triangle t;

    t = GetTriangle();
    PrintTriangle(t);
    UpdateTriangle(ref t);
    PrintTriangle(t);
    t.points[0].x = 100;
    PrintTriangle(t);
  }
}
