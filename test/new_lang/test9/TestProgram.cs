using SplashKitSDK;
using static SplashKitSDK.SplashKit;
using static System.Console;
using System.Collections.Generic;

public class Program
{
  public static void Main()
  {
    StructPtr sPtr, other;

    sPtr = GetStruct();
    PrintStruct(sPtr);
    WriteLine("Calling update func!");
    UpdateStruct(sPtr);
    PrintStruct(sPtr);

    WriteLine("Calling print,update,print via object!");
    sPtr.Update(5);
    sPtr.Print();
    sPtr.Update();
    sPtr.Print();
    sPtr.UpdateOther(10);
    sPtr.Print();

    other = sPtr;

    using ( sPtr = GetStruct() )
    {
      sPtr.Print();
      sPtr.Update();
    }
    WriteLine("New sPTr should be deleted!");
    DeleteStructPtr(other);
  }
}
