from splashkit import *

print("About to say yay")
say_yay()

print("About to say yay int 1")
say_yay_int(1)

print("About to say yay int -1")
say_yay_int(-1)

print("About to say yay int 987654321")
say_yay_int(987654321)

print("About to say yay float 1.0")
say_yay_float(1.0)

print("About to say yay float -1.0")
say_yay_float(-1.0)

print("About to say yay float 0.00001")
say_yay_float(0.00001)

print("About to say yay double 0.00001")
say_yay_double(0.00001)

print("About to say yay char 'A'")
say_yay_char("A")

print("About to say yay char 'Z'")
say_yay_char("Z")

print("About to say yay char '11'")
try:
    say_yay_char("11")
except Exception as e:
    print(e)


print("About to say yay bool true")
say_yay_bool(True)

print("About to say yay bool false")
say_yay_bool(False)

print("About to say yay short 999")
say_yay_short(999)

print("About to say yay short 999999")
say_yay_short(999999)

print("About to say yay long 999999")
say_yay_long(999999)

print("About to say yay uint 999999")
say_yay_uint(999999)

print("About to say yay uint -1")
say_yay_uint(-1)

print("About to say yay ushort -1")
say_yay_ushort(-1)

print("About to say yay uchar 'B'")
say_yay_uchar('B')


print("Done!")
