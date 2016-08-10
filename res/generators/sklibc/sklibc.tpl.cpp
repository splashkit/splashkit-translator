//== Type conversions ==
#define ptr void *
#define __to_ptr(value)\
(ptr)value
#define __to_bool(value)\
value == 1 ? true : false
#define __no_type_change(type)\
type __to_##type(type value) { return value; }
#define __sk_type_casting(type)\
type __to_##type(ptr value) { return static_cast<type>(value); }
#define __array_wrappable(type)\
typedef struct { type *data; int size; } __sklib_##type##_array;

__no_type_change(int)
__no_type_change(float)
__no_type_change(double)

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
std::string __to_string(__sklib_string s)
{
    return std::string(s.string);
}

//== SK Types ==
[Generators::SKLibC.define_sk_types]

//== Forward Declare Functions ==
[Generators::SKLibC.forward_declare_sk_lib]

//== Define Implementations ==
[Generators::SKLibC.implement_sk_lib]
