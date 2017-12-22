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
#  ATRACSYS_SDK_LIBRARY_DIR          Libraries needed to use sTk Passive Tracking SDK
#  ATRACSYS_SDK_BINARY_DIR           Binaries needed to use sTk Passive Tracking SDK

SET(ATRACSYS_SDK_PATH_HINTS
  "$ENV{PROGRAMFILES}/Atracsys/sTk Passive Tracking SDK"
  "$ENV{PROGRAMW6432}/Atracsys/sTk Passive Tracking SDK"
  "C:/Program Files (x86)/Atracsys/sTk Passive Tracking SDK"
  "C:/Program Files/Atracsys/sTk Passive Tracking SDK"
  "../PLTools/Atracsys/sTk Passive Tracking SDK"
  "../../PLTools/Atracsys/sTk Passive Tracking SDK"
  "../trunk/PLTools/Atracsys/sTk Passive Tracking SDK"
  "${CMAKE_CURRENT_BINARY_DIR}/PLTools/Atracsys/sTk Passive Tracking SDK"
  )

if( WIN32 )
    find_path(ATRACSYS_SDK_DIR versions.txt
        PATHS ${ATRACSYS_SDK_PATH_HINTS}
        DOC "Atracsys sTk Passive Tracking SDK directory")
else()
    find_path( ATRACSYS_SDK_DIR include/ftkTypes.h DOC "Directory where ftkTypes.h is located" )
endif()

if (ATRACSYS_SDK_DIR)
  # Include directories
  set(ATRACSYS_SDK_INCLUDE_DIR ${ATRACSYS_SDK_DIR}/include)
  mark_as_advanced(ATRACSYS_SDK_INCLUDE_DIR)

  # Libraries
  if( WIN32 )
    find_path(AtracsysSDK_LIBRARY_DIR
            NAMES fusionTrack32${CMAKE_STATIC_LIBRARY_SUFFIX}
            PATHS "${ATRACSYS_SDK_DIR}/lib" NO_DEFAULT_PATH)

    find_path(AtracsysSDK_BINARY_DIR
            NAMES fusionTrack32${CMAKE_SHARED_LIBRARY_SUFFIX}
            PATHS "${ATRACSYS_SDK_DIR}/bin" NO_DEFAULT_PATH)
  else()
    find_library( AtracsysSDK_LIBRARY_DIR
            NAMES fusionTrack32 
            PATHS "${ATRACSYS_SDK_DIR}/lib" NO_DEFAULT_PATH )
    set( AtracsysSDK_BINARY_DIR ${AtracsysSDK_LIBRARY_DIR} )
  endif()

  set(ATRACSYS_SDK_LIBRARY_DIR ${AtracsysSDK_LIBRARY_DIR})
  set(ATRACSYS_SDK_BINARY_DIR ${AtracsysSDK_BINARY_DIR})
  mark_as_advanced(AtracsysSDK_LIBRARY_DIR)
  mark_as_advanced(AtracsysSDK_BINARY_DIR)

  #Version
  #TODO: properly set SDK version using regex
  set(ATRACSYS_SDK_VERSION "3.1.1")

endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ATRACSYS_SDK
  FOUND_VAR ATRACSYS_SDK_FOUND
  REQUIRED_VARS ATRACSYS_SDK_INCLUDE_DIR ATRACSYS_SDK_LIBRARY_DIR #ATRACSYS_SDK_BINARY_DIR 
  VERSION_VAR ATRACSYS_SDK_VERSION
)
