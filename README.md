GITHASH CMAKE MODULE
====================

[![GitHash](https://github.com/Svalorzen/GitHash/actions/workflows/build_cmake.yml/badge.svg)](https://github.com/Svalorzen/GitHash/actions/workflows/build_cmake.yml)

This module allows you to obtain the current branch, sha1, short sha1 and dirty
flag directly within C++. It creates a static library called `GitHash` behind
the scenes which contains these values as symbols you can use.

It additionally creates a cache of the last generated hash (and whether it was
dirty) so it avoids recompilation as long as the current hash is equal to the
last compiled one.

Setup
-----

To use GitHash in your project, you need to:
- Clone the project in some sub-folder of your project, and add to your main
  `CMakeLists.txt` file the following line:
  ```
  add_subdirectory(<GitHash_Dir_Path>)`
  ```
- Add the following include where you need it:
  ```
  #include "GitHash.hpp"
  ```
- Use these variables in your C++ files:
  ```
  GitHash::branch;     // C-string
  GitHash::sha1;       // C-string
  GitHash::shortSha1;  // C-string
  GitHash::dirty;      // boolean
  ```
- In CMake, link your project to the GitHash library using the
  `${GITHASH_LIBRARIES}` variable:
  ```
  target_link_libraries(your_project "${GITHASH_LIBRARIES}")
  ```

Customization
-------------

### Output Files Names and Path ###

If for any reason you want the output files to have different names and/or
reside in a different folder than the default, you can configure GitHash via the
following CMake variables: `GitHash_OutputDir`, `GitHash_CppFilename` and
`GitHash_CacheFilename`. For example, you might want to run:

```
cmake -DGitHash_OutputDir=MyCustomFolder
```

### Additional Fields ###

It is possible to add additional fields to read (for example, to read tags). For
each new field, you need to:
- Modify the `GitHash.hpp` header file to expose the new field you want.
- Add the new field, and the appropriate `git` command to obtain its value, in
  the `CMakeLists.txt` script. All modifications can be done briefly at the top
  of the CMake script:
  - Add a new CMake variable to `variablesToRead`
  - Add a new `CMD_` variable containing the appropriate command to run
  - Add a new `extern` field (both declaration and definition) inside the string
    in the `genCppContents` function

### Other non-Git Commands ###

The GitHash mechanism can be used more generally than `git`, since you could use
arbitrary commands to generate and expose arbitrary values. If you do so, you
may also want to change what is put in the cache so you can trigger
recompilation when your commands return different values. To do so, you just
have to change the format of the cache file as returned by the `genCache`
function.

Credits
-------

This library was developed with the help of [this blog
post](https://jonathanhamberg.com/post/cmake-embedding-git-hash/).
