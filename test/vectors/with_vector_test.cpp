#include "with_vector.h"

// using namespace splashkit;

int main()
{
  for (size_t i = 0; i < 100000; i++) {
    std::string str = print_string("Hello World");
  }

  std::vector<string> v;
  // v.push_back(str);
  v.push_back("-----");
  v.push_back("Hello");
  v.push_back("World");
  v.push_back("-----");

  print_string_list(v, 10);

  std::vector<float> nums;

  nums = get_number_list(100);

  for (size_t i = 0; i < 100000; i++) {
    print_float_list(nums);
  }

  return 0;
}
