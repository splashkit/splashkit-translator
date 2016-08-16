#define __skadapter__to_sklib_bool(value)\
value == true ? 1 : 0
#define __skadapter__to_bool(value)\
value == 1 ? true : false

#define __skadapter__make_direct_adapter(type)\
type __skadapter__to_sklib_##type(type value) { return value; }\
type __skadapter__to_##type(type value) { return value; }
__skadapter__make_direct_adapter(int)
__skadapter__make_direct_adapter(float)
__skadapter__make_direct_adapter(double)

#define __sklib_ptr void *
#define __skadapter__make_typealias_adapter(type)\
__sklib_ptr __skadapter__to_sklib_##type(type value) { return static_cast<__sklib_ptr>(value); }\
type __skadapter__to_##type(__sklib_ptr value) { return static_cast<type>(value); }

#define __skadapter__make_enum_adapter(type)\
int __skadapter__to_sklib_##type(type value) { return static_cast<int>(value); }\
type __skadapter__to_##type(int value) { return static_cast<type>(value); }
