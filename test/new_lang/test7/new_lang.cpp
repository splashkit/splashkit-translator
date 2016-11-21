#include "new_lang.h"

#include <iostream>
using namespace std;

namespace splashkit_lib
{
  basic_flag get_basic_flag()
  {
    return A_OPTION;
  }

  void print_basic_flag(basic_flag bf)
  {
    cout << "Basic Flag is: " << static_cast<int>(bf) << endl;
  }

  void print_flag(flag x)
  {
    cout << "Flag is: " << static_cast<int>(x) << endl;
  }

  flag get_flag()
  {
    return FLAG_10;
  }
}
