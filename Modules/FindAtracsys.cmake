###############################################################################
# Find Atracsys sTk Passive Tracking SDK
#
#     find_package(Atracsys)
#
# Variables defined by this module:
#
#  ATRACSYS_SDK_FOUND                True if Atracsys sTk Passive Tracking SDK was found
#  ATRACSYS_SDK_VERSION              The version of sTkPassive Tracking SDK
#  ATRACSYS_SDK_INCLUDE_DIR          The location of sTk Passive Tracking SDK headers
#  ATRACSYS_SDK_LIBRARY              Library needed to use sTk Passive Tracking SDK
#  ATRACSYS_SDK_BINARY_DIR           Binaries needed to use sTk Passive Tracking SDK

# PLTools
SET(PLTOOLS_ATRACSYS_PATHS "")
MARK_AS_ADVANCED(PLTOOLS_ATRACSYS_PATHS)

IF(PLUS_USE_ATRACSYS_DEVICE_TYPE STREQUAL "stk")
  # use spryTrack SDK
	IF(WIN32 AND NOT CMAKE_CL_64)
    # Windows 32 bit spryTrack path hints
    SET(ATRACSYS_SDK_PATH_HINTS
      "$ENV{PROGRAMFILES(x86)}/Atracsys/spryTrack SDK x86"
      "C:/Program Files (x86)/Atracsys/spryTrack SDK x86"
    )
  ELSEIF(WIN32 AND CMAKE_CL_64)
    # Windows 64 bit spryTrack path hints
    SET(ATRACSYS_SDK_PATH_HINTS
      "$ENV{PROGRAMFILES}/Atracsys/spryTrack SDK x64"
      "C:/Program Files/Atracsys/spryTrack SDK x64"
    )
  ELSEIF(UNIX)
    #Unix spryTrack path hints
    
  ENDIF()
ELSEIF(PLUS_USE_ATRACSYS_DEVICE_TYPE STREQUAL "ftk")
  # use fusionTrack SDK
  IF(WIN32 AND NOT CMAKE_CL_64)
    message(FATAL_ERROR "There is no support for fusionTrack devices on win32. Please choose an x64 generator and use the x64 fTk SDK.")
  ELSEIF(WIN32 AND CMAKE_CL_64)
    # Windows 64 bit fusionTrack path hints
    SET(ATRACSYS_SDK_PATH_HINTS
      "$ENV{PROGRAMFILES}/Atracsys/fusionTrack SDK x64"
      "C:/Program Files/Atracsys/fusionTrack SDK x64"
      )
  ELSEIF(UNIX)
    #Unix spryTrack path hints
    
  ENDIF()
ELSEIF(PLUS_USE_ATRACSYS_DEVICE_TYPE STREQUAL "ftksim")
  SET(ATRACSYS_SDK_PATH_HINTS
      "$ENV{PROGRAMFILES}/Atracsys/simulator SDK x64"
      "C:/Program Files/Atracsys/simulator SDK x64"
      )
ENDIF()
MARK_AS_ADVANCED(ATRACSYS_SDK_PATH_HINTS)

find_path( ATRACSYS_SDK_DIR include/ftkTypes.h
  PATHS ${ATRACSYS_SDK_PATH_HINTS}
  DOC "Atracsys SDK directory." )
MARK_AS_ADVANCED(ATRACSYS_SDK_DIR)
  
IF(ATRACSYS_SDK_DIR)
  # Set include directories
  SET(ATRACSYS_SDK_INCLUDE_DIR ${ATRACSYS_SDK_DIR}/include)
  MARK_AS_ADVANCED(ATRACSYS_SDK_INCLUDE_DIR)

  IF(WIN32)
    # bitness suffix
    IF(CMAKE_CL_64)
      SET(ATRACSYS_BITNESS_SUFFIX "64")
    ELSE()
      SET(ATRACSYS_BITNESS_SUFFIX "32")
    ENDIF()
    
    # Library
    FIND_LIBRARY(AtracsysSDK_LIBRARY
      NAMES fusionTrack${ATRACSYS_BITNESS_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
      PATHS "${ATRACSYS_SDK_DIR}/lib" NO_DEFAULT_PATH)
    
    # Binaries
    FIND_PATH(AtracsysSDK_BINARY_DIR
      NAMES fusionTrack${ATRACSYS_BITNESS_SUFFIX}${CMAKE_SHARED_LIBRARY_SUFFIX}
      PATHS "${ATRACSYS_SDK_DIR}/bin" NO_DEFAULT_PATH)
      
  ELSEIF(UNIX)
  
  ENDIF()

  SET(ATRACSYS_SDK_LIBRARY ${AtracsysSDK_LIBRARY})
  MARK_AS_ADVANCED(AtracsysSDK_LIBRARY)
  SET(ATRACSYS_SDK_BINARY_DIR ${AtracsysSDK_BINARY_DIR})
  MARK_AS_ADVANCED(AtracsysSDK_BINARY_DIR)
  
  #Version
  #TODO: properly set SDK version using regex
  set(ATRACSYS_SDK_VERSION "3.1.1")

ENDIF()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ATRACSYS_SDK
  FOUND_VAR ATRACSYS_SDK_FOUND
  REQUIRED_VARS ATRACSYS_DEVICE_TYPE ATRACSYS_SDK_INCLUDE_DIR ATRACSYS_SDK_LIBRARY ATRACSYS_SDK_BINARY_DIR 
  VERSION_VAR ATRACSYS_SDK_VERSION
)
