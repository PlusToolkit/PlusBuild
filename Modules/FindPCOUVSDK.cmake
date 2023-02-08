###############################################################################
# Find PCO UV SDK
#
#     find_package(PCOUVSDK)
#
# Variables defined by this module:
#
#  PCOUVSDK_FOUND                True if UV SDK found
#  PCOUVSDK_VERSION              The version of UV SDK
#  PCOUVSDK_INCLUDE_DIR          The location(s) of UV SDK headers
#  PCOUVSDK_LIBRARY_DIR          Libraries needed to use UV SDK
#  PCOUVSDK_BINARY_DIR           Binaries needed to use UV SDK

SET(PCOUV_SDK_PATH_HINTS
  "$ENV{APPDATA}/PCO Digital Camera Toolbox/pco.sdk"
  )

find_path(PCOUV_SDK_DIR include/SC2_CamExport.h
  PATHS ${PCOUV_SDK_PATH_HINTS}
  DOC "PCO UV SDK directory")

if (PCOUV_SDK_DIR)
  # Include directories
  set(PCOUV_SDK_INCLUDE_DIR ${PCOUV_SDK_DIR}/include)
  mark_as_advanced(PCOUV_SDK_INCLUDE_DIR)


  # Libraries
  SET(PLATFORM_SUFFIX "")
  SET(LIB_FILENAME "SC2_Cam.lib")
  SET(SDK_FILENAME "SC2_Cam.dll")

  IF (CMAKE_HOST_WIN32 AND CMAKE_CL_64 )
    SET(PLATFORM_LIB_SUFFIX "lib64")
    SET(PLATFORM_BIN_SUFFIX "bin64")
  ENDIF (CMAKE_HOST_WIN32 AND CMAKE_CL_64 )

  IF (CMAKE_HOST_WIN32 AND NOT CMAKE_CL_64 )
    SET(PLATFORM_LIB_SUFFIX "lib")
    SET(PLATFORM_BIN_SUFFIX "bin")
  ENDIF (CMAKE_HOST_WIN32 AND NOT CMAKE_CL_64 )



  find_library(PCOUV_SDK_LIBRARY
            NAMES ${LIB_FILENAME}
            PATHS "${PCOUV_SDK_DIR}/${PLATFORM_LIB_SUFFIX}/" NO_DEFAULT_PATH
            PATH_SUFFIXES ${PLATFORM_SUFFIX})

  find_path(PCOUV_SDK_BINARY
            NAMES ${SDK_FILENAME}
            PATHS "${PCOUV_SDK_DIR}/${PLATFORM_BIN_SUFFIX}/" NO_DEFAULT_PATH
            PATH_SUFFIXES ${PLATFORM_SUFFIX})

 
  mark_as_advanced(PCOUV_SDK_LIBRARY)
  mark_as_advanced(PCOUV_SDK_BINARY)

  set(PCOUV_BIN_FILE ${PCOUV_SDK_BINARY} "/" ${SDK_FILENAME})

  set(PCOUV_SDK_VERSION "1.0")

endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PCOUVSDK
  FOUND_VAR PCOUVSDK_FOUND
  REQUIRED_VARS PCOUV_SDK_DIR PCOUV_SDK_LIBRARY PCOUV_SDK_INCLUDE_DIR
  VERSION_VAR PCOUV_SDK_VERSION
)
