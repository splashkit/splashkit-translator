# Splashkit API Parser

Converts Splashkit API documentation into YAML and then anything else...

## Running

Ensure you have doxygen installed. For macOS using Homebrew:

```bash
$ brew cask doxygen
```

or on Linux:

```
$ sudo apt-get install doxygen
```

Then install dependencies and run using `parse.rb` in the root folder.

```bash
$ bundle install
$ ./parse.rb /path/to/splashkit/coresdk/src/coresdk
```
