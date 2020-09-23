using static SplashKitSDK.SplashKit;
using static System.Console;
using System.Collections.Generic;

public class Program
{
  public static void Main()
  {
    List<bool> arr;

    arr = GetBools();
    PrintAll(arr);
    WriteLine("Adding false");
    AddBool(ref arr, false);
    for (int i = 0; i < 300; i++)
    {
      AddBool(ref arr, i % 2 == 0);
      WriteLine(i);
    }
    PrintAll(arr);
  }
}
