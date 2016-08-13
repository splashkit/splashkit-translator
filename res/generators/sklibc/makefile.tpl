all:
	clang++ sklib.c -dynamiclib -I /*=include_dir*/ -o libSplashKit.1.dylib
