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
  "../PLTools/OptiTrack/MotiveAPI-${MOTIVE_VERSION}"
  "../../PLTools/OptiTrack/MotiveAPI-${MOTIVE_VERSION}"
  "../trunk/PLTools/OptiTrack/MotiveAPI-${MOTIVE_VERSION}"
  "${CMAKE_CURRENT_BINARY_DIR}/PLTools/OptiTrack/MotiveAPI-${MOTIVE_VERSION}"
  "$ENV{PROGRAMFILES}/OptiTrack/Motive"
  "$ENV{PROGRAMW6432}/OptiTrack/Motive"
  "C:/Program Files (x86)/OptiTrack/Motive"
  "C:/Program Files/OptiTrack/Motive"
  )

SET(Microsoft_VC80_OpenMP_PATH_HINTS
  "../PLTools/OptiTrack/Microsoft.VC80.OpenMP"
  "../../PLTools/OptiTrack/Microsoft.VC80.OpenMP"
  "../trunk/PLTools/OptiTrack/Microsoft.VC80.OpenMP"
  "${CMAKE_CURRENT_BINARY_DIR}/PLTools/OptiTrack/Microsoft.VC80.OpenMP"
  )

find_path(MOTIVE_DIR "/inc/NPTrackingTools.h"
  PATHS ${MOTIVEAPI_PATH_HINTS}
  DOC "OptiTrack Motive API directory")

find_path(MOTIVE_MSVC80_OpenMP_DIR
      NAMES vcomp.dll
      PATHS ${Microsoft_VC80_OpenMP_PATH_HINTS}
      DOC "Microsoft VC80 OpenMP directory")

IF (MOTIVE_DIR)
  # Include directories
  set(MOTIVE_API_INCLUDE_DIR ${MOTIVE_DIR}/inc)
  mark_as_advanced(MOTIVE_API_INCLUDE_DIR)

  #Version
  #TODO: properly set SDK version using REGEX
  set(MOTIVE_API_VERSION ${MOTIVE_VERSION})

ENDIF ()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MOTIVE_API
  FOUND_VAR MOTIVE_API_FOUND
  REQUIRED_VARS MOTIVE_API_INCLUDE_DIR MOTIVE_DIR
  VERSION_VAR MOTIVE_API_VERSION
)
