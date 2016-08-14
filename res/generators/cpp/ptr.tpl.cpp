#define ptr void *
#define __to_type(type, value)\
(type)value
#define __to_ptr(value)\
__to_type(ptr, value)
