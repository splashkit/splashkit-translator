from splashkit import *

i = c_int(10)
f = c_float(1.11)
d = c_double(2.22)
sh = c_short(-3)
ush = c_ushort(4)
l = c_long(5)
ch = c_char(b'a')
uch = c_ubyte(ord('B'))
b = c_bool(True)
ui = c_uint(50)

print(i)
print(" get ", get_and_update_int(i), " updated int ", i)

print(i, end=" ")
update_int(i)
print("Updated int: ", i)

print(ui, end=" ")
update_uint(ui)
print("Updated uint: ", ui)

print(sh, end=" ")
update_short(sh)
print("Updated short int: ", sh)

print(ush, end=" ")
update_ushort(ush)
print("Updated short int: ", ush)

print(f, end=" ")
update_float(f)
print("Updated float: ", f)

print(d, end=" ")
update_double(d)
print("Updated double: ", d)

print(l, end=" ")
update_long(l)
print("Updated long: ", l)

print(ch, end=" ")
update_char(ch)
print("Updated char: ", ch)

print(uch, end=" ")
update_uchar(uch)
print("Updated char: ", uch)

print(b, end=" ")
update_bool(b)
print("Updated bool: ", b)
