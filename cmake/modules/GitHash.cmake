###################################
###### CUSTOMIZATION POINTS #######
###################################

# If you change the output file, remember to modify the GitHash.hpp header file
# in sync with it!

# Commands to read each needed variable
set(variablesToRead "GIT_BRANCH;GIT_SHA1;GIT_SHORTSHA1;GIT_DIRTY")
set(CMD_GIT_BRANCH      git branch --show-current)
set(CMD_GIT_SHA1        git log -1 --format=%H)
set(CMD_GIT_SHORTSHA1   git log -1 --format=%h)
set(CMD_GIT_DIRTY       git describe --always --dirty) # we post-process this one

# Generator of the .cpp of the githash library
function(genCppContents outputString)
    set(${outputString}
        "namespace GitHash {
           extern const char * const branch;
           extern const char * const sha1;
           extern const char * const shortSha1;
           extern const bool dirty;
           const char * const branch = \"${GIT_BRANCH}\";
           const char * const sha1 = \"${GIT_SHA1}\";
           const char * const shortSha1 = \"${GIT_SHORTSHA1}\";
           const bool dirty = ${GIT_DIRTY};
        }" PARENT_SCOPE
    )
endfunction()

###################################
### END OF CUSTOMIZATION POINTS ###
###################################

# Needed for setup for older CMake versions (reads this file's path).
set(_THIS_MODULE_FILE "${CMAKE_CURRENT_LIST_FILE}")

# When calling again, we can't get BINARY_DIR directly, so we get it as input.
if (NOT DEFINED outputDir)
    set(outputDir "${PROJECT_BINARY_DIR}/GitHash")
endif ()
set(outputFile "${outputDir}/GitHash.cpp")
set(cacheFile "${outputDir}/cache.txt")

# Reads cache file to a variable
function(ReadGitSha1Cache sha1)
    if (EXISTS ${cacheFile})
        file(STRINGS ${cacheFile} CONTENT)
        LIST(GET CONTENT 0 tmp)

        set(${sha1} ${tmp} PARENT_SCOPE)
    endif ()
endfunction()

# Function called during `make`
function(UpdateGitHash)
    # Make sure our working folder exists.
    if (NOT EXISTS ${outputDir})
        file(MAKE_DIRECTORY ${outputDir})
    endif ()

    # Automatically set all variables.
    foreach(c ${variablesToRead})
        execute_process(
            COMMAND ${CMD_${c}}
            WORKING_DIRECTORY "${outputDir}"
            OUTPUT_VARIABLE ${c}
            OUTPUT_STRIP_TRAILING_WHITESPACE)
    endforeach(c)

    # GIT_DIRTY post-processing
    if(${GIT_DIRTY} MATCHES ".*dirty")
        set(GIT_DIRTY "true")
    else()
        set(GIT_DIRTY "false")
    endif()

    # Try to read the cache
    ReadGitSha1Cache(sha1Cache)
    if (NOT DEFINED sha1Cache)
        set(sha1Cache "none")
    endif ()

    # Only update the GitHash.cpp if the hash has changed. This will
    # prevent us from rebuilding the project more than we need to.
    if (NOT "${GIT_SHA1}-${GIT_DIRTY}" STREQUAL ${sha1Cache} OR NOT EXISTS ${outputFile})
        # Set the cache so we can skip rebuilding if nothing changed.
        file(WRITE ${cacheFile} "${GIT_SHA1}-${GIT_DIRTY}")

        # Get the CPP file contents with all variables correctly embedded.
        genCppContents(outputString)

        # Finally output our new library cpp file.
        file(WRITE ${outputFile} "${outputString}")
        message(STATUS "Compiling branch ${GIT_BRANCH}, commit ${GIT_SHA1}, dirty is ${GIT_DIRTY}")
    endif ()
endfunction()

# This needs to be called at startup.
function(SetupGitHash)
    # Run this script when building
    add_custom_target(CheckGitHash COMMAND ${CMAKE_COMMAND}
        -DRUN_UPDATE_GIT_HASH=1
        -DoutputDir=${outputDir}
        -P ${_THIS_MODULE_FILE}
        BYPRODUCTS ${outputFile}
    )

    # Create library for user
    add_library(githash ${outputFile})
    add_dependencies(githash CheckGitHash)

    # Output library name to the other CMakeLists.txt
    set(GITHASH_LIBRARIES githash CACHE STRING "Name of githash library")

    UpdateGitHash()
endfunction()

# This is used to run this function from an external cmake process.
if (RUN_UPDATE_GIT_HASH)
    UpdateGitHash()
endif ()
