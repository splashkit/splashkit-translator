using static SplashKitSDK.SplashKit;
using static System.Console;
using System.Collections.Generic;

public class Program
{
  public static void Main()
  {
    Flag v;
    BasicFlag v1;

    v1 = GetBasicFlag();
    PrintBasicFlag(v1);

    PrintBasicFlag(BasicFlag.Option1);
    PrintBasicFlag(BasicFlag.Option2);
    PrintBasicFlag(BasicFlag.AOption);

    WriteLine("---");
    v = GetFlag();
    PrintFlag(v);

    PrintFlag(Flag.Flag1);
    PrintFlag(Flag.Flag10);
  }
}
