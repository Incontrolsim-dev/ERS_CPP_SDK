cmake_minimum_required (VERSION 3.20)
include_guard(GLOBAL)

include(${CMAKE_CURRENT_LIST_DIR}/Utility.cmake)

macro(ERS_Link targetName)
    target_link_libraries(${targetName} PUBLIC ers-core-api)
    ERS_Copy_Sources(${targetName})
endmacro()

macro(ERS_Add_Test targetName)
    ERS_Copy_Sources(${targetName})
    add_test(NAME ${targetName} COMMAND ${targetName} WORKING_DIRECTORY $<TARGET_FILE_DIR:${targetName}>)
endmacro()