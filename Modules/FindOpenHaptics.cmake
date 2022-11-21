# - try to find OpenHaptics libraries
#
# Cache Variables: (probably not for direct use in your scripts)
#  HDAPI_INCLUDE_DIR
#  HDAPI_LIBRARY
#  HDAPI_LIBRARY_RELEASE
#  HDAPI_LIBRARY_DEBUG
#  HDAPI_HDU_INCLUDE_DIR
#  HDAPI_HDU_LIBRARY
#  HDAPI_HDU_LIBRARY_RELEASE
#  HDAPI_HDU_LIBRARY_DEBUG
#  HLAPI_INCLUDE_DIR
#  HLAPI_LIBRARY
#  HLAPI_LIBRARY_RELEASE
#  HLAPI_LIBRARY_DEBUG
#  HLAPI_HLU_INCLUDE_DIR
#  HLAPI_HLU_LIBRARY
#  HLAPI_HLU_LIBRARY_RELEASE
#  HLAPI_HLU_LIBRARY_DEBUG
#
# Non-cache variables you might use in your CMakeLists.txt:
#  OpenHaptics_FOUND
#  HDAPI_INCLUDE_DIRS
#  HDAPI_LIBRARIES
#  HDAPI_HDU_INCLUDE_DIRS
#  HDAPI_HDU_LIBRARIES
#  HLAPI_INCLUDE_DIRS
#  HLAPI_LIBRARIES
#  HLAPI_HLU_INCLUDE_DIRS
#  HLAPI_HLU_LIBRARIES
#  OpenHaptics_LIBRARIES - includes HD, HDU, HL, HLU
#  OpenHaptics_INCLUDE_DIRS
#  OpenHaptics_BINARY_DIR
#  OpenHaptics_UTILITIES_BINARY_DIR
#
# Requires these CMake modules:
#  CleanDirectoryList
#  CleanLibraryList
#  ListCombinations
#  ProgramFilesGlob
#  SelectLibraryConfigurations (included with CMake >=2.8.0)
#  FindPackageHandleStandardArgs (known included with CMake >=2.6.2)
#  CMake 2.6.3 (uses "unset")
#
# Original Author:
# 2009-2012 Ryan Pavlik <rpavlik@iastate.edu> <abiryan@ryand.net>
# http://academic.cleardefinition.com
# Iowa State University HCI Graduate Program/VRAC
#
# Copyright Iowa State University 2009-2010.
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt)

cmake_minimum_required(VERSION 3.16.3...3.19.7 FATAL_ERROR)

SET( OpenHaptics_PATH_HINTS
  "C:/OpenHaptics/Developer/3.4.0"
  )


FIND_PATH( OpenHaptics_ROOT_DIR Geomagic_OpenHaptics.ico
  DOC "Root directory for OpenHaptics"
  PATHS ${OpenHaptics_PATH_HINTS}
  )


IF(CMAKE_HOST_WIN32 AND CMAKE_CL_64)
  set (_libsearch
    "${OpenHaptics_ROOT_DIR}/lib/x64"
    )
  set(_libsearch2
    "${OpenHaptics_ROOT_DIR}/utilities/lib/x64"
    )
ELSE()
  set (_libsearch
    "${OpenHaptics_ROOT_DIR}/lib/Win32"
    )
  set(_libsearch2
    "${OpenHaptics_ROOT_DIR}/utilities/lib/Win32"
    )
ENDIF()

set (_incsearch
  "${OpenHaptics_ROOT_DIR}/include"
  )
set (_incsearch2
  "${OpenHaptics_ROOT_DIR}/utilities/include"
  )

set(_deps_check)
set(_deps_libs)

###
# HDAPI: HD
###

find_path(HDAPI_INCLUDE_DIR
  NAMES
  HD/hd.h
  HINTS
  ${_incsearch})

find_library(HDAPI_LIBRARY_RELEASE
  NAMES
  HD
  PATH_SUFFIXES
  ReleaseAcademicEdition
  Release
  HINTS
  ${_libsearch})

find_library(HDAPI_LIBRARY_DEBUG
  NAMES
  HD
  PATH_SUFFIXES
  DebugAcademicEdition
  Debug
  HINTS
  ${_libsearch})

set( HDAPI_LIBRARY
  $<$<CONFIG:Release>:${HDAPI_LIBRARY_RELEASE}>
  $<$<CONFIG:Debug>:${HDAPI_LIBRARY_DEBUG}>
  )

###
# HDAPI: HDU
###
find_path(HDAPI_HDU_INCLUDE_DIR
  NAMES
  HDU/hdu.h
  HINTS
  ${_incsearch2})

find_library(HDAPI_HDU_LIBRARY_RELEASE
  NAMES
  HDU
  PATH_SUFFIXES
  ReleaseAcademicEdition
  Release
  HINTS
  ${_libsearch2})

find_library(HDAPI_HDU_LIBRARY_DEBUG
  NAMES
  HDU
  HDUD
  PATH_SUFFIXES
  DebugAcademicEdition
  Debug
  HINTS
  ${_libsearch2})

set( HDAPI_HDU_LIBRARY
  $<$<CONFIG:Release>:${HDAPI_HDU_LIBRARY_RELEASE}>
  $<$<CONFIG:Debug>:${HDAPI_HDU_LIBRARY_DEBUG}>
  )


###
# HLAPI: HL
###
find_path(HLAPI_INCLUDE_DIR
  NAMES
  HL/hl.h
  HINTS
  ${_incsearch})

find_library(HLAPI_LIBRARY_RELEASE
  NAMES
  HL
  PATH_SUFFIXES
  ReleaseAcademicEdition
  Release
  HINTS
  ${_libsearch})

find_library(HLAPI_LIBRARY_DEBUG
  NAMES
  HL
  PATH_SUFFIXES
  DebugAcademicEdition
  Debug
  HINTS
  ${_libsearch})

set( HLAPI_LIBRARY
  $<$<CONFIG:Release>:${HLAPI_LIBRARY_RELEASE}>
  $<$<CONFIG:Debug>:${HLAPI_LIBRARY_DEBUG}>
  )

###
# HLAPI: HLU
###
find_path(HLAPI_HLU_INCLUDE_DIR
  NAMES
  HLU/hlu.h
  HINTS
  ${_incsearch2})

find_library(HLAPI_HLU_LIBRARY_RELEASE
  NAMES
  HLU
  PATH_SUFFIXES
  ReleaseAcademicEdition
  Release
  HINTS
  ${_libsearch2})

find_library(HLAPI_HLU_LIBRARY_DEBUG
  NAMES
  HLU
  HLUD
  PATH_SUFFIXES
  DebugAcademicEdition
  Debug
  HINTS
  ${_libsearch2})

set( HLAPI_HLU_LIBRARY
  $<$<CONFIG:Release>:${HLAPI_HLU_LIBRARY_RELEASE}>
  $<$<CONFIG:Debug>:${HLAPI_HLU_LIBRARY_DEBUG}>
  )

###
# Add dependencies: Libraries
###
set(HDAPI_LIBRARIES "${HDAPI_LIBRARY}" ${_deps_libs})

if(HDAPI_HDU_LIBRARIES AND HDAPI_LIBRARIES)
  list(APPEND HDAPI_HDU_LIBRARIES ${HDAPI_LIBRARIES})
else()
  set(HDAPI_HDU_LIBRARIES)
endif()

if(HLAPI_LIBRARY AND HDAPI_LIBRARIES)
  set(HLAPI_LIBRARIES ${HLAPI_LIBRARY} ${HDAPI_LIBRARIES})
else()
  set(HLAPI_LIBRARIES)
endif()

if(HLAPI_HLU_LIBRARIES AND HLAPI_LIBRARIES)
  list(APPEND HLAPI_HLU_LIBRARIES ${HLAPI_LIBRARIES})
else()
  set(HLAPI_HLU_LIBRARIES)
endif()

###
# Add dependencies: Include dirs
###
if(HDAPI_INCLUDE_DIR)
  set(HDAPI_INCLUDE_DIRS ${HDAPI_INCLUDE_DIR})

  if(HDAPI_HDU_INCLUDE_DIR)
    set(HDAPI_HDU_INCLUDE_DIRS
      ${HDAPI_INCLUDE_DIRS}
      ${HDAPI_HDU_INCLUDE_DIR})

    if(HDAPI_HDU_INCLUDE_DIR)
      set(HLAPI_INCLUDE_DIRS ${HDAPI_INCLUDE_DIRS} ${HLAPI_INCLUDE_DIR})

      if(HLAPI_HLU_INCLUDE_DIR)
        set(HLAPI_HLU_INCLUDE_DIRS
          ${HLAPI_INCLUDE_DIRS}
          ${HLAPI_HLU_INCLUDE_DIR})

      endif()
    endif()
  endif()
endif()

# handle the QUIETLY and REQUIRED arguments and set xxx_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(OpenHaptics
  DEFAULT_MSG
  HDAPI_LIBRARY
  HDAPI_INCLUDE_DIR
  HDAPI_HDU_INCLUDE_DIR
  HDAPI_HDU_LIBRARY
  HLAPI_INCLUDE_DIR
  HLAPI_LIBRARY
  HLAPI_HLU_INCLUDE_DIR
  HLAPI_HLU_LIBRARY
  ${_deps_check})

if(OpenHaptics_FOUND)
  set(OpenHaptics_LIBRARIES
    ${HDAPI_LIBRARY}
    ${HDAPI_HDU_LIBRARY}
    ${HLAPI_LIBRARY}
    ${HLAPI_HLU_LIBRARY})

  set(OpenHaptics_INCLUDE_DIRS
    ${HLAPI_HLU_INCLUDE_DIRS}
    ${HDAPI_HDU_INCLUDE_DIRS}
    )
  list(REMOVE_DUPLICATES OpenHaptics_INCLUDE_DIRS)
  list(REMOVE_DUPLICATES OpenHaptics_LIBRARIES)

  set(OpenHaptics_BINARY_DIR ${_libsearch})
  set(OpenHaptics_UTILITIES_BINARY_DIR ${_libsearch2})
  mark_as_advanced(OpenHaptics_ROOT_DIR)
endif()

mark_as_advanced(HDAPI_INCLUDE_DIR
  HDAPI_LIBRARY_RELEASE
  HDAPI_LIBRARY_DEBUG
  HDAPI_HDU_INCLUDE_DIR
  HDAPI_HDU_LIBRARY_RELEASE
  HDAPI_HDU_LIBRARY_DEBUG
  HLAPI_INCLUDE_DIR
  HLAPI_LIBRARY_RELEASE
  HLAPI_LIBRARY_DEBUG
  HLAPI_HLU_INCLUDE_DIR
  HLAPI_HLU_LIBRARY_RELEASE
  HLAPI_HLU_LIBRARY_DEBUG
  OpenHaptics_BINARY_DIR
  OpenHaptics_UTILITIES_BINARY_DIR)
