###############################################################################
# Find Thermal Expert EV2 SDK
#
#     find_package(TEEV2SDK)
#
# Variables defined by this module:
#
#  TEEV2SDK_FOUND                True if EV2 SDK found
#  TEEV2SDK_VERSION              The version of EV2 SDK
#  TEEV2SDK_INCLUDE_DIR          The location(s) of EV2 SDK headers
#  TEEV2SDK_LIBRARY_DIR          Libraries needed to use EV2 SDK
#  TEEV2SDK_BINARY_DIR           Binaries needed to use EV2 SDK

SET(TEEV2_SDK_PATH_HINTS
  "../ThirdParty/TE_SDK"
  "../Plus-bin/TE_SDK"
  
  )


find_path(TEEV2_SDK_DIR include/i3system_TE.h
  PATHS ${TEEV2_SDK_PATH_HINTS}
  DOC "Thermal Expert EV2 SDK directory")

if (TEEV2_SDK_DIR)
  # Include directories
  set(TEEV2_SDK_INCLUDE_DIR ${TEEV2_SDK_DIR}/include)
  mark_as_advanced(TEEV2_SDK_INCLUDE_DIR)


  # Libraries
  SET(PLATFORM_SUFFIX "")
  SET(BIN_FILENAME "")
  SET(FILENAME "i3system_TE")

  IF (CMAKE_HOST_WIN32 AND CMAKE_CL_64 )
    SET(PLATFORM_SUFFIX "x64")
	SET(SDK_FILENAME "i3system_TE_x64.dll")
	SET(SDK_FILENAME_IMG "i3system_imgproc_impl_x64.dll")
	SET(SDK_FILENAME_USB "i3system_USB_DLL_V2_2_x64.dll")
	SET(LIB_FILENAME "i3system_TE_x64.lib")
  ENDIF (CMAKE_HOST_WIN32 AND CMAKE_CL_64 )

  IF (CMAKE_HOST_WIN32 AND NOT CMAKE_CL_64 )
    SET(PLATFORM_SUFFIX "x86")
#	SET(BIN_FILENAME "${PLATFORM_SUFFIX}_${FILENAME}")
#	SET(BIN_FILENAME "${FILENAME}")
#	SET(SDK_FILENAME "${BIN_FILENAME}.dll")
#	SET(LIB_FILENAME "${FILENAME}.lib")
	SET(SDK_FILENAME "i3system_TE.dll")
	SET(SDK_FILENAME_IMG "i3system_imgproc.dll")
	SET(SDK_FILENAME_USB "i3system_USB_DLL_V2_2.dll")
	SET(LIB_FILENAME "i3system_TE.lib")
  ENDIF (CMAKE_HOST_WIN32 AND NOT CMAKE_CL_64 )


#  find_library(TEEV2_SDK_LIBRARY
#            NAMES ${LIB_FILENAME}
#            PATHS "${TEEV2_SDK_DIR}/lib/lib${PLATFORM_SUFFIX}/" NO_DEFAULT_PATH
#            PATH_SUFFIXES ${PLATFORM_SUFFIX})

  find_library(TEEV2_SDK_LIBRARY
            NAMES ${LIB_FILENAME}
            PATHS "${TEEV2_SDK_DIR}/lib/${PLATFORM_SUFFIX}/" NO_DEFAULT_PATH
            PATH_SUFFIXES ${PLATFORM_SUFFIX})

#  find_path(TEEV2_SDK_BINARY
#            NAMES ${SDK_FILENAME}
#            PATHS "${TEEV2_SDK_DIR}/bin/bin${PLATFORM_SUFFIX}/" NO_DEFAULT_PATH
#            PATH_SUFFIXES ${PLATFORM_SUFFIX})

  find_path(TEEV2_SDK_BINARY
            NAMES ${SDK_FILENAME}
            PATHS "${TEEV2_SDK_DIR}/bin/${PLATFORM_SUFFIX}/" NO_DEFAULT_PATH
            PATH_SUFFIXES ${PLATFORM_SUFFIX})

 
  mark_as_advanced(TEEV2_SDK_LIBRARY)
  mark_as_advanced(TEEV2_SDK_BINARY)

  set(TEEV2_BIN_FILE ${TEEV2_SDK_BINARY} "/" ${SDK_FILENAME})

  set(TEEV2_SDK_VERSION "1.0")

endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TEEV2SDK
  FOUND_VAR TEEV2SDK_FOUND
  REQUIRED_VARS TEEV2_SDK_DIR TEEV2_SDK_BINARY TEEV2_SDK_LIBRARY TEEV2_SDK_INCLUDE_DIR
  VERSION_VAR TEEV2_SDK_VERSION
)