# Find the RevoPoint 3D Camera SDK
# This module defines
# REVOPOINT3DSDK_FOUND - Revopoint 3D camera SDK has been found on this system
# REVOPOINT3DSDK_INCLUDE_DIR - Revopoint 3D camera SDK headers directory
# REVOPOINT3DSDK_BINARY_DIR - Revopoint 3D camera SDK binary directory
# REVOPOINT3DSDK_LIBRARIES - Revopoint 3D camera SDK libraries
#

SET(REVOPOINT3DSDK_ROOT "" CACHE STRING "Path to Revopoint 3D Camera SDK directory")

IF (NOT REVOPOINT3DSDK_ROOT)
  MESSAGE(FATAL_ERROR "Please specify the Revopoint 3D Camera SDK root directory in the variable REVOPOINT3DSDK_ROOT.")
ENDIF()

# Setup
SET(_revopoint3d_libs 3DCamera HandEye)
SET(REVOPOINT3DSDK_LIBRARIES)

# Find include directory
FIND_FILE(3D_CAM_HEADER 3DCamera.hpp PATHS ${REVOPOINT3DSDK_ROOT} PATH_SUFFIXES "inc")
IF(NOT 3D_CAM_HEADER)
  MESSAGE(FATAL_ERROR "Failed to find 3DCamera.hpp from SDK root. Check REVOPOINT3DSDK_ROOT.")
ENDIF()
GET_FILENAME_COMPONENT(REVOPOINT3DSDK_INCLUDE_DIR "${3D_CAM_HEADER}" DIRECTORY)

# Find libraries
STRING(TOLOWER ${CMAKE_SYSTEM_NAME} _revopoint3d_libs_subdir)
FOREACH(_lib ${_revopoint3d_libs})
  FIND_LIBRARY(_libpath ${_lib} PATHS ${REVOPOINT3DSDK_ROOT} PATH_SUFFIXES "lib/${_revopoint3d_libs_subdir}")
  IF(NOT _libpath)
    MESSAGE(FATAL_ERROR "Failed to find ${_lib} library from SDK root. Check REVOPOINT3DSDK_ROOT.")
  ENDIF()
  SET(REVOPOINT3DSDK_LIBRARIES ${REVOPOINT3DSDK_LIBRARIES} ${_libpath})
ENDFOREACH()

# Find binaries
FOREACH(_rtlib ${_revopoint3d_libs})
  FIND_FILE(_rtlibpath ${CMAKE_SHARED_LIBRARY_PREFIX}${_rtlib}${CMAKE_SHARED_LIBRARY_SUFFIX} PATHS ${REVOPOINT3DSDK_ROOT} PATH_SUFFIXES "lib/${_revopoint3d_libs_subdir}")
  IF(NOT _rtlibpath)
    MESSAGE(FATAL_ERROR "Failed to find ${_rtlib}${CMAKE_SHARED_LIBRARY_SUFFIX} runtime library from SDK root. Check REVOPOINT3DSDK_ROOT.")
  ENDIF()
  GET_FILENAME_COMPONENT(REVOPOINT3DSDK_BINARY_DIR "${_rtlibpath}" DIRECTORY)
ENDFOREACH()

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(REVOPOINT3DSDK DEFAULT_MSG
  REVOPOINT3DSDK_INCLUDE_DIR
  REVOPOINT3DSDK_BINARY_DIR
  REVOPOINT3DSDK_LIBRARIES
  )
