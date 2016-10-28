#!/bin/sh

LANG_TEST=$1
echo "Generate adapter"
../../translate --generate clib,pascal -i "test${LANG_TEST}/new_lang.h" --output ../out -l

echo "Make dynamic library"
clang++ -shared -g -DBUILDING_SK_LIB -std=c++14 -I "test${LANG_TEST}" "test${LANG_TEST}/new_lang.cpp" ../out/clib/sk_clib.cpp ../out/clib/lib_type_mapper.cpp -I../clib -I../.. -I. -o libSplashKit.dylib

echo "Compile program"
ppcx64 -g -FE. -Fu../out/pascal -S2 test${LANG_TEST}/TestProgram.pas -k-L. -k-lSplashKit
