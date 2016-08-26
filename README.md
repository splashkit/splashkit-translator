# SplashKit API Parser

Converts SplashKit API documentation into YAML and then anything else we want to generate...

# Contents

<!-- MDTOC maxdepth:4 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:0 -->

- [SplashKit API Parser](#splashkit-api-parser)
- [Contents](#contents)
- [Running](#running)
- [SplashKit Documentation Guidelines](#splashkit-documentation-guidelines)
   - [Header File Docblocks](#header-file-docblocks)
   - [Function Docblocks](#function-docblocks)
   - [Enum Docblocks](#enum-docblocks)
   - [Struct Docblocks](#struct-docblocks)
   - [Typedef Docblocks](#typedef-docblocks)
   - [Attributes](#attributes)
      - [`class`](#class)
         - [Usage in typedefs](#usage-in-typedefs)
         - [Usage in functions](#usage-in-functions)
      - [`method`](#method)
      - [`constructor`](#constructor)
      - [`destructor`](#destructor)
      - [`self`](#self)
      - [`unique`](#unique)

<!-- /MDTOC -->

# Running

## Dependencies

Ensure you have HeaderDoc installed:

- Under macOS, you will need to have Xcode with Developer Tools installed.
- Under Ubuntu, you can download HeaderDoc at Apple's OpenSource Developer Tools
  [here](http://opensource.apple.com/release/developer-tools-64/).

Install dependencies using `bundle`:

```bash
$ bundle install
```

Then run using `parse`.

## Validating

To validate a single file or files, supply the `--validate` or `-v` switch and
the `--input` or `-i` switch with the header file you wish to validate:

```bash
$ ./parse --validate --input /path/to/splashkit/coresdk/src/coresdk/audio.h
```

Alternatively, you can validate all header files by supplying just the
SplashKit `coresdk/src/coresdk` directory instead:

```bash
$ ./parse -v -i /path/to/splashkit/coresdk/src/coresdk
```

## Converting

To convert, follow the same as the above, removing the `--validate`/`-v` switch
and supplying the generators you would like to run using a comma-separated list
under the `--generate` or `-g` switch and specifiying the output directory using
the `--output` or `-o` switch:

```bash
$ ./parse -i /path/to/splashkit/coresdk/src/coresdk/audio.h -o ~/Desktop/audio -g YAML,SKLIBC,CPP
```

To see a full list of each generator available, use the `--help` switch.

# SplashKit Documentation Guidelines

SplashKit uses [HeaderDoc](https://en.wikipedia.org/wiki/HeaderDoc) to parse
documentation. A guide on HeaderDoc can be found [here](https://developer.apple.com/legacy/library/documentation/DeveloperTools/Conceptual/HeaderDoc/intro/intro.html#//apple_ref/doc/uid/TP40001215-CH345-SW1).

**Ensure that `snake_case` is consistently used throughout documentation.**

## Header File Docblocks

A header file should begin with a docblock consisting of:

1. `@header [name]` - The name of the 'module' of functions and types defined in
   the header. E.g., `audio.h` would be listed as `Audio`.
2. `@author [name]` - One or many author names who have contributed to the
   header and/or implementation
3. `@brief [description]` - A brief, one sentence description of what
   functionality is added in this 'module'.
4. A longer description of the functionality. The description accepts Markdown.

Example, `audio.h`:

```c
/**
 * @header Audio
 * @author Andrew Cain
 * @brief SplashKit Audio allows you to load and play music and sound effects.
 *
 * The SplashKit's audio library allows you to easily load and play music and
 * sound effects within your programs. To get started with audio the first
 * thing you need to do is load a sound effect or music file. You can do this
 * by calling the `load_sound_effect(string name)` function to the
 * `load_music(string name)` function.
 *
 * @attribute static audio
 */
```

Any attributes set in a header file docblock will apply those attributes to all
docblocks inside that file. In the example above, all docblocks will have
`@attribute static audio` added to them _unless_ `@attribute static` is already
listed in a docblock.

## Function Docblocks

A function docblock should consist of _at least_ a basic description of the
functionality provided by the function in Markdown. Where applicable, it also
must have:

* `@param [name] [description]` - The name and description of a parameter.
  These should be listed in order of the function's signature. **All parameters
  must be listed and be consistent with the correct name(s) in the signature.**
* `@returns [description]` - A basic description of what is returned from the
  function. **Any non-void function must have an `@returns`**.
* `@brief [description]` - A brief, one sentence description of what
  functionality is added in this function.

Each of the above should be separated with a newline and grouped together where
applicable.

Example, `load_sound_effect`:
```c
/**
 * @brief Loads and returns a sound effect.
 *
 * The supplied `filename` is used to locate the sound effect to load. The
 * supplied `name` indicates the name to use to refer to this `sound_effect`.
 * The `sound_effect` can then be retrieved by passing this `name` to
 * the `sound_effect_named` function.
 *
 * @param name      The name used to refer to the sound effect.
 * @param filename  The filename used to locate the sound effect to use.
 *
 * @returns A new `sound_effect` with the initialised values provided.
 */
sound_effect load_sound_effect(string name, string filename);
```

## Enum Docblocks

An enum docblock **must** define every one of its constants using the
`@constant` tag. For example:

```c
/**
 * Defines each of the five weekdays
 *
 * @constant Monday     The day where you want to go sleep
 * @constant Tuesday    The day where you start to get stuff done
 * @constant Wednesday  The day where you realise you're only midway through
 * @constant Thursday   The day where you can smell Friday coming
 * @constant Friday     The day where you party hard
 */
enum weekdays {
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday
};
```

## Struct Docblocks

A struct docblock must define each of its field members using a `@param` tag.
For example:

```c
/**
 * Defines basic details for a person
 *
 * @param name    The name of the person
 * @param age     The age of the person
 * @param friend  The person's bestest friend in the whole world
 */
struct person {
  string name,
  int age,
  person *friend
};
```

## Typedef Docblocks

A function docblock should consist of _at least_ a basic description of the
functionality provided by the function in Markdown.

## Attributes

Attributes provide options to the language translator. They are applicable to
functions and typedef docblocks. Attributes are declared as thus:

```c
/**
 * @attribute [key] [value]
 */
```

Here is a list of all accepted attribute keys:

### `class`

#### Usage in typedefs

When added to a typedef, the type will be declared as a class:

```c
/**
 * ...
 *
 * @attribute class sound_effect
 */
typedef struct _sound_data *sound_effect;
```

Note that typedef aliases to pointers **must** be declared with a `class` attribute.

#### Usage in functions

Associates the `sound_effect` type to an OO-translated SplashKit code class
_instance_.

When added to a function, the type will be associated to a class. You must
pair this with `method`, `constructor`, `destructor`, `getter`, or `setter`
attribute (see below) to define how the function will be associated to under
that class.

```c
/**
 * ...
 *
 * @attribute class  audio
 * @attribute method close
 */
void close_audio();
```

This will convert the above to an equivalent OO method:

```c
Audio.Close()
```

### `method`

Associates a function to a class. Requires the `class` or `static` attribute to
be set. The name specified by `method` will be the method name that will be used
as the method on the class. See the above example.

When `method` is used with the `class` attribute, an _instance method_ will be
generated on the class whose name is specified by `class`.

When `method` is used with the `static` attribute, a _static method_ will be
generated on the class whose name is specified by `class`.

### `constructor`

Associates a function as the constructor to a class. Requires the `class`
attribute to be set. To mark a constructor, simply set the value as `true`:

```c
/**
 * ...
 *
 * @attribute class       sound_effect
 * @attribute constructor true
 */
sound_effect load_sound_effect(string name, string filename);
```

This will convert the above to an equivalent OO constructor:

```c
SoundEffect(string name, string filename)
```

### `destructor`

Same as `constructor`, but for a destructor. Requires a `self` attribute to be
set (see below).

```c
/**
 * ...
 *
 * @attribute class       sound_effect
 * @attribute self        effect
 * @attribute destructor  true
 */
void delete_sound_effect(sound_effect effect);
```

This would call the `delete_sound_effect` on the instance, where the instance is
the `effect` parameter:

```cpp
delete someSoundEffectInstance;
```

### `self`

Specifies the name of the parameter which should act as `this` or `self` on the
function call. That is, when the function is converted to a method for an OO
language, the instance calling the method will be passed into the parameter
specified by `self`. For example:

```c
/**
 * ...
 *
 * @attribute class   sound_effect
 * @attribute method  play
 * @attribute self    effect
 */
void play_sound_effect(sound_effect effect, int times, float volume);
```

When translated into OO:

```cpp
someSoundEffectInstance.play(3, 10.0f)
```

will call

```c
play_sound_effect(someSoundEffectInstance, 3, 10.0f)
```

When using a `self` attribute, you must ensure that **the parameter named by
`self` has a type which matches the `class` attribute value**. For example, the
following will cause an error since `times` is an `int`, which does not match
the `class` attribute value of type `sound_effect`:

```c
/**
 * ...
 *
 * @attribute class   sound_effect    <-------------------------------
 * @attribute method  play                                             \
 * @attribute self    times           <--- times is an int, not a sound_effect!!
 */
void play_sound_effect(sound_effect effect, int times, float volume);
```

### `unique`

For translated languages that do not support overloaded function names, the
name specified by `unique` name will be used instead. For example:

```c
/**
 * ...
 *
 * @attribute class   sound_effect
 * @attribute method  play
 * @attribute unique  play_with_loops_and_volume
 * @attribute self    effect
 */
void play_sound_effect(sound_effect effect, int times, float volume);
```

will be translated into Python as:

```python
some_sound_effect_instance.play_with_loops_and_volume(3, 10.0)
```

whereas in C# it would look like:

```c#
someSoundEffectInstance.play(3, 10.0f)
```

### `getter`

Creates a getter method to the `class` specified. Requires `class` and `self`
to be set.

Must be set on a function that has __exactly__ one parameter. This parameter
must be the parameter which will be used as `self`.

For example, the following:

```c
/**
 * ...
 *
 * @attribute class   query_result
 * @attribute self    effect
 * @attribyte getter  is_empty
 */
bool query_result_empty(query_result result);
```

generates:

```c#
QueryResult myQueryResult = myDatabase.queryResult;
if (myQueryResult.isEmpty) { ... };
```

If the value specified by `getter` is `true`, the name will not change.
Otherwise the name will be set by the specified `getter` name:

```c
/**
 * ...
 *
 * @attribute class   query_result
 * @attribute self    effect
 * @attribyte getter  true
 */
bool has_data(query_result result);
```

generates:

```c#
QueryResult myQueryResult = myDatabase.queryResult;
if (myQueryResult.hasData) { ... };
```

### `setter`

Creates a setter method to the `class` specified. Requires `class` and `self`
to be set.

Must be set on a function that has __exactly__ two parameters:

1. the first must be the the parameter which will be used as `self`, and
2. the second must the value that is to be set

For example, the following:

```c
/**
 * ...
 *
 * @attribute class   database
 * @attribute self    effect
 * @attribyte setter  last_query
 */
void database_set_query_result(database db, query_result result);
```

generates:

```c#
myDatabase.lastQuery = myQueryResult;
```

If the value specified by `setter` is `true`, the name will not change.
Otherwise the name will be set by the specified `setter` name:

```c
/**
 * ...
 *
 * @attribute class   database
 * @attribute self    effect
 * @attribyte setter  true
 */
void flagged(database db, bool flag);
```

generates:

```c#
myDatabase.flagged = false;
```
