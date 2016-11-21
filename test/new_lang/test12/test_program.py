from splashkit import *

input("Press enter to start...")

for i in range(0,10000):
    s = get_strings()
    print_strings(s)
    add_string(s, 'Yay')
    print_strings(s)

input("Waiting for enter to be pressed: ")
