from splashkit import *


s_ptr = get_struct()
print_struct(s_ptr)
print('Calling update func!')
update_struct(s_ptr)
print_struct(s_ptr)
