###############################################################################
# Find OptiTrack NatNet SDK
#
#     find_package(NatNetSDK)
#
# Variables defined by this module:
#
#  NATNET_SDK_FOUND                True if OptiTrack NatNet SDK was found
#  NATNET_SDK_VERSION              The version of NatNet SDK
#  NATNET_SDK_INCLUDE_DIR          The location(s) of NatNet SDK headers
#  NATNET_SDK_LIBRARY_DIR          Libraries needed to use NatNet SDK
#  NATNET_SDK_BINARY_DIR           Binaries needed to use NatNet SDK

SET(NATNET_SDK_PATH_HINTS
  "../PLTools/OptiTrack/NatNet-3.1"
  "../../PLTools/OptiTrack/NatNet-3.1"
  "../trunk/PLTools/OptiTrack/NatNet-3.1"
  "${CMAKE_CURRENT_BINARY_DIR}/PLTools/OptiTrack/NatNet-3.1"
  "$ENV{PROGRAMFILES}/OptiTrack/NatNetSDK"
  "$ENV{PROGRAMW6432}/OptiTrack/NatNetSDK"
  "C:/Program Files (x86)/OptiTrack/NatNetSDK"
  "C:/Program Files/OptiTrack/NatNetSDK"
  )

find_path(NATNET_SDK_DIR Readme-NatNet.txt
  PATHS ${NATNET_SDK_PATH_HINTS}
  DOC "OptiTrack NatNet SDK directory")

if (NATNET_SDK_DIR)
  # Include directories
  set(NATNET_SDK_INCLUDE_DIR ${NATNET_SDK_DIR}/include)
  mark_as_advanced(NATNET_SDK_INCLUDE_DIR)

  # Libraries
  SET(PLATFORM_SUFFIX "/x86/")
  IF (CMAKE_HOST_WIN32 AND CMAKE_CL_64)
    SET(PLATFORM_SUFFIX "/x64/")   
  ENDIF()

  find_path(NatNetSDK_LIBRARY_DIR
            NAMES NatNetLib${CMAKE_STATIC_LIBRARY_SUFFIX}
            PATHS "${NATNET_SDK_DIR}/lib" NO_DEFAULT_PATH
            PATH_SUFFIXES ${PLATFORM_SUFFIX})

  find_path(NatNetSDK_BINARY_DIR
            NAMES NatNetLib${CMAKE_SHARED_LIBRARY_SUFFIX}
            PATHS "${NATNET_SDK_DIR}/lib" NO_DEFAULT_PATH
            PATH_SUFFIXES ${PLATFORM_SUFFIX})

  set(NATNET_SDK_LIBRARY_DIR ${NatNetSDK_LIBRARY_DIR})
  set(NATNET_SDK_BINARY_DIR ${NatNetSDK_BINARY_DIR})
  mark_as_advanced(NatNetSDK_LIBRARY_DIR)
  mark_as_advanced(NatNetSDK_BINARY_DIR)

  #Version
  #TODO: properly set SDK version using REGEX from NatNetTypes.h
  set(NATNET_SDK_VERSION "3.1")

endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(NATNET_SDK
  FOUND_VAR NATNET_SDK_FOUND
  REQUIRED_VARS NATNET_SDK_LIBRARY_DIR NATNET_SDK_BINARY_DIR NATNET_SDK_INCLUDE_DIR
  VERSION_VAR NATNET_SDK_VERSION
)