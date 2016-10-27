#include "new_lang6.h"

#include <iostream>
using namespace std;

namespace splashkit_lib
{
   void print_vector(const vector_2d &x)
   {
      cout << x.x << "," << x.y << endl;
   }

   vector_2d get_vector()
   {
     return { 1.111, 2.222 };
   }
}
