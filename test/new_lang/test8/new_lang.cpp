#include "new_lang.h"

#include <iostream>
using namespace std;

namespace splashkit_lib
{
   void run_func(func_name *v)
   {
      cout << "About to run" << endl;
      cout << "Return: " << v(1) << endl;
      cout << "Ran!" << endl;
   }

   void run_proc(proc_name *v)
   {
      cout << "About to run" << endl;
      v(1);
      cout << "Ran!" << endl;
   }
}
