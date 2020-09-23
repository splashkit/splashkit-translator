#include "new_lang.h"

#include <iostream>
using namespace std;

namespace splashkit_lib
{
   int get_and_update_int(int &x)
   {
     x += 10;
     return 10;
   }

   void update_int(int &x)
   {
     x = x * 2;
   }

   void update_float(float &x)
   {
     x = x * 2;
   }

   void update_double(double &x)
   {
     x = x * 2;
   }

   void update_char(char &x)
   {
     x = x + 1;
   }

   void update_bool(bool &x)
   {
     x = not x;
   }

   void update_short(short &x)
   {
     x = x * 2;
   }

   void update_long(int64_t &x)
   {
     x = x * 2;
   }

   void update_uint(unsigned int &x)
   {
     x = x * 2;
   }

   void update_ushort(unsigned short &x)
   {
     x = x * 2;
   }

   void update_uchar(unsigned char &x)
   {
     x = x + 1;
   }
}
