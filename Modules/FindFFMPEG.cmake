#
# Find the native FFMPEG includes and library
#
# Outputs:
#   FFMPEG_TARGETS, list of targets created by this find module
#   FFMPEG_INCLUDE_DIRS, where to find avcodec.h, avformat.h ...
#   FFMPEG_LIBRARIES, the libraries to link against to use FFMPEG.
#   FFMPEG_BINARIES, any binary files needed to use FFMPEG_LIBRARIES
#   FFMPEG_FOUND, If false, do not try to use FFMPEG.
#
# Targets:
#   ffmpeg::avformat
#   ffmpeg::avcodec
#   ffmpeg::avdevice
#   ffmpeg::avfilter
#   ffmpeg::avresample
#   ffmpeg::avutil
#   ffmpeg::postproc
#   ffmpeg::swresample
#   ffmpeg::swscale
#
# Input:
#   FFMPEG_ROOT, if this module use this path to find FFMPEG headers and libraries.

# Macro to find header and lib directories
# example: FFMPEG_FIND(AVFORMAT avformat avformat.h)
MACRO(FFMPEG_FIND varname shortname headername)
  FIND_PATH(FFMPEG_${varname}_INCLUDE_DIR
    lib${shortname}/${headername}
    PATHS
      ${FFMPEG_ROOT}/include
      $ENV{FFMPEG_DIR}/include
      ~/Library/Frameworks
      /Library/Frameworks
      /usr/local/include
      /usr/include
      /sw/include # Fink
      /opt/local/include # DarwinPorts
      /opt/csw/include # Blastwave
      /opt/include
      /usr/freeware/include
    PATH_SUFFIXES ffmpeg
    DOC "Location of FFMPEG_${shortname} headers"
  )
  MARK_AS_ADVANCED(FFMPEG_${varname}_INCLUDE_DIR)

  FIND_LIBRARY(FFMPEG_${varname}_LIBRARY
    NAMES ${shortname}${CMAKE_STATIC_LIBRARY_SUFFIX}
    PATHS
      ${FFMPEG_ROOT}/lib
      $ENV{FFMPEG_DIR}/lib
      ~/Library/Frameworks
      /Library/Frameworks
      /usr/local/lib
      /usr/local/lib64
      /usr/lib
      /usr/lib64
      /sw/lib
      /opt/local/lib
      /opt/csw/lib
      /opt/lib
      /usr/freeware/lib64
      ${FFMPEG_ROOT}/bin
    DOC "Location of FFMPEG_${shortname} library"
  )
  MARK_AS_ADVANCED(FFMPEG_${varname}_LIBRARY)

  IF(FFMPEG_${varname}_LIBRARY)
    IF(WIN32)
      GET_FILENAME_COMPONENT(_${varname}_lib_folder ${FFMPEG_${varname}_LIBRARY} DIRECTORY)
      # Find all the input files
      FILE(GLOB _binary_files RELATIVE "${_${varname}_lib_folder}" "${_${varname}_lib_folder}/*${CMAKE_SHARED_LIBRARY_SUFFIX}")
      FOREACH(_binary_file ${_binary_files})
        STRING(FIND ${_binary_file} ${shortname} _match)
        IF(NOT _match EQUAL -1)
          # Found matching binary file
          SET(FFMPEG_${varname}_BINARY ${_${varname}_lib_folder}/${_binary_file} CACHE FILEPATH "Location of the FFMPEG_${shortname} binary" FORCE)
          MARK_AS_ADVANCED(FFMPEG_${varname}_BINARY)
          BREAK()
        ENDIF()
      ENDFOREACH()
    ELSEIF(UNIX AND NOT APPLE)
    
    ELSEIF(APPLE)
    
    ENDIF()
  ENDIF()

  IF(FFMPEG_${varname}_LIBRARY AND FFMPEG_${varname}_INCLUDE_DIR)
    SET(FFMPEG_${varname}_FOUND 1)
  ENDIF()

  IF(FFMPEG_${varname}_BINARY)
    ADD_LIBRARY(ffmpeg::${shortname} IMPORTED SHARED)
    SET_TARGET_PROPERTIES(ffmpeg::${shortname} PROPERTIES
      IMPORTED_IMPLIB "${FFMPEG_${varname}_LIBRARY}"
      IMPORTED_LOCATION "${FFMPEG_${varname}_BINARY}"
    )
  ELSE()
    ADD_LIBRARY(ffmpeg::${shortname} IMPORTED STATIC)
    SET_TARGET_PROPERTIES(ffmpeg::${shortname} PROPERTIES
      IMPORTED_LOCATION "${FFMPEG_${varname}_LIBRARY}"
    )
  ENDIF()

  SET_TARGET_PROPERTIES(ffmpeg::${shortname} PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${FFMPEG_${varname}_INCLUDE_DIR}"
    )
ENDMACRO()

INCLUDE(CheckIncludeFiles)
CHECK_INCLUDE_FILES(stdint.h HAVE_STDINT_H)

FFMPEG_FIND(LIBAVFORMAT   avformat   avformat.h)
FFMPEG_FIND(LIBAVFILTER   avfilter   avfilter.h)
FFMPEG_FIND(LIBAVRESAMPLE avresample avresample.h)
FFMPEG_FIND(LIBAVDEVICE   avdevice   avdevice.h)
FFMPEG_FIND(LIBPOSTPROC   postproc   postprocess.h)
FFMPEG_FIND(LIBAVCODEC    avcodec    avcodec.h)
FFMPEG_FIND(LIBAVUTIL     avutil     avutil.h)
FFMPEG_FIND(LIBSWSCALE    swscale    swscale.h)
FFMPEG_FIND(LIBSWRESAMPLE swresample swresample.h)

MACRO(FFMPEG_BUILD_EXPORT_LIST listName listType entrySuffix docSuffix)

  MACRO(FFMPEG_APPEND_ENTRY listName varName entrySuffix)
    IF(FFMPEG_${varName}_FOUND)
      LIST(APPEND ${listName} ${FFMPEG_${varName}_${entrySuffix}})
    ENDIF()
  ENDMACRO()

  FFMPEG_APPEND_ENTRY(${listName} LIBAVFORMAT ${entrySuffix})
  FFMPEG_APPEND_ENTRY(${listName} LIBAVFILTER ${entrySuffix})
  FFMPEG_APPEND_ENTRY(${listName} LIBAVRESAMPLE ${entrySuffix})
  FFMPEG_APPEND_ENTRY(${listName} LIBAVDEVICE ${entrySuffix})
  FFMPEG_APPEND_ENTRY(${listName} LIBPOSTPROC ${entrySuffix})
  FFMPEG_APPEND_ENTRY(${listName} LIBAVCODEC ${entrySuffix})
  FFMPEG_APPEND_ENTRY(${listName} LIBAVUTIL ${entrySuffix})
  FFMPEG_APPEND_ENTRY(${listName} LIBSWSCALE ${entrySuffix})
  FFMPEG_APPEND_ENTRY(${listName} LIBSWRESAMPLE ${entrySuffix})
  LIST(REMOVE_DUPLICATES ${listName})
  SET(${listName} ${${listName}} CACHE ${listType} "Location of the FFMPEG ${docSuffix}.")
  MARK_AS_ADVANCED(${listName})
ENDMACRO()

FFMPEG_BUILD_EXPORT_LIST(FFMPEG_INCLUDE_DIRS PATH INCLUDE_DIR headers)
FFMPEG_BUILD_EXPORT_LIST(FFMPEG_LIBRARIES FILEPATH LIBRARY libraries)
FFMPEG_BUILD_EXPORT_LIST(FFMPEG_BINARIES FILEPATH BINARY binaries)

LIST(APPEND FFMPEG_TARGETS
  ffmpeg::avformat
  ffmpeg::avfilter
  ffmpeg::avresample
  ffmpeg::avdevice
  ffmpeg::postproc
  ffmpeg::avcodec
  ffmpeg::avutil
  ffmpeg::swscale
  ffmpeg::swresample
  )
LIST(REMOVE_DUPLICATES FFMPEG_TARGETS)
SET(FFMPEG_TARGETS ${FFMPEG_TARGETS} CACHE STRING "Names of the ffmpeg:: targets.")
MARK_AS_ADVANCED(FFMPEG_TARGETS)

# handle the QUIETLY and REQUIRED arguments and set FFMPEG_FOUND to TRUE if 
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(FFMPEG 
  FAIL_MESSAGE "Unable to locate FFMPEG. Please set FFMPEG_ROOT to a valid location."
  REQUIRED_VARS FFMPEG_INCLUDE_DIRS FFMPEG_LIBRARIES
  )