#!/bin/sh
echo "Generate adapter"
rm -rf ../out
../../translate --generate clib,cpp -i with_vector.h --output ../out

echo "Make static library"
clang++ -DBUILDING_SK_LIB -std=c++14 -c with_vector.cpp ../out/clib/sk_clib.cpp -I../clib -I../..
libtool -static -o libSplashKitBackend.a with_vector.o sk_clib.o

echo "Make dynamic library"
clang++ -DBUILDING_SK_ADAPTER -std=c++14 -shared -g ../out/cpp/splashkit.cpp -I../out/clib -I../out/cpp -L. -lSplashKitBackend -o libSplashKit.dylib -Wl,-install_name,'@rpath/libSplashKit.dylib'

echo "Compile program"
mv with_vector.h with_vector.h.old
clang++ -g -std=c++14 with_vector_test.cpp -L. -lSplashKit -I../out/cpp -Wl,-rpath,@loader_path
mv with_vector.h.old with_vector.h
