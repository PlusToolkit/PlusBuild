# Find the Agilent MD1 SDK
# This module defines
# AgilentMD1_FOUND - Agilent SDK has been found on this system
# AgilentMD1_INCLUDE_DIR - where to find the header files
# AgilentMD1_LIBRARIES - libraries to be linked

IF(NOT WIN32)
  MESSAGE(FATAL_ERROR "AgilentMD1 is only supported on Windows. Cannot continue.")
ENDIF()

SET(AgilentMD1_PATH_HINTS
  "C:/Program Files (x86)/Agilent/MD1/U10xx_Digitizers"
  "C:/Program Files/IVI Foundation/IVI"
  "C:/Program Files (x86)/IVI Foundation/IVI"
  )

IF(CMAKE_HOST_WIN32 AND CMAKE_CL_64)
  SET(PLATFORM_SUFFIX "_64")
ELSE()
  SET(PLATFORM_SUFFIX "")
ENDIF()
  
FIND_PATH(AgilentMD1_INCLUDE_DIR AgMD1Fundamental.h
  PATH_SUFFIXES
    include
  DOC "U10xx_Digitizers include directory (contains AgMD1Fundamental.h)"
  PATHS ${AgilentMD1_PATH_HINTS} 
  )

FIND_LIBRARY(AgilentMD1_LIBRARY 
  NAMES AgMD1Fundamental${PLATFORM_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
  PATH_SUFFIXES
    lib
  DOC "Path to Agilent MD1 base library (AgMD1Fundamental${CMAKE_STATIC_LIBRARY_SUFFIX})"
  PATHS ${AgilentMD1_PATH_HINTS}
  )

FIND_PATH(AgilentMD1_BINARY_DIR 
  AgMD1Fundamental${PLATFORM_SUFFIX}${CMAKE_SHARED_LIBRARY_SUFFIX}
  PATH_SUFFIXES 
    bin
  PATHS ${AgilentMD1_PATH_HINTS} 
  DOC "Path to Agilent MD1 base shared library (AgMD1Fundamental${CMAKE_SHARED_LIBRARY_SUFFIX})"
  NO_DEFAULT_PATH # avoid finding installed DLLs in the system folders
  )

# handle the QUIETLY and REQUIRED arguments and set MicronTracker_FOUND to TRUE if 
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(AgilentMD1 DEFAULT_MSG 
  AgilentMD1_INCLUDE_DIR
  AgilentMD1_LIBRARY
  AgilentMD1_BINARY_DIR
  )

IF(AgilentMD1_FOUND)
  SET(AgilentMD1_LIBRARIES ${AgilentMD1_LIBRARY})
ENDIF()

# Wrap everything in a CMake target
ADD_LIBRARY(AgilentMD1 STATIC IMPORTED)
SET_TARGET_PROPERTIES(AgilentMD1 PROPERTIES
  IMPORTED_IMPLIB ${AgilentMD1_LIBRARY}
  IMPORTED_LOCATION ${AgilentMD1_BINARY_DIR}/AgMD1Fundamental${PLATFORM_SUFFIX}${CMAKE_SHARED_LIBRARY_SUFFIX}
  INTERFACE_INCLUDE_DIRECTORIES ${AgilentMD1_INCLUDE_DIR}
  )