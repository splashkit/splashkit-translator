The existing SwinGame exporter reads Pascal files and creates an object model that is translated into the different programming languages. This needs to be changed in several ways...

1. This needs to read the new C/C++ code -- change the parser the use C/C++ syntax.
1. The object model should just be saved to YAML
1. Language translators can then be created to read the YAML and generate code


For this to work, the YAML needs to capture the code structure and comments.
