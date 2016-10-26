#include "new_lang3.h"

#include <iostream>
using namespace std;

namespace splashkit_lib
{
   int get_int()
   {
     return 10;
   }

   int get_int(int x)
   {
     return x * 2;
   }

   float get_float(float x)
   {
     return x * 2;
   }

   double get_double(double x)
   {
     return x * 2;
   }

   char get_char(char x)
   {
     return x + 1;
   }

   bool get_bool(bool x)
   {
     return not x;
   }

   short get_short(short x)
   {
     return x * 2;
   }

   long get_long(long x)
   {
     return x * 2;
   }

   unsigned int get_uint(unsigned int x)
   {
     return x * 2;
   }

   unsigned short get_ushort(unsigned short x)
   {
     return x * 2;
   }

   unsigned char get_uchar(unsigned char x)
   {
     return x + 1;
   }
}
