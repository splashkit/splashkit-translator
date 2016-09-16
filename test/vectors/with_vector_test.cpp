#include "with_vector.h"

#include <iostream>

// using namespace splashkit;

int main()
{
  string s;

  std:vector<int> vals;
  vals.push_back(1);
  vals.push_back(2);
  vals.push_back(3);

  std::cout << "Update 1,2,3" << std::endl;
  update_numbers(vals);

  for (int i : vals )
  {
    std::cout << i << std::endl;
  }

  std::cout << std::endl << "Enter string to cont.";
  std::cin >> s;

  for (size_t i = 0; i < 100000; i++) {
    std::string str = print_string("Hello ");
  }

  std::vector<string> v;
  // v.push_back(str);
  v.push_back("-----");
  v.push_back("Hello");
  v.push_back("World");
  v.push_back("-----");

  print_string_list(v, 10);

  std::cout << std::endl << "Enter string to cont.";
  std::cin >> s;

  std::vector<float> nums;

  nums = get_number_list(100);

  for (size_t i = 0; i < 100000; i++) {
    print_float_list(nums);
  }

  std::cout << std::endl << "Enter string to cont.";
  std::cin >> s;

  return 0;
}
