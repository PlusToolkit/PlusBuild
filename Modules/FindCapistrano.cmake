# Find the Capistrano cSDK
# This module defines
# CAPISTRANO_FOUND - Capistrano SDK has been found on this system
# CAPISTRANO_INCLUDE_DIR - where to find the header files
# CAPISTRANO_LIBRARY_DIR - libraries to be linked
# CAPISTRANO_BINARY_DIR - common shared libraries to be installed
# CAPISTRANO_LIBRARY_USBPROBE_NAME - USBprobe filename in the lib dir
# CAPISTRANO_BINARY_USBPROBE_NAME - USBprobe filename in the bin dir
# CAPISTRANO_LIBRARY_BMODE_NAME - Bmode filename in the lib dir
# CAPISTRANO_BINARY_BMODE_NAME - Bmode filename in the bin dir

SET(Capistrano_SDK_VERSION "cSDK2023" CACHE STRING "Which cSDK version to build Plus against")
SET(_csdk_versions "cSDK2023" "cSDK2019.3" "cSDK2019.2" "cSDK2019" "cSDK2018" "cSDK2016" "cSDK2013")
set_property(CACHE Capistrano_SDK_VERSION PROPERTY STRINGS ${_csdk_versions})

unset(Capistrano_INCLUDE_DIR CACHE)
unset(Capistrano_WIN32_LIBRARY_DIR CACHE)
unset(Capistrano_WIN64_LIBRARY_DIR CACHE)
unset(Capistrano_WIN32_BINARY_DIR CACHE)
unset(Capistrano_WIN64_BINARY_DIR CACHE)

SET(Capistrano_FIND_FILE "USBprobe")
IF(Capistrano_SDK_VERSION STREQUAL "cSDK2023" OR
   Capistrano_SDK_VERSION STREQUAL "cSDK2019.3" OR
   Capistrano_SDK_VERSION STREQUAL "cSDK2019.2" OR
   Capistrano_SDK_VERSION STREQUAL "cSDK2019" OR
   Capistrano_SDK_VERSION STREQUAL "cSDK2018")
  SET(Capistrano_WIN32_LIBRARY_FILENAME_SUFFIX "CLI")
  SET(Capistrano_WIN64_LIBRARY_FILENAME_SUFFIX "CLI64")
  SET(Capistrano_WIN32_BINARY_FILENAME_SUFFIX "CLI")
  SET(Capistrano_WIN64_BINARY_FILENAME_SUFFIX "CLI64")
  SET(Capistrano_WIN64_LIBRARY_DIR_SUFFIX "lib")
ELSEIF(Capistrano_SDK_VERSION STREQUAL "cSDK2016" OR Capistrano_SDK_VERSION STREQUAL "cSDK2013")
  SET(Capistrano_WIN32_LIBRARY_FILENAME_SUFFIX "DLL")
  SET(Capistrano_WIN64_LIBRARY_FILENAME_SUFFIX "DLL")
  SET(Capistrano_WIN32_BINARY_FILENAME_SUFFIX "")
  SET(Capistrano_WIN64_BINARY_FILENAME_SUFFIX "")
  SET(Capistrano_WIN64_LIBRARY_DIR_SUFFIX "lib/x64")
ENDIF()

IF(Capistrano_SDK_ROOT)
  SET(Capistrano_PATH_HINTS ${Capistrano_SDK_ROOT})
ELSEIF(Capistrano_SDK_VERSION STREQUAL "cSDK2023")
  SET(Capistrano_PATH_HINTS "c:/cSDK2023/cView2023")
else()
  SET(Capistrano_PATH_HINTS "c:/${Capistrano_SDK_VERSION}")
ENDIF()

FIND_PATH(Capistrano_INCLUDE_DIR usbprobedll_net.h
  PATH_SUFFIXES
    "include"
  DOC "Capistrano include directory (contains usbProbeDLL_net.h)"
  PATHS ${Capistrano_PATH_HINTS}
  )
FIND_PATH(Capistrano_WIN32_LIBRARY_DIR ${Capistrano_FIND_FILE}${Capistrano_WIN32_LIBRARY_FILENAME_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
  PATH_SUFFIXES
    "lib"
  DOC "Capistrano 32-bit library directory (contains ${Capistrano_FIND_FILE}${Capistrano_WIN32_LIBRARY_FILENAME_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX})"
  PATHS ${Capistrano_PATH_HINTS}
  )
FIND_PATH(Capistrano_WIN64_LIBRARY_DIR ${Capistrano_FIND_FILE}${Capistrano_WIN64_LIBRARY_FILENAME_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
  PATH_SUFFIXES
    ${Capistrano_WIN64_LIBRARY_DIR_SUFFIX}
  DOC "Capistrano 64-bit library directory (contains ${Capistrano_FIND_FILE}${Capistrano_WIN64_LIBRARY_FILENAME_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX})"
  PATHS ${Capistrano_PATH_HINTS}
  )
FIND_PATH(Capistrano_WIN32_BINARY_DIR ${Capistrano_FIND_FILE}${Capistrano_WIN32_BINARY_FILENAME_SUFFIX}${CMAKE_SHARED_LIBRARY_SUFFIX}
  PATH_SUFFIXES
    "bin"
    "dll"
  DOC "Path to Capistrano 32-bit binary directory (contains 32-bit ${Capistrano_FIND_FILE}${Capistrano_WIN32_BINARY_FILENAME_SUFFIX}${CMAKE_SHARED_LIBRARY_SUFFIX})"
  PATHS ${Capistrano_PATH_HINTS}
  NO_DEFAULT_PATH # avoid finding installed DLLs in the system folders
  )
FIND_PATH(Capistrano_WIN64_BINARY_DIR ${Capistrano_FIND_FILE}${Capistrano_WIN64_BINARY_FILENAME_SUFFIX}${CMAKE_SHARED_LIBRARY_SUFFIX}
  PATH_SUFFIXES
    "bin/x64"
    "dll"
  DOC "Path to Capistrano 64-bit binary directory (contains 64-bit ${Capistrano_FIND_FILE}${Capistrano_WIN64_BINARY_FILENAME_SUFFIX}${CMAKE_SHARED_LIBRARY_SUFFIX})"
  PATHS ${Capistrano_PATH_HINTS}
  NO_DEFAULT_PATH # avoid finding installed DLLs in the system folders
  )

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(Capistrano_BINARY_DIR ${Capistrano_WIN64_BINARY_DIR} )
  set(Capistrano_LIBRARY_DIR ${Capistrano_WIN64_LIBRARY_DIR} )
  set(Capistrano_BINARY_FILE_NAME_SUFFIX ${Capistrano_WIN64_BINARY_FILENAME_SUFFIX})
  set(Capistrano_LIBRARY_FILE_NAME_SUFFIX ${Capistrano_WIN64_LIBRARY_FILENAME_SUFFIX})
  if(Capistrano_SDK_VERSION STREQUAL "cSDK2016" OR Capistrano_SDK_VERSION STREQUAL "cSDK2013")
    message(FATAL_ERROR "Capistrano does not support 64-bit applications with ${Capistrano_SDK_VERSION}")
  endif()
else(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(Capistrano_BINARY_DIR ${Capistrano_WIN32_BINARY_DIR})
  set(Capistrano_LIBRARY_DIR ${Capistrano_WIN32_LIBRARY_DIR})
  set(Capistrano_BINARY_FILE_NAME_SUFFIX ${Capistrano_WIN32_BINARY_FILENAME_SUFFIX})
  set(Capistrano_LIBRARY_FILE_NAME_SUFFIX ${Capistrano_WIN32_LIBRARY_FILENAME_SUFFIX})
endif(CMAKE_SIZEOF_VOID_P EQUAL 8)

# handle the QUIETLY and REQUIRED arguments and set Capistrano_FOUND to TRUE if
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(CAPISTRANO DEFAULT_MSG
  Capistrano_LIBRARY_DIR
  Capistrano_INCLUDE_DIR
  Capistrano_BINARY_DIR
  )

IF(CAPISTRANO_FOUND)
  SET(CAPISTRANO_LIBRARY_DIR ${Capistrano_LIBRARY_DIR})
  SET(CAPISTRANO_INCLUDE_DIR ${Capistrano_INCLUDE_DIR})
  SET(CAPISTRANO_BINARY_DIR ${Capistrano_BINARY_DIR})
  SET(CAPISTRANO_BINARY_USBPROBE_NAME "USBprobe${Capistrano_BINARY_FILE_NAME_SUFFIX}")
  SET(CAPISTRANO_LIBRARY_USBPROBE_NAME "USBprobe${Capistrano_LIBRARY_FILE_NAME_SUFFIX}")
  SET(CAPISTRANO_BINARY_BMODE_NAME "BmodeUSB${Capistrano_BINARY_FILE_NAME_SUFFIX}")
  IF(Capistrano_SDK_VERSION STREQUAL "cSDK2023" OR
     Capistrano_SDK_VERSION STREQUAL "cSDK2019.3" OR
     Capistrano_SDK_VERSION STREQUAL "cSDK2019.2" OR
     Capistrano_SDK_VERSION STREQUAL "cSDK2019" OR
     Capistrano_SDK_VERSION STREQUAL "cSDK2018")
    SET(CAPISTRANO_LIBRARY_BMODE_NAME "BmodeUSB${Capistrano_LIBRARY_FILE_NAME_SUFFIX}")
  ELSEIF(Capistrano_SDK_VERSION STREQUAL "cSDK2016" OR Capistrano_SDK_VERSION STREQUAL "cSDK2013")
    SET(CAPISTRANO_LIBRARY_BMODE_NAME "Bmode${Capistrano_LIBRARY_FILE_NAME_SUFFIX}")
  ELSE()
    MESSAGE(FATAL_ERROR "Unknown version of Capistrano SDK")
  ENDIF()
ENDIF()
