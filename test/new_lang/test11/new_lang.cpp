#include "new_lang.h"
#include <stdlib.h>
#include <iostream>

namespace splashkit_lib
{
  void print_string(const string &s)
  {
    cout << "The value is: " << s << endl;
  }

  string get_string()
  {
     return "Getting started";
  }
}
