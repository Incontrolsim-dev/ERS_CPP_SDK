# Configure vcpkg toolchain
if("${CMAKE_TOOLCHAIN_FILE}" STREQUAL "")
    if(DEFINED ENV{VCPKG_ROOT})
        set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "")
    endif()
endif()

option(ERS_USE_DEFAULT_VCPKG_INSTALL_DIR "Prevent reinstalling of packages of vcpkg after deleting build directory" OFF)

if("${CMAKE_TOOLCHAIN_FILE}" STREQUAL "")
    message(ERROR " unable to find vcpkg")
endif()

if(ERS_USE_DEFAULT_VCPKG_INSTALL_DIR)
    if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED VCPKG_INSTALLED_DIR)
        set(VCPKG_INSTALLED_DIR "$ENV{VCPKG_ROOT}/installed")
    endif()
endif()

if(WIN32)
    set(VCPKG_TARGET_TRIPLET "x64-windows" CACHE STRING "")
elseif(UNIX AND NOT APPLE)
    set(VCPKG_TARGET_TRIPLET "x64-linux" CACHE STRING "")
else()
    message(ERROR " Unable to determin VCPKG triplet for ERS")
endif()


if(EXISTS "${CMAKE_SOURCE_DIR}/vcpkg/")
    # Select only our overlay
	message("Setup to configure custom vcpkg packages.")

	# Since we have a few requirements for different packages we use custom overlays and a custom ports for specfic projects
	set(VCPKG_OVERLAY_PORTS "${CMAKE_SOURCE_DIR}/vcpkg/overlay")
	set(VCPKG_OVERLAY_TRIPLETS "${CMAKE_SOURCE_DIR}/vcpkg/triplets")
    set(VCPKG_TARGET_TRIPLET "${ERS_TRIPLET}-ers")

    configure_file(${VCPKG_OVERLAY_TRIPLETS}/${VCPKG_TARGET_TRIPLET}.cmake.in ${VCPKG_OVERLAY_TRIPLETS}/${VCPKG_TARGET_TRIPLET}.cmake)
endif()

include(${CMAKE_TOOLCHAIN_FILE})