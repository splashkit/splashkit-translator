#include "new_lang.h"

#include <iostream>
using namespace std;

namespace splashkit_lib
{
  void print_vector(const vector_2d &x)
  {
    cout << x.x << "," << x.y << " and " << x.multi_name << " mapped " << x.mapped << endl;
  }

  vector_2d get_vector()
  {
    return { 1.111, 2.222, 10, false };
  }
}
