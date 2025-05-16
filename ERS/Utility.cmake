cmake_minimum_required (VERSION 3.20)
include_guard(GLOBAL)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

#make visual studio like filters so that we have a nice file structure in ide
#SourcePath: path to start looking for sources
#SourceList: return value with list of all sources
function(ERS_Add_Filters sourcePath sourceList)
    file(GLOB_RECURSE _SourceList ${sourcePath}/*.cpp* ${sourcePath}/*.h* ${sourcePath}/*.hpp*)
    source_group(TREE ${sourcePath} FILES ${_SourceList})
    foreach(source IN ITEMS ${_SourceList})
        get_filename_component(_source_path "${source}" PATH)
        string(REPLACE "${CMAKE_SOURCE_DIR}" "" _group_path "${source_path}")
        string(REPLACE "/" "\\" _group_path "${_group_path}")
    endforeach()
    set(${sourceList} ${_SourceList} PARENT_SCOPE)
endfunction()


macro(ERS_Copy_Sources target)
    # Copy ERS sources to target
    add_custom_command(TARGET ${target} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        $<TARGET_FILE_DIR:ers-engine> $<TARGET_FILE_DIR:${target}>
        )

    # Set working directory specifically visual studio when running the project
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set_target_properties(
            ${target} PROPERTIES
            VS_DEBUGGER_WORKING_DIRECTORY "$<TARGET_FILE_DIR:${target}>")
    endif()
endmacro()

#make visual studio like filters so that we have a nice file structure in ide
#however Qt has its own files that we need to add for gui, resources, and translations
#SourcePath: path to start looking for sources
#SourceList: return value with list of all sources
function(ERS_Add_QtFilters sourcePath sourceList)
    file(GLOB_RECURSE _SourceList ${sourcePath}/*.cpp* ${sourcePath}/*.h* ${sourcePath}/*.hpp* ${sourcePath}/*.ui* ${sourcePath}/*.ts* ${sourcePath}/*.qrc*)
    source_group(TREE ${sourcePath} FILES ${_SourceList})
    foreach(source IN ITEMS ${_SourceList})
        get_filename_component(_source_path "${source}" PATH)
        string(REPLACE "${CMAKE_SOURCE_DIR}" "" _group_path "${source_path}")
        string(REPLACE "/" "\\" _group_path "${_group_path}")
    endforeach()
    set(${sourceList} ${_SourceList} PARENT_SCOPE)
endfunction(ERS_Add_QtFilters)

#make visual studio like filters so that we have a nice file structure in ide
#SourcePath: path to start looking for sources
#SourceList: return value with list of all sources
function(ERS_Add_shaderFilters sourcePath sourceList)
    file(GLOB_RECURSE _SourceList ${sourcePath}/*.sc)
    source_group(TREE ${sourcePath} FILES ${_SourceList})
    foreach(source IN ITEMS ${_SourceList})
        get_filename_component(_source_path "${source}" PATH)
        string(REPLACE "${CMAKE_SOURCE_DIR}" "" _group_path "${source_path}")
        string(REPLACE "/" "\\" _group_path "${_group_path}")
    endforeach()
    set(SourceList "${SourceList};${_SourceList}" PARENT_SCOPE)
endfunction(ERS_Add_shaderFilters)