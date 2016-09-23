#include <vector>
#include <string>
using namespace std;

namespace splashkit_lib
{
  /**
   * description.
   *
   * @param message message
   * @returns message
   */
  string print_string(const string &message);

  /**
   * Adds an array of `json` object values to the `json` object for
   * the given `string` key.
   *
   * @param j List to print
   * @param x An int
   */
  void print_string_list(const vector<string> &j, int x);

  /**
   * Prints values from the list.
   *
   * @param j The list
   */
  void print_float_list(const vector<float> &j);


  /**
   * Adds an array of `json` object values to the `json` object for
   * the given `string` key.
   *
   * @param count The number of values
   *
   * @returns Values 1 to count in a vector
   */
  vector<float> get_number_list(int count);

  /**
   * Update the passed in values..
   *
   * @param nums The values passed both in and out...
   */
  void update_numbers(vector<int> &nums);

  /**
   * Test multiple types of vectors...
   *
   * @param ivec [description]
   * @param svec [description]
   * @param fvec [description]
   */
  void test_multiple_vectors(const vector<int> &ivec, const vector<string> &svec, const vector<float> &fvec);

  /**
   * [show_me description]
   * @param test [description]
   */
  void show_me(unsigned short test);

  /**
   * [update_strings description]
   * @param strings [description]
   */
  void update_strings(vector<string> &strings);

  /**
   * @return An array of strings
   */
  vector<string> get_messages();
}
