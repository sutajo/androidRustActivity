cmake_minimum_required(VERSION 3.22.1)
project("androidRustActivity")

set(JNI_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../jniLibs)
set(LIB_FOLDER ${CMAKE_CURRENT_SOURCE_DIR}/../test-lib)

include(Cargo.cmake)
add_external_library_crate(TEST_LIB ${LIB_FOLDER} ${JNI_DIR})