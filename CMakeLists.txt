cmake_minimum_required (VERSION 3.20)

include_guard(GLOBAL)

project(ERS_SDK VERSION 0.0.1)

option(ERS_BUILD_TESTS "Indication if ERS should build the tests" TRUE)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/Install/${CMAKE_BUILD_TYPE} CACHE PATH "" FORCE)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_INSTALL_PREFIX}/lib CACHE PATH "" FORCE)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_INSTALL_PREFIX}/lib CACHE PATH "" FORCE)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_INSTALL_PREFIX}/bin CACHE PATH "" FORCE)

add_subdirectory(ERS)

# Add command line arguments for specific compilers
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    add_compile_options(-fPIC)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    add_compile_options(-fPIC)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
endif()

if(ERS_BUILD_TESTS)
    set(WORKING_DIRECTORY "$<TARGET_FILE_DIR:ers-engine>")
    include(CTest)
    enable_testing()

endif()
