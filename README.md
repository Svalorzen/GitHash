GITHASH CMAKE MODULE
====================

This module allows you to obtain the current branch, sha1, short sha1 and dirty
flag directly within C++. It creates a static library called `GitHash` behind
the scenes which contains these values as symbols you can use.

To use GitHash in your project, you need to follow these steps:
- Copy the file `GitHash.cmake` in your project's `cmake/module` folder.
- Copy the file `GitHash.hpp` to your project's include directory.
- Add the following two lines to your main `CMakeLists.txt` file:
   ```
   include(${PROJECT_SOURCE_DIR}/cmake/modules/GitHash.cmake)
   SetupGitHash()
   ```
- Use these variables in your C++ files:
   ```
   GitHash::branch;     // C-string
   GitHash::sha1;       // C-string
   GitHash::shortSha1;  // C-string
   GitHash::dirty;      // boolean
   ```
- In CMake, use `target_link_libraries` to link your project to the GitHash
  library (using the `${GITHASH_LIBRARIES}` variable).

Note that currently the `GitHash` library is outputted in a subfolder of your
`PROJECT_BINARY_DIR`. If this is not desired you will have to manually modify
the script to specify your ideal output directory.

Customization
-------------

It is possible to add additional fields to read (for example, to read tags). For
each new field, you need to:
- Modify the `GitHash.hpp` header file to expose the new field you want.
- Add the new field, and the appropriate `git` command to obtain its value, in
  the `GitHash.cmake` script. All modifications can be done briefly at the top
  of the CMake script:
  - Add a new CMake variable to `variablesToRead`
  - Add a new `CMD_` variable containing the appropriate command to run
  - Add a new `extern` field (both declaration and definition) inside the string
    in the `getCppContents` function

Credits
-------

This library was developed with the help of [this blog
post](https://jonathanhamberg.com/post/cmake-embedding-git-hash/).
