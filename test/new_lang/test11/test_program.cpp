#include <vector>
#include <iostream>
using namespace std;

#include <splashkit.h>

int main()
{
  string s;

  s = get_string();
  print_string(s);
  s = "Now its this";
  print_string(s);
}
