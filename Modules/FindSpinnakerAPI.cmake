###############################################################################
# Find Point Grey Spinnaker API
#
#     find_package(SpinnakerAPI)
#
# Variables defined by this module:
#
#  SPINNAKER_API_FOUND               True if OptiTrack Motive API was found
#  SPINNAKER_API_VERSION             The version of Motive API
#  SPINNAKER_API_INCLUDE_DIR         The location(s) of Motive API headers
#  SPINNAKER_API_LIBRARY_DIR         Libraries needed to use Motive API
#  SPINNAKER_API_BINARY_DIR          Binaries needed to use Motive API

macro(spinnaker_get_version VERSION_FILE)
  unset(_VERSION_STR)
  unset(_MAJOR)
  unset(_MINOR)
  unset(_TYPE)
  unset(_BUILD)

  # read IPP version info from file
  file(STRINGS ${VERSION_FILE} STR1 REGEX "FLIR_SPINNAKER_VERSION_MAJOR")
  file(STRINGS ${VERSION_FILE} STR2 REGEX "FLIR_SPINNAKER_VERSION_MINOR")
  file(STRINGS ${VERSION_FILE} STR3 REGEX "FLIR_SPINNAKER_VERSION_TYPE")
  file(STRINGS ${VERSION_FILE} STR4 REGEX "FLIR_SPINNAKER_VERSION_BUILD")

  # extract info and assign to variables
  string(REGEX MATCHALL "[0-9]+" _MAJOR ${STR1})
  string(REGEX MATCHALL "[0-9]+" _MINOR ${STR2})
  string(REGEX MATCHALL "[0-9]+" _TYPE ${STR3})
  string(REGEX MATCHALL "[0-9]+" _BUILD ${STR4})

  # export info to parent scope
  set(SPINNAKER_API_VERSION "${_MAJOR}.${_MINOR}.${_TYPE}.${_BUILD}")
endmacro()

# path hints
SET(_x86env "ProgramFiles(x86)")
IF(WIN32)
  # Windows Spinnaker API path hints
  SET(SPINNAKER_API_PATH_HINTS
      "../PLTools/PointGrey/windows/spinnaker"
    "../../PLTools/PointGrey/windows/spinnaker"
    "../trunk/PLTools/PointGrey/windows/spinnaker"
    "$ENV{PROGRAMFILES}/Point Grey Research/Spinnaker"
    "C:/Program Files/Point Grey Research/Spinnaker"
    "$ENV{${_x86env}}/Point Grey Research/Spinnaker"
    "C:/Program Files (x86)/Point Grey Research/Spinnaker"
    )
ELSEIF(UNIX AND NOT MAC)
  # Ubuntu Spinnaker API path hints

  # get release codename
  execute_process(COMMAND lsb_release -cs
    OUTPUT_VARIABLE _RELEASE_CODENAME
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )

  # get bitness suffix
  IF(CMAKE_SIZEOF_VOID_P EQUAL 4)
    SET(_SPINNAKER_BITNESS_SUFFIX "win32")
  ELSE()
    SET(_SPINNAKER_BITNESS_SUFFIX "x64")
  ENDIF()

  SET(SPINNAKER_API_PATH_HINTS
    "../PLTools/PointGrey/ubuntu_${_RELEASE_CODENAME}/spinnaker_${_SPINNAKER_BITNESS_SUFFIX}"
    "../../PLTools/PointGrey/ubuntu_${_RELEASE_CODENAME}/spinnaker${_SPINNAKER_BITNESS_SUFFIX}"
    "../trunk/PLTools/PointGrey/ubuntu_${_RELEASE_CODENAME}/spinnaker${_SPINNAKER_BITNESS_SUFFIX}"
    "/usr/include/spinnaker"
    )
ENDIF()

# check for local spinnaker folder
find_path(SPINNAKER_DIR "/include/System.h"
  PATHS ${SPINNAKER_API_PATH_HINTS}
  DOC "Point Grey Spinnaker API directory")

IF (SPINNAKER_DIR)
  # include directories
  set(SPINNAKER_API_INCLUDE_DIR ${SPINNAKER_DIR}/include)
  mark_as_advanced(SPINNAKER_API_INCLUDE_DIR)

  IF(WIN32)
    # Windows
    IF(CMAKE_SIZEOF_VOID_P EQUAL 4)
      # 32 bits
      set(SPINNAKER_API_LIBRARY_DIR ${SPINNAKER_DIR}/lib/vs2015)
      mark_as_advanced(SPINNAKER_API_LIBRARY_DIR)
      set(SPINNAKER_API_BINARY_DIR ${SPINNAKER_DIR}/bin/vs2015)
      mark_as_advanced(SPINNAKER_API_BINARY_DIR)
    ELSE()
      # 64 bits
      set(SPINNAKER_API_LIBRARY_DIR ${SPINNAKER_DIR}/lib64/vs2015)
      mark_as_advanced(SPINNAKER_API_LIBRARY_DIR)
      set(SPINNAKER_API_BINARY_DIR ${SPINNAKER_DIR}/bin64/vs2015)
      mark_as_advanced(SPINNAKER_API_BINARY_DIR)
    ENDIF()

  ELSEIF(UNIX AND NOT MAC)
    # Ubuntu
    set(SPINNAKER_API_LIBRARY_DIR ${SPINNAKER_DIR}/lib)
    mark_as_advanced(SPINNAKER_API_LIBRARY_DIR)
    set(SPINNAKER_API_BINARY_DIR ${SPINNAKER_DIR}/lib)
    mark_as_advanced(SPINNAKER_API_BINARY_DIR)
  ENDIF()

  # version
  spinnaker_get_version("${SPINNAKER_DIR}/include/System.h")

ELSE()
  # check if spinnaker is globally installed on Ubuntu
  IF (UNIX AND NOT MAC AND EXISTS "/usr/include/spinnaker/System.h")
    set(SPINNAKER_API_INCLUDE_DIR /usr/include/spinnaker)
    mark_as_advanced(SPINNAKER_API_INCLUDE_DIR)
    set(SPINNAKER_API_LIBRARY_DIR /usr/lib)
    mark_as_advanced(SPINNAKER_API_LIBRARY_DIR)
    set(SPINNAKER_API_BINARY_DIR /usr/lib)
    mark_as_advanced(SPINNAKER_API_BINARY_DIR)

    # version
    spinnaker_get_version("/usr/include/spinnaker/System.h")
  ENDIF()
ENDIF()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SPINNAKER_API
  FOUND_VAR SPINNAKER_API_FOUND
  REQUIRED_VARS SPINNAKER_API_INCLUDE_DIR SPINNAKER_API_LIBRARY_DIR SPINNAKER_API_BINARY_DIR
  VERSION_VAR SPINNAKER_API_VERSION
)