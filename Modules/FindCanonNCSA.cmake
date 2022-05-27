# - Find Canon NCSA SDK
# Find the native Canon NCSA includes and library
# This module defines
#  Canon::NCSA, the main CMake target to link against
#  Canon::CommLib, the communication target
#  Canon::Logging, the logging target
#  CanonNCSA_INCLUDE_DIR, where to find headers
#  CanonNCSA_LIBRARIES, libraries to link against
#  CanonNCSA_FOUND, If false, do not try to use Canon NCSA. also defined, but not for general use are
#
#=============================================================================
# Copyright 2022 Adam Rankin (Robarts Research Institute)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
# associated documentation files (the "Software"), to deal in the Software without restriction, 
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial 
# portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT 
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#=============================================================================

FIND_PATH(CanonNCSA_INCLUDE_DIR
  NAMES NcsaCommLibrary.h Logger.h cxxopts.hpp
  PATHS
    "C:/Program Files/Canon/mru/ncsa-sdk/include"
  DOC "The Canon NCSA include directory"
  )

FIND_LIBRARY(CanonNCSA_Comm_LIBRARY
  NAMES NcsaCommLib
  PATHS
    "C:/Program Files/Canon/mru/ncsa-sdk/lib"
  PATH_SUFFIXES
    "Release"
  DOC "The Canon NCSA communication library"
  )

FIND_LIBRARY(CanonNCSA_Log_LIBRARY
  NAMES libncsalogger
  PATHS
    "C:/Program Files/Canon/mru/ncsa-sdk/lib"
  PATH_SUFFIXES
    "Release"
  DOC "The Canon NCSA logging library"
  )

SET(_find_args CanonNCSA_Comm_LIBRARY CanonNCSA_Log_LIBRARY CanonNCSA_INCLUDE_DIR)

IF(WIN32)
  FIND_FILE(CanonNCSA_Comm_BINARY
    NAME NcsaCommLib.dll
    PATHS
      "C:/Program Files/Canon/mru/ncsa-sdk/bin"
    )

  FIND_FILE(CanonNCSA_Log_BINARY
    NAME libncsalogger.dll
    PATHS
      "C:/Program Files/Canon/mru/ncsa-sdk/bin"
    )

  LIST(APPEND _find_args CanonNCSA_Comm_BINARY CanonNCSA_Log_BINARY)
ENDIF()

# handle the QUIETLY and REQUIRED arguments and set CanonNCSA_FOUND to TRUE if all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(CanonNCSA DEFAULT_MSG ${_find_args})

SET(CanonNCSA_LIBRARIES NcsaCommLib libncsalogger)

IF(CanonNCSA_FOUND)
  ADD_LIBRARY(Canon::CommLib SHARED IMPORTED)
  IF(WIN32)
    SET_PROPERTY(TARGET Canon::CommLib PROPERTY IMPORTED_IMPLIB_RELEASE ${CanonNCSA_Comm_LIBRARY})
    SET_PROPERTY(TARGET Canon::CommLib PROPERTY IMPORTED_LOCATION_RELEASE ${CanonNCSA_Comm_BINARY})
  ELSE()
    SET_PROPERTY(TARGET Canon::CommLib PROPERTY IMPORTED_LOCATION ${CanonNCSA_Comm_LIBRARY})
  ENDIF()
  SET_PROPERTY(TARGET Canon::CommLib PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${CanonNCSA_INCLUDE_DIR})

  ADD_LIBRARY(Canon::Logging SHARED IMPORTED)
  IF(WIN32)
    SET_PROPERTY(TARGET Canon::Logging PROPERTY IMPORTED_IMPLIB_RELEASE ${CanonNCSA_Log_LIBRARY})
    SET_PROPERTY(TARGET Canon::Logging PROPERTY IMPORTED_LOCATION_RELEASE ${CanonNCSA_Log_BINARY})
  ELSE()
    SET_PROPERTY(TARGET Canon::Logging PROPERTY IMPORTED_LOCATION ${CanonNCSA_Log_LIBRARY})
  ENDIF()
  SET_PROPERTY(TARGET Canon::Logging PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${CanonNCSA_INCLUDE_DIR})

  ADD_LIBRARY(Canon::NCSA INTERFACE IMPORTED)
  SET_PROPERTY(TARGET Canon::NCSA PROPERTY
    INTERFACE_LINK_LIBRARIES Canon::CommLib Canon::Logging)
ENDIF()

MARK_AS_ADVANCED(CanonNCSA_FOUND CanonNCSA_INCLUDE_DIR CanonNCSA_Comm_LIBRARY CanonNCSA_Comm_BINARY CanonNCSA_Log_LIBRARY CanonNCSA_Log_BINARY CanonNCSA_LIBRARIES)
