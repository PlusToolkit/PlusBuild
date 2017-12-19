# - Find V4L2 library
# Find the native V4L2 includes and library
# This module defines
#  V4L2_INCLUDE_DIR, where to find libv4l2.h, etc.
#  V4L2_LIBRARIES, libraries to link against to use V4L2.
#  V4L2_FOUND, If false, do not try to use V4L2. also defined, but not for general use are
#  V4L2_LIBRARY, where to find the V4L2 library.
#
#=============================================================================
# Copyright 2012 Juergen Heinemann(Undefined) http://www.hjcms.de
#
# Distributed under the OSI-approved BSD License(the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#
#=============================================================================

FIND_PATH(V4L2_INCLUDE_DIR
  NAMES libv4l2.h libv4lconvert.h
  PATH_SUFFIXES v4l2 video4linux
  DOC "The Video4Linux Version 2(v4l2) include directory"
  )

FIND_PATH(_videodev2
  NAMES videodev2.h
  PATH_SUFFIXES linux
  DOC "Video for Linux Two header file include directory"
  )

FIND_LIBRARY(V4L2_LIBRARY
  NAMES v4l2 v4lconvert
  DOC "The Video4Linux Version 2(v4l2) library"
  )

# handle the QUIETLY and REQUIRED arguments and set V4L2_FOUND to TRUE if all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(V4L2 DEFAULT_MSG V4L2_LIBRARY V4L2_INCLUDE_DIR)

SET(V4L2_LIBRARIES v4l2)

IF(NOT _videodev2)
  MESSAGE(WARNING "videodev2.h kernel header not found!")
  SET(V4L2_FOUND 0)
ENDIF()

IF(V4L2_FOUND)
  ADD_LIBRARY(v4l2 SHARED IMPORTED)
  SET_PROPERTY(TARGET v4l2 PROPERTY IMPORTED_LOCATION ${V4L2_LIBRARY})
  SET_PROPERTY(TARGET v4l2 PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${V4L2_INCLUDE_DIR})
ENDIF()

MARK_AS_ADVANCED(V4L2_INCLUDE_DIR V4L2_LIBRARY _videodev2)
