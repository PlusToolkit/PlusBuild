# Find the Claron MicronTracker SDK
# This module defines
# MicronTracker_FOUND - MicronTracker SDK has been found on this system
# MicronTracker_INCLUDE_DIR - where to find the header files
# MicronTracker_LIBRARY - MTC library to be linked
# MicronTracker_BINARY_DIR - location of shared libraries
#
# INSTALL_MicronTracker - Macro to install all MicronTracker DLLs to a location

# By default prefer MTC_3.6 as MTC_3.7 requires installation of VS2013 redistributable package
OPTION(PLUSBUILD_PREFER_MicronTracker_36 "Plus prefers MicronTracker SDK version MTC_3.6 instead of MTC_3.7" ON)
MARK_AS_ADVANCED(PLUSBUILD_PREFER_MicronTracker_36)

# If PLUSBUILD_PREFER_MicronTracker_36 is defined: try to find MTC_3.6 first and fall back to MTC_3.7,
# otherwise try to find MTC_3.7 and fall back to MTC_3.6.
IF(PLUSBUILD_PREFER_MicronTracker_36)
  SET(MicronTracker_PATH_HINTS
    ../Claron/MTC_3.6.5.4_x86_win/MicronTracker
    ../PLTools/Claron/MTC_3.6.5.4_x86_win/MicronTracker
    ../../PLTools/Claron/MTC_3.6.5.4_x86_win/MicronTracker
    ../trunk/PLTools/Claron/MTC_3.6.5.4_x86_win/MicronTracker
    ${CMAKE_CURRENT_BINARY_DIR}/PLTools/Claron/MTC_3.6.5.4_x86_win/MicronTracker
    ../Claron/MTC_3.6.1.6_x86_win/MicronTracker
    ../PLTools/Claron/MTC_3.6.1.6_x86_win/MicronTracker
    ../../PLTools/Claron/MTC_3.6.1.6_x86_win/MicronTracker
    ../trunk/PLTools/Claron/MTC_3.6.1.6_x86_win/MicronTracker
    ${CMAKE_CURRENT_BINARY_DIR}/PLTools/Claron/MTC_3.6.1.6_x86_win/MicronTracker
    ../Claron/MTC_3.7.6.8_x86_win/MicronTracker
    ../PLTools/Claron/MTC_3.7.6.8_x86_win/MicronTracker
    ../../PLTools/Claron/MTC_3.7.6.8_x86_win/MicronTracker
    ../trunk/PLTools/Claron/MTC_3.7.6.8_x86_win/MicronTracker
    ${CMAKE_CURRENT_BINARY_DIR}/PLTools/Claron/MTC_3.7.6.8_x86_win/MicronTracker
    ${CMAKE_CURRENT_BINARY_DIR}/../../../../../PLTools/Claron/MTC_3.7.6.8_x86_win/MicronTracker
    )
ELSE()
  IF(BUILD_ARCHITECTURE MATCHES "x64")
    SET(MicronTracker_PATH_HINTS
      ../PLTools/Claron/MTC_4.1.2.41606_x64_win
      ../../PLTools/Claron/MTC_4.1.2.41606_x64_win
      )
  ELSE()
    SET(MicronTracker_PATH_HINTS
      ../Claron/MTC_3.7.6.8_x86_win/MicronTracker
      ../PLTools/Claron/MTC_3.7.6.8_x86_win/MicronTracker
      ../../PLTools/Claron/MTC_3.7.6.8_x86_win/MicronTracker
      ../trunk/PLTools/Claron/MTC_3.7.6.8_x86_win/MicronTracker
      ${CMAKE_CURRENT_BINARY_DIR}/PLTools/Claron/MTC_3.7.6.8_x86_win/MicronTracker
      ../Claron/MTC_3.6.5.4_x86_win/MicronTracker
      ../PLTools/Claron/MTC_3.6.5.4_x86_win/MicronTracker
      ../../PLTools/Claron/MTC_3.6.5.4_x86_win/MicronTracker
      ../trunk/PLTools/Claron/MTC_3.6.5.4_x86_win/MicronTracker
      ${CMAKE_CURRENT_BINARY_DIR}/PLTools/Claron/MTC_3.6.5.4_x86_win/MicronTracker
      ../Claron/MTC_3.6.1.6_x86_win/MicronTracker
      ../PLTools/Claron/MTC_3.6.1.6_x86_win/MicronTracker
      ../../PLTools/Claron/MTC_3.6.1.6_x86_win/MicronTracker
      ../trunk/PLTools/Claron/MTC_3.6.1.6_x86_win/MicronTracker
      ${CMAKE_CURRENT_BINARY_DIR}/PLTools/Claron/MTC_3.6.1.6_x86_win/MicronTracker
      ${CMAKE_CURRENT_BINARY_DIR}/../../../../../PLTools/Claron/MTC_3.6.1.6_x86_win/MicronTracker
      )
  ENDIF()
ENDIF()

LIST(APPEND MicronTracker_PATH_HINTS
  "c:/Program Files (x86)/Claron Technology/MicronTracker"
  "c:/Program Files/Claron Technology/MicronTracker"
  "c:/ProgramData/ClaroNav/MicronTracker 4/Dist64MT4"
  )

  IF(CMAKE_HOST_WIN32 AND CMAKE_CL_64)
    SET(PLATFORM_SUFFIX "64")
  ELSE()
    SET(PLATFORM_SUFFIX "")
  ENDIF()

FIND_PATH(MicronTracker_INCLUDE_DIR MTC.h
  PATH_SUFFIXES
    Dist${PLATFORM_SUFFIX}
    inc
  DOC "MicronTracker include directory (contains MTC.h)"
  PATHS ${MicronTracker_PATH_HINTS}
  )

FIND_LIBRARY(MicronTracker_LIBRARY
  NAMES MTC${CMAKE_STATIC_LIBRARY_SUFFIX}
  PATH_SUFFIXES
    Dist${PLATFORM_SUFFIX}
    lib
  DOC "Path to MicronTracker base library (MTC.lib)"
  PATHS ${MicronTracker_PATH_HINTS}
  )

FIND_PATH(MicronTracker_BINARY_DIR MTC${CMAKE_SHARED_LIBRARY_SUFFIX}
  PATH_SUFFIXES
    Dist${PLATFORM_SUFFIX}
    bin
  PATHS ${MicronTracker_PATH_HINTS}
  DOC "Path to MicronTracker base shared library (MTC.dll)"
  NO_DEFAULT_PATH # avoid finding installed DLLs in the system folders
  )

# handle the QUIETLY and REQUIRED arguments and set MicronTracker_FOUND to TRUE if
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(MicronTracker DEFAULT_MSG
  MicronTracker_LIBRARY
  MicronTracker_INCLUDE_DIR
  MicronTracker_BINARY_DIR
  )
