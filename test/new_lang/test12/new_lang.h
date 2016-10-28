/**
 * @header new_lang
 * @attribute group test
 */
#include <vector>
#include <string>
using namespace std;

namespace splashkit_lib
{
  /**
   * [add_string description]
   * @param v [description]
   * @param s [description]
   */
  void add_string(vector<string> &v, const string &s);

  /**
   * [print_strings description]
   * @param v [description]
   */
  void print_strings(const vector<string> &v);

  /**
   * @return foo
   */
  vector<string> get_strings();
}
