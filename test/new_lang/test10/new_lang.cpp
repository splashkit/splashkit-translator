#include "new_lang.h"

#include <iostream>
using namespace std;

namespace splashkit_lib
{
  void update_1d(array_1d &v)
  {
    v.values[1] = 0;
  }
  void update_2d(array_2d &v)
  {
    v.values[1][2] = 0;
  }
}
