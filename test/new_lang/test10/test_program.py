from splashkit import *

a1 = Array1D()
a2 = Array2D()

a1.values[0] = 0
a1.values[1] = 10
print('Updating a1.values[1] from: ', a1.values[1])

update_1d(a1)
print('It is now: ', a1.values[1])

a2.values[0,0] = 0
a2.values[1,2] = 30
print('Updating a2.values[1][2] from: ', a2.values[1, 2])

update_2d(a2)
print('It is now: ', a2.values[1, 2])
