#!/bin/sh

LANG_TEST=$1
echo "Generate adapter"
../../translate --generate clib,pascal,cpp,python,csharp,rust -i "test${LANG_TEST}/new_lang.h" --output ../out -l

echo "Make dynamic library"
# clang++ -arch i386 -shared -g -DBUILDING_SK_LIB -std=c++14 -I "test${LANG_TEST}" "test${LANG_TEST}/new_lang.cpp" ../out/clib/sk_clib.cpp ../out/clib/lib_type_mapper.cpp -I../clib -I../.. -I. -o libSplashKit-i386.dylib -install_name @rpath/libSplashKit.dylib

# clang++ -arch x86_64 -shared -g -DBUILDING_SK_LIB -std=c++14 -I "test${LANG_TEST}" "test${LANG_TEST}/new_lang.cpp" ../out/clib/sk_clib.cpp ../out/clib/lib_type_mapper.cpp -I../clib -I../.. -I. -o libSplashKit-x64.dylib -install_name @rpath/libSplashKit.dylib

# lipo -create libSplashKit-i386.dylib libSplashKit-x64.dylib -output libSplashKit.dylib

clang++ -arch x86_64 -shared -g -DBUILDING_SK_LIB -std=c++14 -I "test${LANG_TEST}" "test${LANG_TEST}/new_lang.cpp" ../out/clib/sk_clib.cpp ../out/clib/lib_type_mapper.cpp -I../clib -I../.. -I. -o libSplashKit.dylib -install_name @rpath/libSplashKit.dylib


function run_cpp
{
  echo "Compile C++ program"
  clang++ -g -std=c++14 ../out/cpp/*.cpp test${LANG_TEST}/test_program.cpp -L. -lSplashKit -I../out/clib -I../out/cpp -Wl,-rpath,@loader_path -o cpp_test${LANG_TEST}
  ./cpp_test${LANG_TEST}
}

echo "Do you wish to run the C++ version?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) run_cpp; break;;
        No ) break;;
    esac
done

function run_csharp
{
  echo "Compile CSharp program"
  mcs ../out/csharp/*.cs test${LANG_TEST}/TestProgram.cs -out:TestProgram.exe
  mono ./TestProgram.exe
}

echo "Do you wish to run the CSharp version?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) run_csharp; break;;
        No ) break;;
    esac
done

function run_pascal
{
  echo "Compile Pascal program"
  ppcx64 -g -FE. -Fu../out/pascal -S2 test${LANG_TEST}/TestProgram.pas -k-L. -k-lSplashKit -k"-rpath @loader_path"
  ./TestProgram
}

echo "Do you wish to run the Pascal version?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) run_pascal; break;;
        No ) break;;
    esac
done

function run_python
{
  cp "test${LANG_TEST}/test_program.py" .
  echo "Running Python program"
  export PYTHONPATH=../out/python
  python3 test_program.py
}

echo "Do you wish to run the Python version?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) run_python; break;;
        No ) break;;
    esac
done

function run_rust
{
  cp "test${LANG_TEST}/test_program.rs" .
  echo "Running Rust program"
  rustc -C link-args="-L . -Wl,-rpath,@loader_path" ./test${LANG_TEST}/test_program.rs
  ./test_program
}

echo "Do you wish to run the Rust version?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) run_rust; break;;
        No ) break;;
    esac
done
