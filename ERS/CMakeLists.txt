include_guard(GLOBAL)

include(${CMAKE_CURRENT_SOURCE_DIR}/Utility.cmake)
include(GNUInstallDirs)

option(ERS_OMIT_DOWNLOAD_ENGINE "For development purposes, omit downloading the ers-engine" OFF)
set(ERS_BUILD_DIR "" CACHE PATH "The build directory for the ers-engine project")
set(ERS_SDK_DIR "" CACHE PATH "The SDK directory for the ers-engine project")

if (NOT ERS_OMIT_DOWNLOAD_ENGINE)
    ## TODO Read commit hash from file then clone from hash
    file (STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/Engine/SDK_URL" BinariesURL)
    message(STATUS "Engine binaries url: ${BinariesURL}")

    # URL of the ZIP file to download
    set(DOWNLOAD_URL "${BinariesURL}")

    # Define the location where the ZIP file will be saved
    set(DOWNLOAD_FILE "${CMAKE_BINARY_DIR}/ERS_Binaries.zip")

    # Define the directory where the contents will be extracted
    set(EXTRACT_DIR "${CMAKE_BINARY_DIR}/ERS_Binaries")

    # Download the file (SHOW_PROGRESS is optional)
    if(NOT EXISTS "${DOWNLOAD_FILE}")
        message(STATUS "Downloading from ${DOWNLOAD_URL} to ${DOWNLOAD_FILE}")
        file(DOWNLOAD ${DOWNLOAD_URL} ${DOWNLOAD_FILE} SHOW_PROGRESS)
    endif()

    if(NOT EXISTS ${EXTRACT_DIR})
        message(STATUS "Creating extraction directory: ${EXTRACT_DIR}")
        file(MAKE_DIRECTORY ${EXTRACT_DIR})

        message(STATUS "Extracting ${DOWNLOAD_FILE} into ${EXTRACT_DIR}")

        # Extract the ZIP file into the specified directory
        file(ARCHIVE_EXTRACT INPUT ${DOWNLOAD_FILE} DESTINATION ${EXTRACT_DIR})
    endif()

    # Copy ERS binaries to installation directory always when the Install Target is built
    install(DIRECTORY "${EXTRACT_DIR}/bin/" DESTINATION ${CMAKE_INSTALL_BINDIR})
    set(EnginePath ${EXTRACT_DIR})
else()
    # Copy ERS binaries to installation directory always when the Install Target is built
    file(COPY "${ERS_BUILD_DIR}/" DESTINATION "${ERS_SDK_DIR}/bin")
    install(DIRECTORY "${ERS_SDK_DIR}/bin/" DESTINATION ${CMAKE_INSTALL_BINDIR})
    set(EnginePath ${ERS_SDK_DIR})
endif()

################### IMPORT ENGINE

set(ERSEngineName ers-engine CACHE INTERNAL "" ) # Imported Engine project name
set(EngineBinPath ${EnginePath}/bin)

if (NOT ERS_OMIT_DOWNLOAD_ENGINE)
    file(GLOB_RECURSE EngineBinaryFiles
    "${EngineBinPath}/${CMAKE_CXX_COMPILER_ID}/*"
    )
else()
    file(GLOB_RECURSE EngineBinaryFiles
    "${EngineBinPath}/*"
    )
endif()
file(COPY ${EngineBinaryFiles} DESTINATION "${CMAKE_BINARY_DIR}/ERS/Bin")
add_library(${ERSEngineName} SHARED IMPORTED GLOBAL)

set_target_properties(
    ${ERSEngineName} 
    PROPERTIES IMPORTED_LOCATION             
    ${CMAKE_BINARY_DIR}/ERS/Bin/${CMAKE_SHARED_LIBRARY_PREFIX}${ERSEngineName}${CMAKE_SHARED_MODULE_SUFFIX}
    )
    
################### IMPORT APIs
set(ERSApiName ers-core-api CACHE INTERNAL "") # API Project Name
#set(ERS4DSApiName ers-4dscriptlibrary CACHE INTERNAL "") # 4DS Library project name

# Define SDK directories
set(ERSEngineSDKDir ${EnginePath}/SDK)
set(ERSEngineIncludeDir ${ERSEngineSDKDir}/Include)
set(ERSEngineIncludeMinimalDir ${ERSEngineSDKDir}/Include_Minimal)

if("${CMAKE_BUILD_TYPE}" STREQUAL "")
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "")
    message(WARNING "Configured with Debug mode please configure with CMAKE_BUILD_TYPE=Debug|Release|RelWithDebInfo|MinSizeRel to do specific build")
endif()

add_custom_target(ers-sdk-setup)
if(EXISTS "${ERSEngineSDKDir}/lib") # Only create a copy event when libs are shipped
    add_custom_command(TARGET ers-sdk-setup PRE_BUILD
        COMMAND "${CMAKE_COMMAND}" -E copy_directory "${ERSEngineSDKDir}/lib/${CMAKE_CXX_COMPILER_ID}/${CMAKE_BUILD_TYPE}" "${CMAKE_BINARY_DIR}/ERS/Libs"
        COMMENT "Copying dependent DLL"
    )
endif()
set_property(TARGET ers-sdk-setup PROPERTY FOLDER "ERS/_autogen")

# utility target
ERS_Add_Filters("${ERSEngineIncludeMinimalDir}" ers-utility-sources)
add_library(ers-utility STATIC ${ers-utility-sources})
add_dependencies(ers-utility ers-sdk-setup)
target_include_directories(ers-utility PUBLIC "${ERSEngineIncludeMinimalDir}")
set_property(TARGET ers-utility PROPERTY FOLDER "ERS/Core")

# Common target
ERS_Add_Filters("${ERSEngineIncludeDir}/Common" ers-common-sources)
add_library(ers-common STATIC ${ers-common-sources})
add_dependencies(ers-common ers-sdk-setup)
target_include_directories(ers-common PUBLIC "${ERSEngineIncludeDir}/Common")
set_property(TARGET ers-common PROPERTY FOLDER "ERS/Core")

# API target
ERS_Add_Filters("${ERSEngineIncludeDir}/Ers" ers-api-sources)
add_library(${ERSApiName} STATIC ${ers-api-sources})
target_link_libraries(${ERSApiName} PUBLIC ers-utility ers-common)
target_include_directories(${ERSApiName} PUBLIC "${ERSEngineIncludeDir}/Ers")
target_include_directories(${ERSApiName} PUBLIC "${ERSEngineIncludeDir}/Ers-engine")
set_property(TARGET ${ERSApiName} PROPERTY FOLDER "ERS/Core")
