###############################################################################
# Find Pco Technology PicoScope SDK
#
#     find_package(PicoScopeSDK)
#
# Variables defined by this module:
#
#  PicoScopeSDK_FOUND               True if PicoScope SDK found
#  PicoScopeSDK_VERSION             The version of PicoScope SDK
#  PicoScopeSDK_INCLUDE_DIR         The location(s) of PicoScope SDK headers
#  PicoScopeSDK_LIBRARY_DIR         Libraries needed to use PicoScope SDK
#  PicoScopeSDK_BINARY_DIR          Binaries needed to use PicoScope SDK

IF(WIN32 AND CMAKE_SIZEOF_VOID_P EQUAL 4)
  # Windows 32 bit path hints
  SET(PICOSCOPE_SDK_PATH_HINTS
    "../PLTools/PicoScope/win32"
    "../../PLTools/PicoScope/win32"
    "../trunk/PLTools/PicoScope/win32"
    "$ENV{${_x86env}}/Pico Technology/SDK"
    "C:/Program Files (x86)/Pico Technology/SDK"
    )
ELSEIF(WIN32 AND CMAKE_SIZEOF_VOID_P EQUAL 8)
  # Windows 64 bit path hints
  SET(PICOSCOPE_SDK_PATH_HINTS
    "../PLTools/PicoScope/x64"
    "../../PLTools/PicoScope/windows/x64"
    "../trunk/PLTools/PicoScope/windows/x64"
    "$ENV{PROGRAMFILES}/Pico Technology/SDK"
    "C:/Program Files/Pico Technology/SDK"
    )
ELSEIF(UNIX)
  #Unix path hints
    SET(PICOSCOPE_SDK_PATH_HINTS
      "../PLTools/PicoScope/linux"
      "../../PLTools/PicoScope/linux"
      "../trunk/PLTools/PicoScope/linux"
      )
ENDIF()

find_path(PICO_SDK_DIR "/inc/ps2000.h"
  PATHS ${PICOSCOPE_SDK_PATH_HINTS}
  DOC "PicoScope SDK directory")

IF (PICO_SDK_DIR)
  # Include directories
  set(PicoScopeSDK_INCLUDE_DIR ${PICO_SDK_DIR}/inc)
  mark_as_advanced(PicoScopeSDK_INCLUDE_DIR)

  # Libraries
  set(PicoScopeSDK_LIBRARY_DIR ${PICO_SDK_DIR}/lib)
  mark_as_advanced(PicoScopeSDK_LIBRARY_DIR)

  # Binary directory
  set(PicoScopeSDK_BINARY_DIR ${PICO_SDK_DIR}/lib)
  mark_as_advanced(PicoScopeSDK_BINARY_DIR)

  #Version
  #TODO: properly set SDK version using REGEX
  set(PicoScopeSDK_VERSION "2.3.0.6")

ENDIF ()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PicoScopeSDK
  FOUND_VAR PicoScopeSDK_FOUND
  REQUIRED_VARS PicoScopeSDK_INCLUDE_DIR PicoScopeSDK_LIBRARY_DIR PicoScopeSDK_BINARY_DIR
  VERSION_VAR PicoScopeSDK_VERSION
)