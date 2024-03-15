add_executable(main main.cpp)

# This automatically adds the GitHash header file dependency to your project
target_link_libraries(main ${GITHASH_LIBRARIES})

add_test(NAME main_test WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY} COMMAND $<TARGET_FILE:main>)
