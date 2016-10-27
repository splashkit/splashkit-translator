#include "new_lang5.h"

#include <vector>
#include <iostream>
using namespace std;

namespace splashkit_lib
{
   void print_all(const vector<int> &x)
   {
        for (size_t i = 0; i < x.size(); i++)
        {
            cout << x[i] << endl;
        }
   }
}
