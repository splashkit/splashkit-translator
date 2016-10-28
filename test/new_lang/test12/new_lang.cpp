#include "new_lang.h"
#include <stdlib.h>
#include <iostream>

namespace splashkit_lib
{
  void add_string(vector<string> &v, const string &s)
  {
    v.push_back(s);
  }

  void print_strings(const vector<string> &v)
  {
    for (string s : v)
    {
      cout << "The value is: " << s << endl;
    }
    cout << "---" << endl;
  }

  vector<string> get_strings()
  {
     vector<string> result;
     result.push_back("hello world!");
     return result;
  }
}
