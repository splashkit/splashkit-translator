//== Includes ==
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include "splashkit.h"

//== Type conversions ==
#define ptr void *
#define __to_bool(value)\
value == 1 ? true : false
#define __no_type_change(value)\
value
#define __sk_type_casting(type)\
type __to_##type(ptr value) { return static_cast<type>(value); }
#define __array_wrappable(type)\
typedef struct { type *data; } __sklib_##type##_array;

//== Strings ==
typedef struct { char *string; int size; } __sklib_string;
__sklib_string __to_sklib_string(std::string s)
{
  __sklib_string result;
  result.size = s.length();
  result.string = (char *)malloc(result.size + 1);
  strcpy(result.string, s.c_str());
  return result;
}
void __sklib_free_sklib_string(__sklib_string s)
{
  free(s.string);
}
std::string __to_std_string(__sklib_string s)
{
  return std::string(s.string);
}

//== SK Types ==
[Generators::SKLibC.define_sk_types]

//== Forward Declare Functions ==
[Generators::SKLibC.forward_declare_sk_lib]

//== Define Implementations ==
[Generators::SKLibC.implement_sk_lib]
