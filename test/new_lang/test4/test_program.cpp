#include <splashkit.h>

#include <iostream>
using namespace std;

int main()
{
  int i;
  uint ui;
  float f;
  double d;
  short sh;
  unsigned short ush;
  int64_t l;
  char ch;
  unsigned char uch;
  bool b;

  i = 10;
  f = 1.11f;
  d = 2.22;
  sh = -3;
  ush = 4;
  l = 5;
  ch = 'a';
  uch = 'B';
  b = true;
  ui = 50;

  cout << i << " get " << get_and_update_int(i) << " updated int " << i << endl;

  cout << i << " ";
  update_int(i);
  cout << "Updated int: " << i << endl;

  cout << ui << " ";
  update_uint(ui);
  cout << "Updated uint: " << ui << endl;

  cout << sh << " ";
  update_short(sh);
  cout << "Updated short int: " << sh << endl;

  cout << ush << " ";
  update_ushort(ush);
  cout << "Updated short int: " << ush << endl;

  cout << f << " ";
  update_float(f);
  cout << "Updated float: " << f << endl;

  cout << d << " ";
  update_double(d);
  cout << "Updated double: " << d << endl;

  cout << l << " ";
  update_long(l);
  cout << "Updated long: " << l << endl;

  cout << ch << " ";
  update_char(ch);
  cout << "Updated char: " << ch << endl;

  cout << uch << " ";
  update_uchar(uch);
  cout << "Updated char: " << uch << endl;

  cout << b << " ";
  update_bool(b);
  cout << "Updated bool: " << b << endl;
}
