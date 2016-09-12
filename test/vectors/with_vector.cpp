#include "with_vector.h"

#include <iostream>
using namespace std;

namespace splashkit_lib
{
  void print_string_list(vector<string> j, int x)
  {
    for(string s : j)
    {
      cout << s << " " << x << endl;
    }
    cout << "end" << endl << endl;
  }

  /**
   * Prints values from the list.
   *
   * @param j The list
   */
  void print_float_list(vector<float> j)
  {
    for(float s : j)
    {
      cout << s << endl;
    }
    cout << "end" << endl << endl;
  }


  /**
   * Adds an array of `json` object values to the `json` object for
   * the given `string` key.
   *
   * @param count The number of values
   * @returns Values 1 to count in a vector
   */
  vector<float> get_number_list(int count)
  {
    std::vector<float> v;
    for (size_t i = 0; i < count; i++)
    {
      v.push_back(i * 1.0f + i * 0.1f);
    }

    return v;
  }
}
