#include "new_lang.h"

#include <iostream>
using namespace std;

namespace splashkit_lib
{
    struct a_struct {
      int value;
    };

    void update_struct(struct_ptr v)
    {
       v->value = 0;
    }

    void print_struct(struct_ptr v)
    {
      cout << "The value is: " << v->value << endl;
    }

    struct_ptr get_struct()
    {
       a_struct *result = (a_struct*)malloc(sizeof(a_struct));
       result->value = 30;
       return result;
    }
}
