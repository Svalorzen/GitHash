add_executable(main main.cpp)
target_link_libraries(main ${GITHASH_LIBRARIES})
add_test(NAME main_test WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY} COMMAND $<TARGET_FILE:main>)
