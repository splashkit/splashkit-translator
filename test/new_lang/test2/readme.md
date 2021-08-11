# Adding parameters and primitive data types

Now that you can call a basic procedure, the next step is to add parameters and translation of basic data types. This is a relatively big step as you will need to put in place the data type mapping functions and templates.

1. Create the basic test program, copy one of the other programs and adjust the syntax. This will test passing in the following parameter types: `int`, `uint`, `short`, `ushort`, `float`, `double`, `long`, `char`, `uchar`, and `bool`.
1. In your language mapping file you need to add 3 maps: `DIRECT_TYPES`, `SK_TYPES_TO_LIB_TYPES`, and `SK_TYPES_TO_"LANG"_TYPES` (replace "LANG" with your language class name - eg `SK_TYPES_TO_RUST_TYPES`). These map a source type from the C/C++ base library to and from the target language.

    - `DIRECT_TYPES` should only include types that require no translation between languages. For example, the C/C++ `int` we use can map to `i32` in Rust without needing any changes.

    The other two maps are used for translation for types that need mapping.
    - `SK_TYPES_TO_LIB_TYPES` provides the type name mapping for these types in the code that interfaces with the C/C++ core library. For example, `char` parameters in the library code will need to be `i8` in the Rust code.
    - `SK_TYPES_TO_"LANG"_TYPES` compliments the `SK_TYPES_TO_LIB_TYPES` to indicate the type within the language itself. So `char` will be `char` in rust (from `SK_TYPES_TO_"LANG"_TYPES`), and that will need to be mapped to `i8` (from `SK_TYPES_TO_LIB_TYPES`).

1. While you are in the language file, update the `signature_syntax` function to include the parameter list. The type mappers will take care of the types for the parameters, so you just need to include it within the signature. Eg:

    ```[ruby]
    def signature_syntax(function, function_name, parameter_list, return_type, opts = {})
      "fn #{function_name}(#{parameter_list})"
    end
    ```

1. Also add a blank `type_exceptions` function. These allow you to custom map certain types, and will come into play later. With these changes you should be able to generate appropriate signatures for the library and adapter code.

    ```[ruby]
    def type_exceptions(type_data, type_conversion_fn, opts = {})
      # No exception for this type
      return nil
    end
    ```

1. Next we need to update the function template, and include mapping functions. Each parameter is first mapped locally to a local variable in the adapter, then passed to the library. This allows any translation to occur.
1. Update the code used to generate an adapter function to convert and pass arguments for each parameter:


    - Use `lib_argument_list_for` to generate the argument list to pass to the function call, and create a template of the function call itself.
    - Loop for each parameter and declare a new local `__skparam__<%= param_name %>` variable that is assigned the result of calling the `lib_mapper_fn_for` the `param_data`. This will map from the language type to the library type (eg bool goes to int to pass to the library).

    See the following example from Rust.

    ```[ruby]
    <%
      @functions.each do |function|
      lib_fn_name = lib_function_name_for(function)
      param_list  = lib_argument_list_for(function)
      func_call   = "#{lib_fn_name}(#{param_list})"
    %>
    pub <%= sk_signature_for(function) %> {
    <%
      # Declare each parameter prefixed with __skparam__
      function[:parameters].each do |param_name, param_data|
    %>
      let __skparam__<%= param_name %>: <%= lib_type_for(param_data) %> = <%= lib_mapper_fn_for param_data %>(<%= param_name.variable_case %>);
    <%
      end # end parameters.each
    %>
      unsafe {
        <%= func_call %>;
      }
    }
    ```

1. Once you have this you now need to create the mapping functions. 
   1. Add in a `<%= read_template 'implementation/mappers' %>` or similar to read in a template that will generate these mappers.
   1. Create the mappers.lang.erb file and have it read templates for the direct types, and the custom mapped types (eg char and bool). Eg:

    ```[erb]
    <%= read_template 'implementation/mappers/bool' %>
    <%= read_template 'implementation/mappers/char' %>
    <%= read_template 'implementation/mappers/direct' %>
    ```

   1. In these mapping files you need to implement 2 functions for each type:

    - __skadapter__to_sklib_"TYPE" - takes the mapped type and returns the library type. eg. from bool to i32.
    - __skadapter__to_"TYPE" - takes the library type and returns the language type. eg. from i32 to bool.

    With these two functions you can map data in both directions - language to and from the library type. For example:

    ```[erb]
    fn __skadapter__to_sklib_bool(v: bool) -> i32
    {
      if v {
        return -1;
      } else {
        return 0;
      }
    }

    fn __skadapter__to_bool(v: i32) -> bool
    {
      return v != 0;
    }
    ```

    In the direct types you should be able to implement this using a loop as there is no need to do any data transformation for these types.

   1. Run `exec.sh 2` to test your new library code. You should see outputs for each type based on what you passed in as parameters.

