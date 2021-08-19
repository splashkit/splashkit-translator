# Returning data from functions

With basic procedure calls and basic parameters taken care of the next step is to start getting data back from the library. In this step we add return values to functions.

1. Create a new test program file and mimic code in the other languages. This will call functions that return each data type and then output the results returned.
1. Start in the language adapter with the `signature_syntax` to add the return type (if it is a function).
   
    ```[ruby]
    def signature_syntax(function, function_name, parameter_list, return_type, opts = {})
      func_suffix = " -> #{return_type}" if is_func?(function)
      "fn #{function_name}(#{parameter_list})#{func_suffix}"
    end
    ```

1. If the language does not support function overloading then you need to override sk_function_name_for to return the details including the function suffix. For example:

    ```[ruby]
    def sk_function_name_for(function)
      "#{function[:name].function_case}#{function[:attributes][:suffix].nil? ? '':'_'}#{function[:attributes][:suffix]}"
    end
    ```

2. Update the splashkit adapter template:

   1. Add a local variable to collect the function return value, and optionally assign the response to this variable. For example:

    ```[ruby]
    <%
        # if it is a function... then add a mutable return variable
        if is_func?(function)
    %>
      let mut __skreturn: <%= sk_type_for(function[:return], is_lib: true) %>;
    <%
        end # end if func
    %>
    ```

   2. Call the function and assign the response to the new variable.

    ```[ruby]
        lib_fn_name = lib_function_name_for(function)
        param_list  = lib_argument_list_for(function)
        return_val  = "__skreturn = " if is_func?(function)
        func_call   = "#{return_val}#{lib_fn_name}(#{param_list})"
    ```

   3. Return the mapped value of the type to the caller.

    ```[ruby]
    <%
        if is_func?(function)
    %>
      return <%= sk_mapper_fn_for function[:return] %>(__skreturn);
    <%
        end # end if function
    %>
    ```
