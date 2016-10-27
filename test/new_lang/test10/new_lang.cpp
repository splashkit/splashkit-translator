#include "new_lang.h"

#include <iostream>
using namespace std;

namespace splashkit_lib
{
  void update_1d(array_1d v)
  {
    v.value[1] -= 10;
  }
  void update_2d(array_2d v)
  {
    v.value[1][2] -= 30;
  }
}
