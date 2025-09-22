cmake_minimum_required (VERSION 3.20)

macro(ERS_Download_SDK TAG)
    Include(FetchContent)
    FetchContent_Declare(
        ERS_ENGINE
        GIT_REPOSITORY https://github.com/Incontrolsim-dev/ERS_CPP_SDK.git
        GIT_TAG        main
        )
    message(STATUS "Downloading ERS SDK package for ${branchName} (shallow clone)")
    FetchContent_MakeAvailable(ERS_ENGINE)
    include(${ers_engine_SOURCE_DIR}/setup.cmake)
endmacro()