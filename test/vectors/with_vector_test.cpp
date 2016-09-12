#include "with_vector.h"

// using namespace splashkit;

int main()
{
  std::vector<string> v;
  v.push_back("-----");
  v.push_back("Hello");
  v.push_back("World");
  v.push_back("-----");

  print_string_list(v, 10);

  std::vector<float> nums;

  nums = get_number_list(100);

  print_float_list(nums);

  return 0;
}
