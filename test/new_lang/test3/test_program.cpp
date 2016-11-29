#include "splashkit.h"

#include <iostream>
using namespace std;

int main()
{
  cout << get_int() << endl;
  cout << get_int(1) << endl;
  cout << get_uint(2) << endl;
  cout << get_short(3) << endl;
  cout << get_ushort(4) << endl;
  cout << get_float(5.55) << endl;
  cout << get_double(6.66) << endl;
  cout << get_long(7) << endl;
  cout << get_char('A') << endl;
  cout << get_uchar('a') << endl;
  cout << get_bool(true) << endl;
  cout << get_bool(false) << endl;
}
