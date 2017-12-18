###############################################################################
# Find OptiTrack Motive API
#
#     find_package(MotiveAPI)
#
# Variables defined by this module:
#
#  MOTIVE_API_FOUND               True if OptiTrack Motive API was found
#  MOTIVE_API_VERSION             The version of Motive API
#  MOTIVE_API_INCLUDE_DIR         The location(s) of Motive API headers
#  MOTIVE_API_LIBRARY_DIR         Libraries needed to use Motive API
#  MOTIVE_API_BINARY_DIR          Binaries needed to use Motive API
#  MOTIVE_API_LIBRARY_NAME        Name of Motive API library file
#  MOTIVE_API_BINARY_NAME         Name of Motive API binary file
#  MOTIVE_OPENMP_DIR              Location of libiomp5md.dll needed to use Motive API

SET(MOTIVEAPI_PATH_HINTS
  "../PLTools/OptiTrack/MotiveAPI-1.10.3"
  "../../PLTools/OptiTrack/MotiveAPI-1.10.3"
  "../trunk/PLTools/OptiTrack/MotiveAPI-1.10.3"
  "${CMAKE_CURRENT_BINARY_DIR}/PLTools/OptiTrack/MotiveAPI-1.10.3"
  "$ENV{PROGRAMFILES}/OptiTrack/Motive"
  "$ENV{PROGRAMW6432}/OptiTrack/Motive"
  "C:/Program Files (x86)/OptiTrack/Motive"
  "C:/Program Files/OptiTrack/Motive"
  )

find_path(MOTIVE_DIR "/inc/NPTrackingTools.h"
  PATHS ${MOTIVEAPI_PATH_HINTS}
  DOC "OptiTrack Motive API directory")

IF (MOTIVE_DIR)
  # Include directories
  set(MOTIVE_API_INCLUDE_DIR ${MOTIVE_DIR}/inc)
  mark_as_advanced(MOTIVE_API_INCLUDE_DIR)

  # Libraries
  SET(PLATFORM_NAME_SUFFIX "")
  SET(OPENMP_PATH_SUFFIX "/lib32")
  IF (CMAKE_HOST_WIN32 AND CMAKE_CL_64 )
    SET(PLATFORM_NAME_SUFFIX "x64")
    SET(OPENMP_PATH_SUFFIX "")
  ENDIF ()
  
  find_path(MotiveAPI_LIBRARY_DIR
            NAMES NPTrackingTools${PLATFORM_NAME_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
            PATHS "${MOTIVE_DIR}/lib/" NO_DEFAULT_PATH)

  find_path(MotiveAPI_BINARY_DIR
            NAMES NPTrackingTools${PLATFORM_NAME_SUFFIX}${CMAKE_SHARED_LIBRARY_SUFFIX}
            PATHS "${MOTIVE_DIR}/lib/" NO_DEFAULT_PATH)

   find_path(libiomp_LIBRARY_DIR
             NAMES libiomp5md${CMAKE_SHARED_LIBRARY_SUFFIX}
             PATHS "${MOTIVE_DIR}${OPENMP_PATH_SUFFIX}" NO_DEFAULT_PATH)
             
  set(MOTIVE_API_LIBRARY_DIR ${MotiveAPI_LIBRARY_DIR})
  set(MOTIVE_API_BINARY_DIR ${MotiveAPI_BINARY_DIR})
  set(MOTIVE_API_LIBRARY_NAME NPTrackingTools${PLATFORM_NAME_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(MOTIVE_API_BINARY_NAME NPTrackingTools${PLATFORM_NAME_SUFFIX}${CMAKE_SHARED_LIBRARY_SUFFIX})
  set(MOTIVE_OPENMP_DIR ${libiomp_LIBRARY_DIR})
  
  mark_as_advanced(MOTIVE_API_LIBRARY_DIR)
  mark_as_advanced(MOTIVE_API_BINARY_DIR)
  mark_as_advanced(MOTIVE_API_LIBRARY_NAME)
  mark_as_advanced(MOTIVE_API_BINARY_NAME)
  mark_as_advanced(MOTIVE_OPENMP_DIR)

  #Version
  #TODO: properly set SDK version using REGEX
  set(MOTIVE_API_VERSION "1.10.3")

ENDIF ()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MOTIVE_API
  FOUND_VAR MOTIVE_API_FOUND
  REQUIRED_VARS MOTIVE_API_INCLUDE_DIR MOTIVE_API_LIBRARY_DIR MOTIVE_API_BINARY_DIR MOTIVE_API_LIBRARY_NAME MOTIVE_API_BINARY_NAME MOTIVE_OPENMP_DIR
  VERSION_VAR MOTIVE_API_VERSION
)