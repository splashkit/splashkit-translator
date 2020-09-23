#include "new_lang.h"

#include <iostream>
using namespace std;

namespace splashkit_lib
{
    struct a_struct
    {
      bool deleted;
      int value;
    };

    test_struct get_test_struct()
    {
      return { 10 };
    }

    int to_int(const test_struct &s)
    {
      return s.x;
    }

    void update_struct(struct_ptr v)
    {
       v->value -= 30;
    }

    void update_struct(struct_ptr v, int value)
    {
      v->value = value;
    }

    void update_struct(int value, struct_ptr v)
    {
      v->value = value;
    }

    void print_struct(struct_ptr v)
    {
      cout << "The value is: " << v->value << endl;
    }

    void set_data(struct_ptr v, int value)
    {}

    struct_ptr get_struct()
    {
       a_struct *result = (a_struct*)malloc(sizeof(a_struct));
       result->value = 30;
       result->deleted = false;
       return result;
    }

    int struct_ptr_get_value(struct_ptr v)
    {
      return v->value;
    }

    void struct_ptr_set_value(struct_ptr v, int data)
    {
      v->value = data;
    }

    vector<int> get_list_from_struct_ptr(struct_ptr v)
    {
      vector<int> result;
      result.push_back(v->value);
      result.push_back(v->value);
      result.push_back(v->value);
      return result;
    }

    static free_notifier *_free_notifier = nullptr;

    void register_free_notifier(free_notifier *fn)
    {
      _free_notifier = fn;
    }

    void delete_struct_ptr(struct_ptr v)
    {
      if(_free_notifier != nullptr)
        _free_notifier(v);
      v->deleted = true;
      free(v);
    }

    void deregister_free_notifier(free_notifier *handler)
    {
      _free_notifier = nullptr;
    }

    static int value = 999;

    int get_value()
    {
      return value;
    }

    void set_value(int val)
    {
      value = val;
    }

    /**
     * @static test_static
     * @method print
     */
    void print_value()
    {
      cout << value << endl;
    }
}
