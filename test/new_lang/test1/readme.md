## Getting things linking

1. Run `exec.sh 1` to build the dylib. Skip executing... just get the lib.
1. Manually get the new language to call the dylib. Use this to determine what you need to do to get this linking. Make sure this compiles and runs.

### Starting the translator

1. Edit the `exec.sh` script to add exporting of your language, and any other required steps. (Copy Paste)

1. Create a new translator in `src/translators` - copy `starter.rb` for the minimal outline.

1. Create a new folder for your translator templates in `res/translators`
  - Add to require relative in `main.rb`
  - Add to language list in `exec.sh`

1. Update the render template function in your translator. This will render the template from your resources folder. eg:
```
def render_templates
  {
    'splashkit.py' => read_template('splashkit.py')
  }
end
```

1. Indicate the coding convention in the identifiers case constant (start with the name of your translator):
```
PYTHON_IDENTIFIER_CASES = {
  types:      :pascal_case,
  functions:  :snake_case,
  variables:  :snake_case,
  constants:  :snake_case
}
```

1. Create the render template. This needs to map to the clib version, and provide a user API in the mapped language. For the moment, this just needs to map the function name -- no data, no parameters, no return data, etc.

1. Run `exec.sh 1` and review the resulting mapping code in the `test/out` folder. Test and get it working.
