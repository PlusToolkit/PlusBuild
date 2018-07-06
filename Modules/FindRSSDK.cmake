###############################################################################
# Find Intel RealSense SDK 2.0
#
#     find_package(RSSDK)
#
# Variables defined by this module:
#
#  RSSDK_FOUND                 True if RealSense SDK was found
#  RSSDK_INCLUDE_DIRS          The location(s) of RealSense SDK headers
#  RSSDK_LIBRARIES             Libraries needed to use RealSense SDK

SET(RSSDK_PATHS
PATHS
  "$ENV{PROGRAMFILES}/Intel RealSense SDK 2.0"
  "$ENV{PROGRAMW6432}/Intel RealSense SDK 2.0"
  "C:/Program Files (x86)/Intel RealSense SDK 2.0"
  "C:/Program Files/Intel RealSense SDK 2.0"
  ../PLTools/IntelRealSense
  ../../PLTools/IntelRealSense
  ../PLTools/trunk/IntelRealSense
)
find_path(RSSDK_DIR include/librealsense2/rsutil.h
  PATHS ${RSSDK_PATHS})

if(RSSDK_DIR)
  # Include directories
  set(RSSDK_INCLUDE_DIR ${RSSDK_DIR}/include/librealsense2 CACHE FILEPATH "RealSense header files directory.")
  mark_as_advanced(RSSDK_INCLUDE_DIR)
  
  # Libraries
  set(RSSDK_LIB_NAME realsense2${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(RSSDK_BIN_NAME realsense2${CMAKE_SHARED_LIBRARY_SUFFIX})
  
  SET(PLATFORM_SUFFIX "x86")
  IF (CMAKE_HOST_WIN32 AND CMAKE_CL_64 )
    SET(PLATFORM_SUFFIX "x64")
  ENDIF (CMAKE_HOST_WIN32 AND CMAKE_CL_64 )

  find_library(RSSDK_LIBRARY
               NAMES ${RSSDK_LIB_NAME}
               PATHS "${RSSDK_DIR}/lib/${PLATFORM_SUFFIX}/" NO_DEFAULT_PATH
               PATH_SUFFIXES ${PLATFORM_SUFFIX})
  
  find_path(RSSDK_BINARY_DIR
               NAMES ${RSSDK_BIN_NAME}
               PATHS "${RSSDK_DIR}/bin/${PLATFORM_SUFFIX}/" NO_DEFAULT_PATH
               PATH_SUFFIXES ${PLATFORM_SUFFIX})

  set(RSSDK_LIB ${RSSDK_LIBRARY})
  mark_as_advanced(RSSDK_LIB)
  set(RSSDK_BIN ${RSSDK_BINARY_DIR}/${RSSDK_BIN_NAME})
  mark_as_advanced(RSSDK_BIN)
  
  # Version
  set(RSSDK_VERSION "2.0")
  
endif()  

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(RSSDK
  FOUND_VAR RSSDK_FOUND
  REQUIRED_VARS RSSDK_LIB RSSDK_BIN RSSDK_INCLUDE_DIR
  VERSION_VAR RSSDK_VERSION
)

ADD_LIBRARY(RSSDK SHARED IMPORTED)

if(MSVC)
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /NODEFAULTLIB:LIBCMTD")
endif()
