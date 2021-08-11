# Getting things linking

1. Run `exec.sh 1` to build the dylib. Skip executing... just get the lib.
1. Manually get the new language to call the dylib. Use this to determine what you need to do to get this linking. Make sure this compiles and runs.

## Starting the translator

1. Edit the `exec.sh` script to add exporting of your language, and any other required steps. (Copy Paste)

2. Make the basic test program in your new language that will call the `SayYay` procedure in the core library. When this runs it will output yay to the terminal.

3. Create a new translator in `src/translators` - copy `starter.rb` for the minimal outline.

4. Create a new folder for your translator templates in `res/translators`

     - Add to require relative in `main.rb`
     - Add to language list in `exec.sh`

5. Update the render template function in your translator. This will render the template from your resources folder. eg:

    ```[ruby]
    def render_templates
      {
        'splashkit.py' => read_template('splashkit.py')
      }
    end
    ```

6. Indicate the coding convention in the identifiers case constant (start with the name of your translator):

    ```[ruby]
    PYTHON_IDENTIFIER_CASES = {
      types:      :pascal_case,
      functions:  :snake_case,
      variables:  :snake_case,
      constants:  :snake_case
    }
    ```

7. Create the render template. This needs to map to the clib version, and provide a user API in the mapped language. For the moment, this just needs to map the function name -- no data, no parameters, no return data, etc.

8. Run `exec.sh 1` and review the resulting mapping code in the `test/out` folder. Test and get it working.
