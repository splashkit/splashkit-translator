# TODO:

- [x] Add `@attribute static [class]` - this is a static method to the class
      provided

- [x] Apply anything in header to all docblocks in that file, unless an
     `@attribute` with the same name is explicitly added in a specific docblock
     (if so, it overrides the attributes in the header).

- [x] Getters and setters can only have one|two parameter(s)

- [x] ~~Getters and setters that are not `true' means to make the getter or setter
      name as that name.~~

- [x] Move automatic unique name generator back to internal (move it back to
      sklib.rb)

- [ ] Don't worry about unique name check for now!

- [ ] Print a report of errors at the end of parsing

- [x] Use `<definition>` for typealiases and use it for function pointers
