cmake_minimum_required (VERSION 3.20)

macro(ERS_Download_SDK TAG)
    Include(FetchContent)
    FetchContent_Declare(
        ERS_ENGINE
        GIT_REPOSITORY https://github.com/Incontrolsim-dev/ERS_CPP_SDK.git
        GIT_TAG        ${TAG}
        )
    FetchContent_GetProperties(ERS_ENGINE)
    if(NOT ERS_ENGINE_POPULATED)
        message(STATUS "Downloading ERS SDK package")
        FetchContent_Populate(ERS_ENGINE)
    endif()
    include(${ers_engine_SOURCE_DIR}/setup.cmake)
endmacro()