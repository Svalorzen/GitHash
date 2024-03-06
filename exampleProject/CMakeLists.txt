cmake_minimum_required(VERSION 3.9)
project(SomeApp)

include(${PROJECT_SOURCE_DIR}/cmake/Modules/GitHash.cmake)
SetupGitHash()

include(CTest)
include_directories(${PROJECT_SOURCE_DIR}/include)
add_subdirectory(${PROJECT_SOURCE_DIR}/src)
