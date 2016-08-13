#include <stdlib.h>
#include <string>
#include "splashkit.h"

//== Type conversions ==
[Generators::SKLibC.include_types_template]

//== Strings ==
[Generators::SKLibC.include_strings_template]

//== SK Types ==
[Generators::SKLibC.declare_type_converters]

//== Forward Declare Functions ==
[Generators::SKLibC.forward_declare_sk_lib]

//== Define Implementations ==
[Generators::SKLibC.implement_sk_lib]
