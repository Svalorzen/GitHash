cmake_minimum_required(VERSION 3.9)
project(SomeApp)

add_subdirectory(deps/GitHash)

include(CTest)
add_subdirectory(${PROJECT_SOURCE_DIR}/src)
