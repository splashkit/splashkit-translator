#!/bin/sh
echo "Generate adapter"
rm -rf ../out
../../translate --generate clib,pascal -i new_lang1.h --output ../out

echo "Make static library"
# clang++ -DBUILDING_SK_LIB -std=c++14 -c new_lang1.cpp ../out/clib/sk_clib.cpp ../out/clib/lib_type_mapper.cpp -I../clib -I../.. -I.
# libtool -static -o libSplashKitBackend.a new_lang1.o lib_type_mapper.o sk_clib.o

clang++ -shared -g -DBUILDING_SK_LIB -std=c++14 new_lang1.cpp ../out/clib/sk_clib.cpp ../out/clib/lib_type_mapper.cpp -I../clib -I../.. -I. -o libSplashKit.dylib

# echo "Make dynamic library"
# clang++ -DBUILDING_SK_ADAPTER -std=c++14 -shared -g ../out/cpp/splashkit.cpp -I../out/clib -I../out/cpp -L. -lSplashKitBackend -o libSplashKit.dylib -Wl,-install_name,'@rpath/libSplashKit.dylib'

echo "Compile program"
# mv with_vector.h with_vector.h.old
# clang++ -g -std=c++14 with_vector_test.cpp -L. -lSplashKit -I../out/cpp -Wl,-rpath,@loader_path
# mv with_vector.h.old with_vector.h

ppcx64 -S2 TestProgram.pas -k-L. -k-lSplashKit
