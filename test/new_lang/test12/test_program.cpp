#include <vector>
#include <iostream>
using namespace std;

#include <splashkit.h>

int main()
{
  vector<string> data;

  data = get_strings();

  for(string s : data)
  {
      std::cout << s << std::endl;
  }

  
}
