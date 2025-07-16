###############################################################################
# Find OptiTrack Motive API
#
#     find_package(MotiveAPI)
#
# Variables defined by this module:
#
#  MotiveAPI_FOUND                True if OptiTrack Motive API was found
#  MotiveAPI_VERSION              The version of Motive API
#  MotiveAPI_DIR                  The directory containing Motive API
#  MotiveAPI_INCLUDE_DIR          The location(s) of Motive API headers
#  MotiveAPI_MSVC80_OpenMP_DIR    Location of libiomp5md.dll needed to use Motive API

set(MotiveAPI_PATH_HINTS
  "../PLTools/OptiTrack/MotiveAPI-${MOTIVE_VERSION}"
  "../../PLTools/OptiTrack/MotiveAPI-${MOTIVE_VERSION}"
  "../trunk/PLTools/OptiTrack/MotiveAPI-${MOTIVE_VERSION}"
  "${CMAKE_CURRENT_BINARY_DIR}/MotiveAPI"
  "${CMAKE_CURRENT_BINARY_DIR}/PLTools/OptiTrack/MotiveAPI-${MOTIVE_VERSION}"
  "$ENV{PROGRAMFILES}/OptiTrack/Motive"
  "$ENV{PROGRAMW6432}/OptiTrack/Motive"
  "C:/Program Files (x86)/OptiTrack/Motive"
  "C:/Program Files/OptiTrack/Motive"
  )

set(Microsoft_VC80_OpenMP_PATH_HINTS
  "../PLTools/OptiTrack/Microsoft.VC80.OpenMP"
  "../../PLTools/OptiTrack/Microsoft.VC80.OpenMP"
  "../trunk/PLTools/OptiTrack/Microsoft.VC80.OpenMP"
  "${CMAKE_CURRENT_BINARY_DIR}/PLTools/OptiTrack/Microsoft.VC80.OpenMP"
  )

if (MOTIVE_VERSION VERSION_LESS 3.0.0)
  find_path(MotiveAPI_DIR "/inc/NPTrackingTools.h"
    PATHS ${MotiveAPI_PATH_HINTS}
    DOC "OptiTrack Motive API directory")
else()
  find_path(MotiveAPI_DIR "/inc/MotiveAPI.h"
    PATHS ${MotiveAPI_PATH_HINTS}
    DOC "OptiTrack Motive API directory")
endif()

find_path(MotiveAPI_MSVC80_OpenMP_DIR
      NAMES vcomp.dll
      PATHS ${Microsoft_VC80_OpenMP_PATH_HINTS}
      DOC "Microsoft VC80 OpenMP directory")

if(MotiveAPI_DIR)
  set(MotiveAPI_INCLUDE_DIR ${MotiveAPI_DIR}/inc)
  mark_as_advanced(MotiveAPI_INCLUDE_DIR)
  set(MotiveAPI_VERSION ${MOTIVE_VERSION})
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MotiveAPI
  FOUND_VAR MotiveAPI_FOUND
  REQUIRED_VARS MotiveAPI_INCLUDE_DIR MotiveAPI_DIR
  VERSION_VAR MotiveAPI_VERSION
)
