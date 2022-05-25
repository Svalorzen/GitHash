# Needed for setup
set(_THIS_MODULE_FILE "${CMAKE_CURRENT_LIST_FILE}") # Don't ask why this works.

# When calling again, we can't get BINARY_DIR directly, so we get it as input.
if (NOT DEFINED outputDir)
    set(outputDir "${PROJECT_BINARY_DIR}/GitHash")
endif ()
set(outputFile "${outputDir}/GitHash.cpp")
set(cacheFile "${outputDir}/cache.txt")

# Generator of the .cpp of the githash library
function(genCppContents outputString)
    set(${outputString}
        "namespace GitHash {
           extern const char * branch;
           extern const char * sha1;
           extern const char * shortSha1;
           extern const bool dirty;
           const char * branch = \"${GIT_BRANCH}\";
           const char * sha1 = \"${GIT_SHA1}\";
           const char * shortSha1 = \"${GIT_SHORTSHA1}\";
           const bool dirty = ${GIT_DIRTY};
        }" PARENT_SCOPE
    )
endfunction()

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

    # Get the current commit hash (long)
    execute_process(
        COMMAND git log -1 --format=%H
        WORKING_DIRECTORY ${outputDir}
        OUTPUT_VARIABLE GIT_SHA1
        OUTPUT_STRIP_TRAILING_WHITESPACE)

    # Get whether we're dirty
    execute_process(
        COMMAND git describe --always --dirty
        WORKING_DIRECTORY ${outputDir}
        OUTPUT_VARIABLE GIT_DIRTY
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if( ${GIT_DIRTY} MATCHES ".*dirty" )
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

        # Compute our other needed info.
        # Get the current working branch
        execute_process(
            COMMAND git branch --show-current
            WORKING_DIRECTORY ${outputDir}
            OUTPUT_VARIABLE GIT_BRANCH
            OUTPUT_STRIP_TRAILING_WHITESPACE)

        # Get the current commit hash (short)
        execute_process(
            COMMAND git log -1 --format=%h
            WORKING_DIRECTORY ${outputDir}
            OUTPUT_VARIABLE GIT_SHORTSHA1
            OUTPUT_STRIP_TRAILING_WHITESPACE)

        # Get the CPP file contents with all variables correctly embedded.
        genCppContents(outputString)

        # Finally output our new library cpp file.
        file(WRITE ${outputFile} "${outputString}")
    endif ()
endfunction()

# This needs to be called at startup.
function(SetupGitHash)
    # Check that the user has the header, otherwise there's no point.
    if (NOT EXISTS "${PROJECT_SOURCE_DIR}/include/GitHash.hpp")
        message( FATAL_ERROR "I'm computing the current git hash, but you won't be able to use it because you don't have the GitHash.hpp header file in the 'include/' folder." )
    endif ()

    # Run this script when building
    add_custom_target(CheckGitHash COMMAND ${CMAKE_COMMAND}
        -DRUN_UPDATE_GIT_HASH=1
        -DoutputDir=${outputDir}
        -P ${_THIS_MODULE_FILE}
        BYPRODUCTS ${outputFile}
    )

    # Create library for user
    add_library(githash ${outputFile})
    # target_include_directories(githash PUBLIC ${PROJECT_BINARY_DIR}/githash) FIXME: rm?
    add_dependencies(githash CheckGitHash)

    set(GITHASH_LIBRARIES githash CACHE STRING "name of githash library")

    UpdateGitHash()
endfunction()

# This is used to run this function from an external cmake process.
if (RUN_UPDATE_GIT_HASH)
    UpdateGitHash()
endif ()
