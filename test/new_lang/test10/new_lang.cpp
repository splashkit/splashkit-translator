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

  triangle get_triangle()
  {
    triangle result;
    result.my_points[0] = { 1, 1};
    result.my_points[1] = {-2, -2};
    result.my_points[2] = {10, -3.14};
    return result;
  }

  void print_triangle(triangle t)
  {
    cout << t.my_points[0].x << ":" << t.my_points[0].y <<  " " << t.my_points[1].x << ":" << t.my_points[1].y << " " << t.my_points[2].x << ":" << t.my_points[2].y << endl;
  }

  void update_triangle(triangle &t)
  {
    for( int i = 0; i < 3; i++ )
    {
      t.my_points[i].x *= 2;
      t.my_points[i].y *= 2;
    }
  }
}
