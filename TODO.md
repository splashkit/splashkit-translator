# TODO:

- [x] Switch to ERBs templates!

- [x] New rule to @attribute class for typedef aliases:
   - must be a pointer (isPointer) and have a class
   - otherwise throw an error

- [x] Enums use a `static_cast` to convert to and from `int` to their enum type

- [x] Structs must convert individually each field by mapping each field type
    and vice versa (omit __sklib_ at __sklib_person and add __sklib_ to person)

```cpp
  __sklib_person __skadapter__to_sklib_person(person p)
  {
    __sklib_person result;
    result.name     = __skadapter__to_sklib_string(p.name); // std::string -> sklib_string
    result.gender   = __skadapter__to_sklib_gender(p.gender); // gender -> sklib_gender
    result.address  = __skadapter__to_sklib_address(p.address); // address struct -> sklib_address
    return result;
  }
```

- [ ] Rename arrays to vectors

- [ ] Arrays must have:
   - `__skadapter__to_sklib_[type]_array`
   - `__skadapter__to_[type]_array`
   - `__skadapter__free_[type]_array`
   - i.e., follow principles of string

- [ ] Reject all `int[]` types - we only accept vectors!

- [ ] Adapter's must be written both ways for sklibc and {LANGUAGE}

```
          ( __skadapter__to_[type]       )->|             |<-( __skadapter__to_sklib_[type] )
    SKLIBC                                  |   ADAPTER   |                                   SWIFT, PYTHON etc.
          ( __skadapter__to_sklib_[type] )<-|             |->( __skadapter__to_[type]       )
```

- [x] Enums must be to ints in SKLIBC

- [x] Structs must be declared as their types in the generated language code (go through each field)
   (not in SKLIBC code as it's included from #include splashkit)

- [x] New breakdown for function calls in both SKLIBC and generated code
