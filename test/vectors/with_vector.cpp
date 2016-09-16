//
// Generate adapter
// ../../translate --generate clib,cpp -i with_vector.h --output ../out
//
// Make static library:
// clang++ -DBUILDING_SK_LIB -std=c++14 -c with_vector.cpp ../out/clib/sk_clib.cpp -I../clib -I../..
// libtool -static -o libSplashKitBackend.a with_vector.o sk_clib.o
//
// Make dynamic library
// clang++ -DBUILDING_SK_ADAPTER -std=c++14 -shared -g ../out/cpp/splashkit.cpp -I../out/clib -I../out/cpp -L. -lSplashKitBackend -o libSplashKit.dylib -Wl,-install_name,'@rpath/libSplashKit.dylib'
//
// Compile program
// mv with_vector.h with_vector.h.old
// clang++ -g -std=c++14 with_vector_test.cpp -L. -lSplashKit -I../out/cpp -Wl,-rpath,@loader_path
// mv with_vector.h.old with_vector.h
//
#include "with_vector.h"

#include <iostream>
using namespace std;

namespace splashkit_lib
{
  string print_string(const string &message)
  {
    cout << message << endl;
    return message;
  }

  void print_string_list(const vector<string> &j, int x)
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
  void print_float_list(const vector<float> &j)
  {
    for(float s : j)
    {
      // cout << s << endl;
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

  void update_numbers(vector<int> &nums)
  {
      int sum = 0;

      for(int i = 0; i < nums.size(); i++)
      {
          nums[i] *= 2;
          sum += nums[i];
      }

      nums.push_back(sum);
  }
}
