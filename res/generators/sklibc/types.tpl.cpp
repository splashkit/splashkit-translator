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
