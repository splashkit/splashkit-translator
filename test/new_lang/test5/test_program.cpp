#include <vector>
#include <iostream>
using namespace std;

#include <splashkit.h>

int main()
{
  vector<bool> arr;

  arr = get_bools();
  print_all(arr);
  cout << "Adding false" << endl;
  add_bool(arr, false);
  print_all(arr);
}
