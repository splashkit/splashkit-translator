# Creating a new language adapter

Locate the `test/new_lang` folder in the splashkit-translator project. This includes a number of iterative projects that can be used to stage the implementation of a new language adapter.

## Test 1

To get started, the first test creates a `say_yay` procedure with no parameters. This is designed to test that you can load the library and call a simple procedure.

Steps:
1. Edit the `exec.sh` script to add exporting of your language, and any other required steps.
1. Create a new translator in `src/translators`
1. Create a new folder for your translator templates in `res/translators`
1. Add a render template function to your translator. This will render the template from your resources folder. eg:
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
  variables:  :snake_case
}
```
1. In your templates we recommend two folders: one for the templates related to the sk library (clib) and the other for the user/programmer facing code from your template. For example, in Python we used `ctypes` which maps the clib functions from splashkit, and `implementation` for the templates to create the python code used by the user/programmer.
1. 
