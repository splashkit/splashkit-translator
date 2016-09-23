#include "with_vector.h"

#include <iostream>
using namespace std;

namespace splashkit_lib
{
  string print_string(const string &message)
  {
    cout << message;
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
    cout << ".";
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

  vector<string> get_messages()
  {
      vector<string> result;
      result.push_back("Hello World!");
      return result;
  }

  void update_strings(vector<string> &strings)
  {
      strings.push_back("More Messages!");
  }

  void test_multiple_vectors(const vector<int> &ivec, const vector<string> &svec, const vector<float> &fvec)
  {

  }

  void show_me(unsigned short test)
  {

  }
}
