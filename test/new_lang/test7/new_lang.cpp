#include "new_lang.h"

#include <iostream>
using namespace std;

namespace splashkit_lib
{
   void print_flag(flag x)
   {
      cout << "Flag is: " << static_cast<int>(x) << endl;
   }

   flag get_flag()
   {
     return FLAG_10;
   }
}
