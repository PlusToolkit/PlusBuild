###############################################################################
# Find Thermal Expert Q1 SDK 
#
#     find_package(TEQ1SDK)
#
# Variables defined by this module:
#
#  TEQ1SDK_FOUND                True if Q1 SDK found
#  TEQ1SDK_VERSION              The version of Q1 SDK
#  TEQ1SDK_INCLUDE_DIR          The location(s) of Q1 SDK headers
#  TEQ1SDK_LIBRARY_DIR          Libraries needed to use Q1 SDK
#  TEQ1SDK_BINARY_DIR           Binaries needed to use Q1 SDK

SET(TEQ1_SDK_PATH_HINTS
  "$ENV{PROGRAMFILES}/TE_Q1Plus/SDK"
  "$ENV{PROGRAMW6432}/TE_Q1Plus/SDK"
  "C:/Program Files (x86)/TE_Q1Plus/SDK"
  "C:/Program Files/TE_Q1Plus/SDK"
  "${CMAKE_CURRENT_BINARY_DIR}/PLTools/TE_Q1Plus/SDK"
  )

find_path(TEQ1_SDK_DIR include/i3system_TE.h
  PATHS ${TEQ1_SDK_PATH_HINTS}
  DOC "Thermal Expert Q1 SDK directory")
  
if (TEQ1_SDK_DIR)
  # Include directories
  set(TEQ1_SDK_INCLUDE_DIR ${TEQ1_SDK_DIR}/include)
  mark_as_advanced(TEQ1_SDK_INCLUDE_DIR)


  # Libraries
  SET(PLATFORM_SUFFIX "")
  SET(BIN_FILENAME "")
  SET(FILENAME "i3system_TE")
  
  IF (CMAKE_HOST_WIN32 AND CMAKE_CL_64 )
    SET(PLATFORM_SUFFIX "x64")
	SET(SDK_FILENAME "i3system_TE_x64.dll")
	SET(SDK_FILENAME_IMG "i3system_imgproc_x64.dll")
	SET(SDK_FILENAME_USB "i3system_USB_DLL_x64.dll")
	SET(LIB_FILENAME "i3system_TE_x64.lib")
  ENDIF (CMAKE_HOST_WIN32 AND CMAKE_CL_64 )
  
  IF (CMAKE_HOST_WIN32 AND NOT CMAKE_CL_64 )
    SET(PLATFORM_SUFFIX "x86")
	SET(BIN_FILENAME "${PLATFORM_SUFFIX}_${FILENAME}")
	SET(SDK_FILENAME "${BIN_FILENAME}.dll")
	SET(LIB_FILENAME "${FILENAME}.lib")
	
	SET(SDK_FILENAME "x86_i3system_TE.dll")
	SET(SDK_FILENAME_IMG "x86_i3system_imgproc.dll")
	SET(SDK_FILENAME_USB "x86_i3system_USB_DLL_V2_1.dll")
	SET(LIB_FILENAME "i3system_TE.lib")
  ENDIF (CMAKE_HOST_WIN32 AND NOT CMAKE_CL_64 )

  find_library(TEQ1_SDK_LIBRARY
            NAMES ${LIB_FILENAME}
            PATHS "${TEQ1_SDK_DIR}/lib/lib${PLATFORM_SUFFIX}/" NO_DEFAULT_PATH
            PATH_SUFFIXES ${PLATFORM_SUFFIX}) 

  set(TEQ1_BIN_FILE ${TEQ1_SDK_BINARY} "/" ${SDK_FILENAME})
  
  find_path(TEQ1_SDK_BINARY
            NAMES ${SDK_FILENAME}
            PATHS "${TEQ1_SDK_DIR}/bin/bin${PLATFORM_SUFFIX}/" NO_DEFAULT_PATH
            PATH_SUFFIXES ${PLATFORM_SUFFIX})

  mark_as_advanced(TEQ1_SDK_LIBRARY)
  mark_as_advanced(TEQ1_SDK_BINARY)

  set(TEQ1_SDK_VERSION "2")

endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TEQ1SDK
  FOUND_VAR TEQ1SDK_FOUND
  REQUIRED_VARS TEQ1_SDK_DIR TEQ1_SDK_BINARY TEQ1_SDK_LIBRARY TEQ1_SDK_INCLUDE_DIR
  VERSION_VAR TEQ1_SDK_VERSION
)