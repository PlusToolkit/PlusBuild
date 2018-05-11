###############################################################################
# Find Intel RealSense SDK 2.0 Camera
#
#     find_package(RSSDKCAM)
#
# Variables defined by this module:
#
#  RSSDKCAM_FOUND                 True if RealSense SDK was found
#  RSSDKCAM_INCLUDE_DIRS          The location(s) of RealSense SDK headers
#  RSSDKCAM_LIBRARIES             Libraries needed to use RealSense SDK

  # Include directories
  
  SET(RSSDKCAM_PATHS
	PATHS "$ENV{PROGRAMFILES}/Intel RealSense SDK 2.0"
		"$ENV{PROGRAMW6432}/Intel RealSense SDK 2.0"
		"C:/Program Files (x86)/Intel RealSense SDK 2.0"
		"C:/Program Files/Intel RealSense SDK 2.0"
  )
find_path(RSSDKCAM_DIR include/librealsense2/rsutil.h
  PATHS ${RSSDKCAM_PATHS})

if(RSSDKCAM_DIR)
  # Include directories
  set(RSSDKCAM_INCLUDE_DIR ${RSSDKCAM_DIR}/include/librealsense2 CACHE FILEPATH "RealSense .h files path.")
  mark_as_advanced(RSSDKCAM_INCLUDE_DIR)
  
  # Libraries
  set(RSSDKCAM_LIB_NAME realsense2.lib)


  SET(PLATFORM_SUFFIX "x86")
  IF (CMAKE_HOST_WIN32 AND CMAKE_CL_64 )
    SET(PLATFORM_SUFFIX "x64")
  ENDIF (CMAKE_HOST_WIN32 AND CMAKE_CL_64 )

  find_library(RSSDKCAM_LIBRARY
               NAMES ${RSSDKCAM_LIB_NAME}
               PATHS "${RSSDKCAM_DIR}/lib/${PLATFORM_SUFFIX}/" NO_DEFAULT_PATH
               PATH_SUFFIXES ${PLATFORM_SUFFIX})
  
  set(RSSDKCAM_BIN_NAME realsense2.dll)  
  
  find_path(RSSDKCAM_BINARY
               NAMES ${RSSDKCAM_BIN_NAME}
               PATHS "${RSSDKCAM_DIR}/bin/${PLATFORM_SUFFIX}/" NO_DEFAULT_PATH
               PATH_SUFFIXES ${PLATFORM_SUFFIX})
			   
  set (RSSDCAM_BIN_FILE ${RSSDKCAM_BINARY}/${RSSDKCAM_BIN_NAME})
  set(RSSDKCAM_LIB optimized ${RSSDKCAM_LIBRARY})
  mark_as_advanced(RSSDKCAM_LIBRARY )
  
  set(RSSDKCAM_BIN optimized ${RSSDKCAM_BINARY})
  mark_as_advanced(RSSDKCAM_BINARY )
  
  # Version
  set(RSSDKCAM_VERSION "2.0")
  
endif()  

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(RSSDKCAM
  FOUND_VAR RSSDKCAM_FOUND
  REQUIRED_VARS RSSDKCAM_LIB RSSDKCAM_BIN RSSDKCAM_INCLUDE_DIR
  VERSION_VAR RSSDKCAM_VERSION
)

ADD_LIBRARY(RSSDKCAM SHARED IMPORTED)
    
if(MSVC)
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /NODEFAULTLIB:LIBCMTD")
endif()
