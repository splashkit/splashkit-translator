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
    result.points[0] = { 1, 1};
    result.points[1] = {-2, -2};
    result.points[2] = {10, -3.14};
    return result;
  }

  void print_triangle(triangle t)
  {
    cout << t.points[0].x << ":" << t.points[0].y <<  " " << t.points[1].x << ":" << t.points[1].y << " " << t.points[2].x << ":" << t.points[2].y << endl;
  }

  void update_triangle(triangle &t)
  {
    for( int i = 0; i < 3; i++ )
    {
      t.points[i].x *= 2;
      t.points[i].y *= 2;
    }
  }
}
