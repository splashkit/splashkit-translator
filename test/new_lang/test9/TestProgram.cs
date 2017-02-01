using SplashKitSDK;
using static SplashKitSDK.SplashKit;
using static System.Console;
using System.Collections.Generic;

public class Program
{
  public static void Main()
  {
    StructPtr sPtr, other;

    TestStruct t = TestStruct.GetTest;

    WriteLine("t.x = {0} t.ToInt = {1}", t.X, t.ToInt());

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

    List<int> data = sPtr.DataList;

    foreach(int i in data) WriteLine($"Got {i} from data list...");

    using ( sPtr = GetStruct() )
    {
      sPtr.Print();
      sPtr.Update();

      WriteLine("Values are now {0} and {1}", sPtr.Value, other.Value);
      sPtr.Value += 10;
      other.Value += 10;
      WriteLine("Values are now {0} and {1}", sPtr.Value, other.Value);
    }
    WriteLine("New sPTr should be deleted!");
    DeleteStructPtr(other);

    PrintValue();
    WriteLine("Value {0}", GetValue());
    TestStatic.Print();
    WriteLine("Value {0}", TestStatic.Value);
  }
}
