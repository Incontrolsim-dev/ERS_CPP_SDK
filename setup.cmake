cmake_minimum_required (VERSION 3.20)

macro(ERS_Download_SDK)
    Include(FetchContent)
    FetchContent_Declare(
        ERS_ENGINE
        GIT_REPOSITORY https://github.com/incontrolsim/ERS_CPP_SDK.git
        GIT_TAG        0.4.0
        )
    FetchContent_GetProperties(ERS_ENGINE)
    if(NOT ERS_ENGINE_POPULATED)
        message(STATUS "Downloading ERS SDK package")
        FetchContent_Populate(ERS_ENGINE)
    endif()
endmacro()

macro(ERS_RUN_VCPKG)
    include(${ers_engine_SOURCE_DIR}/vcpkg.cmake)
endmacro()

macro(ERS_Setup_SDK)
    add_subdirectory(${ers_engine_SOURCE_DIR} ${ers_engine_BINARY_DIR})
endmacro()

macro(ERS_Enable_Additional_Build_Settings)
    include(ProcessorCount)
    ProcessorCount(CoreCount)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP${CoreCount}")
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -fPIC")
    endif()
endmacro()
