cmake_minimum_required (VERSION 3.20)

macro(ERS_Download_SDK branchName)

    message(STATUS "Selected SDK branch ${branchName}")

    Include(FetchContent)
    FetchContent_Declare(
        ERS_ENGINE
        GIT_REPOSITORY https://gitlab.incontrolsim.com/enterprise-resource-simulator/public/ers_sdk.git
        GIT_TAG        origin/${branchName}
        )
    FetchContent_GetProperties(ERS_ENGINE)
    if(NOT ERS_ENGINE_POPULATED)
        message(STATUS "Downloading ERS SDK package for ${branchName} branch")
        FetchContent_Populate(ERS_ENGINE)
    endif()
endmacro()

macro(ERS_Download_SDK_Dictated)

    # Get the current working branch
    execute_process(
    COMMAND git rev-parse --abbrev-ref HEAD
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE GIT_BRANCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(
    "${GIT_BRANCH}" STREQUAL "rc" OR
    "${GIT_BRANCH}" STREQUAL "nightly" OR
    "${GIT_BRANCH}" STREQUAL "main"
    )
        ERS_Download_SDK("${GIT_BRANCH}")
    else()
        ERS_Download_SDK("develop")
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
