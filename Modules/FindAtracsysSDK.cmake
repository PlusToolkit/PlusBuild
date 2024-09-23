###############################################################################
# Find Atracsys SDK for spryTrack (stk) or fusionTrack (ftk)
#
#     find_package(AtracsysSDK)
#
# Variables defined by this module:
#
#  AtracsysSDK_FOUND                True if Atracsys SDK was found
#  AtracsysSDK_VERSION              The version of SDK
#  AtracsysSDK_INCLUDE_DIR          The location of SDK headers
#  AtracsysSDK_LIBRARY              Library needed to use the SDK
#  AtracsysSDK_BINARY_DIR           Binaries needed to use the SDK

IF(PLUS_USE_ATRACSYS_DEVICE_TYPE STREQUAL "stk")
  # use spryTrack SDK
  if (WIN32)
    # Windows 64 bit spryTrack path hints
    SET(AtracsysSDK_PATH_HINTS
    "../PLTools/Atracsys/windows/stk64/cmake"
    "../../PLTools/Atracsys/windows/stk64/cmake"
    "../trunk/PLTools/Atracsys/windows/stk64/cmake"
    )
    # On Windows, we look for the installation folder in the registry
    get_filename_component(
      AtracsysSDK_INSTALL_PATH
      "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Atracsys\\spryTrack;Root]"
      ABSOLUTE
      CACHE)
    # if installation folder found, then add it to the path hints
    if (AtracsysSDK_INSTALL_PATH)
      LIST(APPEND AtracsysSDK_PATH_HINTS "${AtracsysSDK_INSTALL_PATH}")
    endif()
  else ()
    # Unix spryTrack path hints
    SET(AtracsysSDK_PATH_HINTS
      "../PLTools/Atracsys/linux/stk"
      "../../PLTools/Atracsys/linux/stk"
      "../trunk/PLTools/Atracsys/linux/stk"
      )
    # On Linux, the AtracsysSDK_HOME variable must be defined.
    IF(DEFINED ENV{AtracsysSDK_HOME})
      set(AtracsysSDK_INSTALL_PATH $ENV{AtracsysSDK_HOME})
      # Add Linux spryTrack to path hints
      LIST(APPEND AtracsysSDK_PATH_HINTS "${AtracsysSDK_INSTALL_PATH}")
    ENDIF()
  endif ()
ELSEIF(PLUS_USE_ATRACSYS_DEVICE_TYPE STREQUAL "ftk")
  # use fusionTrack SDK
  if (WIN32)
  	# Windows 64 bit fusionTrack path hints
    SET(AtracsysSDK_PATH_HINTS
      "../PLTools/Atracsys/windows/ftk64/cmake"
      "../../PLTools/Atracsys/windows/ftk64/cmake"
      "../trunk/PLTools/Atracsys/windows/ftk64/cmake"
      )
    # On Windows, we look for the installation folder in the registry
    get_filename_component(
      AtracsysSDK_INSTALL_PATH
      "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Atracsys\\fusionTrack;Root]"
      ABSOLUTE
      CACHE)
    # if installation folder found, then add it to the path hints
    if (AtracsysSDK_INSTALL_PATH)
      LIST(APPEND AtracsysSDK_PATH_HINTS "${AtracsysSDK_INSTALL_PATH}")
    endif()
  else ()
    # Unix fusionTrack path hints
    SET(AtracsysSDK_PATH_HINTS
      "../PLTools/Atracsys/linux/ftk"
      "../../PLTools/Atracsys/linux/ftk"
      "../trunk/PLTools/Atracsys/linux/ftk"
      )
    # On Linux, the AtracsysSDK_HOME variable must be defined.
    IF(DEFINED ENV{AtracsysSDK_HOME})
      set(AtracsysSDK_INSTALL_PATH $ENV{AtracsysSDK_HOME})
      # Add Linux fusionTrack to path hints
      LIST(APPEND AtracsysSDK_PATH_HINTS "${AtracsysSDK_INSTALL_PATH}")
    ENDIF()
    SET(CMAKE_IMPORT_LIBRARY_PREFIX "lib")
    SET(CMAKE_IMPORT_LIBRARY_SUFFIX ".so")
  endif ()
ELSEIF(PLUS_USE_ATRACSYS_DEVICE_TYPE STREQUAL "ftksim")
  # use simulator SDK
  SET(AtracsysSDK_PATH_HINTS
    "$ENV{PROGRAMFILES}/Atracsys/simulator SDK x64"
    "C:/Program Files/Atracsys/simulator SDK x64"
    )
ENDIF()
IF(AtracsysSDK_INSTALL_PATH)
  set(Atracsys_DIR "${AtracsysSDK_INSTALL_PATH}/cmake/Atracsys")
ENDIF()

find_package(Atracsys REQUIRED COMPONENTS SDK HINTS ${AtracsysSDK_PATH_HINTS})

set(AtracsysSDK_FOUND True)
set(AtracsysSDK_VERSION "${Atracsys_VERSION}")
set(AtracsysSDK_INCLUDE_DIR "${AtracsysSDK_INCLUDE_DIRS}")
STRING(REPLACE "/include" "/lib" tmp "${AtracsysSDK_INCLUDE_DIR}")
set(AtracsysSDK_LIBRARY "${tmp}${CMAKE_IMPORT_LIBRARY_PREFIX}fusionTrack64${CMAKE_IMPORT_LIBRARY_SUFFIX}")
if(WIN32)
  STRING(REPLACE "/include" "/bin" AtracsysSDK_BINARY_DIR "${AtracsysSDK_INCLUDE_DIR}")
else()
  STRING(REPLACE "/include" "/lib" AtracsysSDK_BINARY_DIR "${AtracsysSDK_INCLUDE_DIR}")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(AtracsysSDK
  FOUND_VAR AtracsysSDK_FOUND
  REQUIRED_VARS ATRACSYS_DEVICE_TYPE AtracsysSDK_INCLUDE_DIR AtracsysSDK_BINARY_DIR #AtracsysSDK_LIBRARY
  VERSION_VAR AtracsysSDK_VERSION
)
