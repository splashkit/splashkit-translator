#include <stdio.h>
#include <stdlib.h>
#include <string>

//===
// Simulated SplashKit Input Library Code
//===
// audio.cpp
struct _sound_data
{
  // whatever...
};
// audio.h
typedef struct _sound_data *sound_effect;
sound_effect sound_effect_named(std::string name)
{
  // whatever...
  return NULL;
}
void play_sound_effect(sound_effect effect, int times, float volume)
{
  // whatever...
  printf("Honk!\n");
}
std::string name_of_sound_effect(sound_effect effect)
{
  // whatever...
  return "foo";
}

//===
// libgen_c.h
//===

//== Includes ==

#include <stdlib.h>
#include <string>
// #include "splashkit.h"

//== Type conversions ==
#define ptr void *
#define __to_ptr(value)\
(ptr)value
#define __to_bool(value)\
value == 1 ? true : false
#define __no_type_change(type)\
type __to_##type(type value) { return value; }
#define __sk_type_casting(type)\
type __to_##type(ptr value) { return static_cast<type>(value); }
#define __array_wrappable(type)\
typedef struct { type *data; } __sklib_##type##_array;

__no_type_change(int)
__no_type_change(float)
__no_type_change(double)
__no_type_change(long)
__no_type_change(short)

//== Strings ==
typedef struct { char *string; int size; } __sklib_string;
__sklib_string __to_sklib_string(std::string s)
{
  __sklib_string result;
  result.size = s.length();
  result.string = (char *)malloc(result.size + 1);
  strcpy(result.string, s.c_str());
  return result;
}
void __sklib_free_sklib_string(__sklib_string s)
{
  free(s.string);
}
std::string __to_string(__sklib_string s)
{
  return std::string(s.string);
}

//== Forward Declare Functions ==
// TODO: Get ruby to geneate and map (see below) the signatures for the .cpp
// file

extern "C" ptr __sklib_sound_effect_named__std_string(__sklib_string name);
extern "C" void __sklib_play_sound_effect__sound_effect__int__float(ptr effect, int loops, float vol);
extern "C" __sklib_string __sklib_name_of_sound_effect__sound_effect(ptr effect);

//== SK Types ==
// TODO: Get ruby to generate and append these as needed to get the types right
__sk_type_casting(sound_effect) // allow static_cast from ptr -> sound_effect
__array_wrappable(sound_effect) // allow wrapping the array in a struct

//===
// libgen_c.cpp
//===

// TODO: For the generated signatures, we must get ruby to map:
// * map in the signature { int, float, struct } -> { int, float, struct }
// * map in the signature std::string -> __sklib_string
//   in the code, we must use the following to map:
//     1. std::string    -> __sklib_string == __to_sklib_string(s)
//     2. __sklib_string -> std::string    == __to_string(s)
//   in the code, we don't need to map them across
// * map in the signature bool -> int
//   in the code, we must use the following to map:
//     1. bool -> int  == __to_bool(i)
//     2. int  -> bool == we don't? just return the int
// * map in the signature any custom SK type -> ptr
//     1. sk_type -> ptr == ???
//     2. ptr -> sk_type == __to_sk_type(ptr)
//   (BUT... must ensure that __sk_type_casting(sk_type)
//    has been called in libgen_c.h (otherwise __to_sk_type(ptr) doesn't
//    exist yet)!!!)

ptr __sklib_sound_effect_named__std_string(__sklib_string name)
{
  sound_effect __sklib_return_value = sound_effect_named(__to_string(name));
  return __to_ptr(__sklib_return_value);
}

void __sklib_play_sound_effect__sound_effect__int__float(ptr effect, int loops, float vol)
{
  play_sound_effect(__to_sound_effect(effect), __to_int(loops), __to_float(vol));
}

__sklib_string __sklib_name_of_sound_effect__sound_effect(ptr effect)
{
  std::string __sklib_return_value = name_of_sound_effect(__to_sound_effect(effect));
  return __to_sklib_string(__sklib_return_value);
}

//===
// Test...
//===

#include <stdio.h>
int main(int argc, char const *argv[]) {
  // these types can be generated using __array_wrappable(sk_type)
  __sklib_sound_effect_array x;

  // original code...
  printf("play_sound_effect: ");
  sound_effect se_original_type;
  play_sound_effect(se_original_type, 0, 0);
  // lib code...
  void* se_some_converted_type;
  printf("__sklib_play_sound_effect__sound_effect__int__float: ");
  __sklib_play_sound_effect__sound_effect__int__float(se_some_converted_type, 0, 0);

  return 0;
}
