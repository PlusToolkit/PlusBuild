# Find the Azure Kinect SDK
# This module defines
# K4A_FOUND - Azure Kinect SDK has been found on this system
# K4A_INCLUDE_DIR - Azure Kinect SDK headers directory
# K4A_LIBRARY_DIR - Azure Kinect SDK library directory
# K4A_BINARY_DIR - Azure Kinect SDK binary directory
# K4A_LIBRARY - Azure Kinect SDK k4a library
#

IF(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
  # For now, the recommended installation on Linux debian distro is through
  # debian packages thus cmake should find the SDK in the system paths.
  FIND_PACKAGE(k4a 1.4.0 REQUIRED)
  IF(${k4a_FOUND})
    IF(NOT TARGET k4a::k4a)
      MESSAGE(FATAL_ERROR "Could not found k4a::k4a target")
    ENDIF()
    GET_TARGET_PROPERTY(_configuration k4a::k4a IMPORTED_CONFIGURATIONS)
    IF(_configuration)
      GET_TARGET_PROPERTY(K4A_LIBRARY k4a::k4a IMPORTED_LOCATION_${_configuration})
      IF(K4A_LIBRARY)
        GET_FILENAME_COMPONENT(K4A_LIBRARY_DIR ${K4A_LIBRARY} DIRECTORY)
        SET(K4A_BINARY_DIR ${K4A_LIBRARY_DIR})
      ENDIF()
      GET_TARGET_PROPERTY(K4A_INCLUDE_DIR k4a::k4a INTERFACE_INCLUDE_DIRECTORIES)
    ENDIF()
  ENDIF()
ELSEIF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
  SET(K4A_ROOT_141 "C:/Program Files/Azure Kinect SDK v1.4.1")
  SET(K4A_ROOT_140 "C:/Program Files/Azure Kinect SDK v1.4.0")
  SET(K4A_ROOT "${K4A_ROOT_141}" CACHE STRING "Path to Azure Kinect SDK")
  SET(K4A_INSTALL_PATHS "${K4A_ROOT}" "${K4A_ROOT}/sdk" "${K4A_ROOT_140}" "${K4A_ROOT_140}/sdk")
  IF(NOT "${CMAKE_GENERATOR}" MATCHES "(Win64|IA64)")
    SET(DESKTOP_ARCH x86)
  ELSE()
    SET(DESKTOP_ARCH amd64)
  ENDIF()
  # Find linked-time libraries
  FIND_LIBRARY(K4A_LIBRARY k4a PATHS ${K4A_INSTALL_PATHS} PATH_SUFFIXES "windows-desktop/${DESKTOP_ARCH}/release/lib")
  IF(NOT K4A_LIBRARY)
    MESSAGE(FATAL_ERROR "Failed to find k4a library from SDK. Try to set K4A_ROOT variable.")
  ENDIF()
  GET_FILENAME_COMPONENT(K4A_LIBRARY_DIR "${K4A_LIBRARY}" DIRECTORY)

  # Find include directory
  FIND_FILE(K4A_HEADER k4a/k4a.hpp PATHS ${K4A_INSTALL_PATHS} PATH_SUFFIXES "include")
  IF(NOT K4A_HEADER)
    MESSAGE(FATAL_ERROR "Failed to find k4a.hpp from SDK. Try to set K4A_ROOT variable.")
  ENDIF()
  GET_FILENAME_COMPONENT(K4A_INCLUDE_DIR "${K4A_HEADER}" DIRECTORY)
  GET_FILENAME_COMPONENT(K4A_INCLUDE_DIR "${K4A_INCLUDE_DIR}" DIRECTORY)

  # Find binary directory
  FOREACH(rtlib k4a;depthengine_2_0)
    FIND_FILE(K4A_RT_${rtlib} ${rtlib}.dll PATHS ${K4A_INSTALL_PATHS} PATH_SUFFIXES "windows-desktop/${DESKTOP_ARCH}/release/bin")
    IF(NOT K4A_RT_${rtlib})
      MESSAGE(FATAL_ERROR "Failed to find ${rtlib}.dll from SDK. Try to set K4A_ROOT variable.")
    ENDIF()
    GET_FILENAME_COMPONENT(_K4A_BINARY_DIR "${K4A_RT_${rtlib}}" DIRECTORY)
    IF(NOT K4A_BINARY_DIR)
      SET(K4A_BINARY_DIR ${_K4A_BINARY_DIR})
    ELSEIF(NOT "${_K4A_BINARY_DIR}" STREQUAL "${K4A_BINARY_DIR}")
      MESSAGE(FATAL_ERROR "Found some dlls in different directories")
    ENDIF()
  ENDFOREACH()
ENDIF()

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(K4A DEFAULT_MSG
  K4A_INCLUDE_DIR
  K4A_LIBRARY_DIR
  K4A_BINARY_DIR
  K4A_LIBRARY
  )
