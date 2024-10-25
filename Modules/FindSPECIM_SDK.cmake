###############################################################################
# Find SPECIM - LUMO SDK
#
#     find_package(SPECIMSDK)
#
# Variables defined by this module:
#
#  SPECIMSDK_FOUND                True if SDK found
#  SPECIMSDK_VERSION              The version of SDK
#  SPECIMSDK_INCLUDE_DIR          The location(s) of SDK headers
#  SPECIMSDK_LIBRARY_DIR          Libraries needed to use SDK
#  SPECIMSDK_BINARY_DIR           Binaries needed to use SDK
#  "$ENV{ProgramFiles\(x86\)}/Specim/SDKs/Lumo_Sensor_SDK"
#  "C:/Program Files (x86)/Specim/SDKs/Lumo_Sensor_SDK"

SET(SPECIM_SDK_PATH_HINTS
  "$ENV{ProgramFiles\(x86\)}/Specim/SDKs/Lumo_Sensor_SDK"
  )

find_path(SPECIM_SDK_DIR include/SI_sensor.h
  PATHS ${SPECIM_SDK_PATH_HINTS}
  DOC "SPECIM - LUMO Sensor SDK directory")

if (SPECIM_SDK_DIR)
  # Include directories
  set(SPECIM_SDK_INCLUDE_DIR ${SPECIM_SDK_DIR}/include)
  mark_as_advanced(SPECIM_SDK_INCLUDE_DIR)


  # Libraries
  SET(PLATFORM_SUFFIX "")
  SET(LIB_FILENAME "SpecSensor.lib")
  SET(SDK_FILENAME "SpecSensor.dll")
 
  IF (CMAKE_HOST_WIN32 AND CMAKE_CL_64 )
    SET(PLATFORM_LIB_SUFFIX "bin/x64")
    SET(PLATFORM_BIN_SUFFIX "bin/x64")
  ENDIF (CMAKE_HOST_WIN32 AND CMAKE_CL_64 )

  IF (CMAKE_HOST_WIN32 AND NOT CMAKE_CL_64 )
    SET(PLATFORM_LIB_SUFFIX "bin/Win32")
    SET(PLATFORM_BIN_SUFFIX "bin/Win32")
  ENDIF (CMAKE_HOST_WIN32 AND NOT CMAKE_CL_64 )



  find_library(SPECIM_SDK_LIBRARY
            NAMES ${LIB_FILENAME}
            PATHS "${SPECIM_SDK_DIR}/${PLATFORM_LIB_SUFFIX}/" NO_DEFAULT_PATH
            PATH_SUFFIXES ${PLATFORM_SUFFIX})

  find_path(SPECIM_SDK_BINARY
            NAMES ${SDK_FILENAME} 
            PATHS "${SPECIM_SDK_DIR}/${PLATFORM_BIN_SUFFIX}/" NO_DEFAULT_PATH
            PATH_SUFFIXES ${PLATFORM_SUFFIX})

 
   set(SPECIM_SDK_DLLS 
    ${SPECIM_SDK_BINARY}/${SDK_FILENAME}
    ${SPECIM_SDK_BINARY}/grab014.dll
    ${SPECIM_SDK_BINARY}/PvBase64.dll
    ${SPECIM_SDK_BINARY}/PvStream64.dll
    ${SPECIM_SDK_BINARY}/tbb.dll
    ${SPECIM_SDK_BINARY}/PvDevice64.dll
    ${SPECIM_SDK_BINARY}/tbbmalloc.dll)
	
  mark_as_advanced(SPECIM_SDK_LIBRARY)
  mark_as_advanced(SPECIM_SDK_BINARY)

  set(SPECIM_BIN_FILE ${SPECIM_SDK_BINARY} "/" ${SDK_FILENAME})

  set(SPECIM_SDK_VERSION "1.0")

endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SPECIM_SDK
  FOUND_VAR SPECIM_SDK_FOUND
  REQUIRED_VARS SPECIM_SDK_DIR SPECIM_SDK_LIBRARY SPECIM_SDK_INCLUDE_DIR
  VERSION_VAR SPECIM_SDK_VERSION
)
