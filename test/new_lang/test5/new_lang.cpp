#include "new_lang.h"

#include <vector>
#include <iostream>
using namespace std;

namespace splashkit_lib
{
   void print_all(const vector<bool> &x)
   {
        cout << "Printing Array:" << endl;
        for (size_t i = 0; i < x.size(); i++)
        {
            cout << "[" << i << "] => " << x[i] << endl;
        }
        cout << "---" << endl;
   }

   void add_bool(vector<bool> &x, bool val)
   {
      x.push_back(val);
   }

   vector<bool> get_bools()
   {
      cout << "Getting Array..." << endl;
      vector<bool> result;
      result.push_back(true);
      return result;
   }
}
