#=============================================================================
# (c) Kiyoyuki Chinzei, AIST japan.
# Small Computings for Clinicals
# Do not remove this copyright claim and the license conditions below.
# This file is released under two licenses: the BSD 3-Clause license and the MIT license.
# See https://opensource.org/licenses
# You may pick the license that best suits your needs.
#=============================================================================

#=============================================================================
# Modifications by (c) Adam Rankin, Robarts Research Institute
# Virtual Augmentation and Simulation for Surgery and Therapy (VASST) Laboratory
# Robarts Research Institute, Western University, Ontario, Canada
#=============================================================================

# This module finds where the DeckLink SDK include file is installed.
# DeckLink SDK is the toolkit for BlackMagickDesign Capture hardware.
# Visit www.blackmagic-design.com/support

# This code sets the following variables:
#  DeckLinkSDK_FOUND    = DeckLinkSDK is found
#  DeckLinkSDK_INCLUDE_DIR = path to where ${DeckLinkSDK_INCLUDE_FILE} is found
#  DeckLinkSDK_INCLUDE_FILE = DeckLinkAPI.idl (Win) or DeckLinkAPI.h (Mac/Linux)
#  DeckLinkSDK_SRC_FILE = Location of DeckLinkAPIDispatch.cpp to include in your project (Mac/Linux)
#  DeckLinkSDK_LIBS     = list of targets provided by this find module

# User-provided variables
#  If an environment variable: DECKLINK_SDK_DIR, BLACKMAGIC_SDK_DIR, DECKLINK_DIR or BLACKMAGIC_DIR is set, it looks in those paths
#  You can also provide the CMake variable DECKLINK_SDK_ROOT as a hint

# Typical usage is:
# > cmake -DDECKLINK_SDK_ROOT:PATH="<some_path_here>"
# ...
#
# CMakeLists.txt:
#    PROJECT(XYZ)
#    ...
#    FIND_PACKAGE(DeckLinkSDK REQUIRED)
#    DeckLinkGenerateAPIFiles(${PROJECT_NAME})
#    target_sources(vtk${PROJECT_NAME} PRIVATE ${MIDL_OUTPUT})
#    LIST(APPEND BlackMagicDeckLink_SRCS ${MIDL_OUTPUT})
#    TARGET_LINK_LIBRARIES(XYZ ${your_libs} ${DeckLinkSDK_LIBS})
#
# You can do the following in your DeckLink related sources;
# #include <DeckLinkAPI.h>
#
# You can optionally provide version argument, for example;
#  FIND_PACKAGE(DeckLinkSDK 10.5 REQUIRED)

MACRO(DeckLinkGenerateAPIFiles _project_name)
  IF(NOT WIN32)
    return()
  ENDIF()

  SET(MIDL_OUTPUT
    ${CMAKE_CURRENT_BINARY_DIR}/DeckLinkAPI.h
    ${CMAKE_CURRENT_BINARY_DIR}/DeckLinkAPI_i.c
    )
  SET(_midl_file
    ${DeckLinkSDK_INCLUDE_DIR}/DeckLinkAPI.idl
    )
  ADD_CUSTOM_COMMAND(
    OUTPUT ${MIDL_OUTPUT}
    COMMAND midl /h ${CMAKE_CURRENT_BINARY_DIR}/DeckLinkAPI.h /iid ${CMAKE_CURRENT_BINARY_DIR}/DeckLinkAPI_i.c ${_midl_file}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${_midl_file}
    VERBATIM
    )
  ADD_CUSTOM_TARGET(${_project_name}-midl-cmplr
    DEPENDS ${MIDL_OUTPUT}
    )
  ADD_DEPENDENCIES(${_project_name}
    ${_project_name}-midl-cmplr
    )
  SET_SOURCE_FILES_PROPERTIES(
    ${MIDL_OUTPUT}
      PROPERTIES
        GENERATED TRUE
        SKIP_AUTOGEN ON
    )
ENDMACRO()

SET(DeckLink_DEFAULT "/src/Blackmagic_SDK")

IF(WIN32)
  SET(_platform "Win")
  SET(__include_file DeckLinkAPI.idl)
ELSE()
  SET(__include_file DeckLinkAPI.h)

  IF(APPLE)
    SET(_platform "Mac")
  ELSE()
    SET(_platform "Linux")
  ENDIF()
ENDIF()

SET(BUILD_ARCHITECTURE "x64")
IF(CMAKE_SIZEOF_VOID_P EQUAL 4)
  SET(BUILD_ARCHITECTURE "x86")
ENDIF()

UNSET(DeckLinkSDK_PATH)
FIND_FILE(_header_found
    ${__include_file}
    PATHS ${DECKLINK_SDK_ROOT}
          $ENV{DECKLINK_SDK_DIR}
          $ENV{BLACKMAGIC_SDK_DIR}
          $ENV{DECKLINK_DIR}
          $ENV{BLACKMAGIC_DIR}
          # Plus specific paths to check
          "../../VASSTTools/BlackmagicDeckLinkSDK-11.2"
          "../../PLTools/BlackmagicDeckLinkSDK-11.2"
          "../VASSTTools/BlackmagicDeckLinkSDK-11.2"
          "../PLTools/BlackmagicDeckLinkSDK-11.2"
    PATH_SUFFIXES ${_platform}/include/
   )
IF(_header_found)
  get_filename_component(DeckLinkSDK_INCLUDE_DIR ${_header_found} DIRECTORY)
  get_filename_component(_platform_dir ${DeckLinkSDK_INCLUDE_DIR} DIRECTORY)
  get_filename_component(DeckLinkSDK_PATH ${_platform_dir} DIRECTORY)
  MARK_AS_ADVANCED(DeckLinkSDK_PATH)
  UNSET(_header_found CACHE)
ELSE()
  UNSET(DeckLinkSDK_PATH)
ENDIF()

SET(_version_h "${DeckLinkSDK_INCLUDE_DIR}/DeckLinkAPIVersion.h")
IF(EXISTS "${_version_h}")
  FILE(STRINGS "${_version_h}" _tmpstr REGEX "^#define[\t ]+BLACKMAGIC_DECKLINK_API_VERSION_STRING[\t ]+\".*\"")
  STRING(REGEX REPLACE                      "^#define[\t ]+BLACKMAGIC_DECKLINK_API_VERSION_STRING[\t ]+\"([^\"]*)\".*" "\\1"
    DeckLinkSDK_VERSION_STRING "${_tmpstr}")
ENDIF()

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(
  DeckLinkSDK
  REQUIRED_VARS DeckLinkSDK_PATH DeckLinkSDK_INCLUDE_DIR
  VERSION_VAR DeckLinkSDK_VERSION_STRING
  FAIL_MESSAGE "DeckLink SDK not found. Please set DECKLINK_SDK_ROOT to the root folder of your DeckLink SDK install.")

# Create CMake targets
IF(NOT TARGET DeckLinkSDK)
  ADD_LIBRARY(DeckLinkSDK INTERFACE IMPORTED)
  IF(WIN32)
    IF(NOT TARGET NVIDIA_GPUDirect)
      ADD_LIBRARY(NVIDIA_GPUDirect SHARED IMPORTED)
      set_target_properties(NVIDIA_GPUDirect
                            PROPERTIES
                              IMPORTED_IMPLIB "${DeckLinkSDK_PATH}/${_platform}/NVIDIA_GPUDirect/lib/${BUILD_ARCHITECTURE}/dvp.lib"
                              IMPORTED_LOCATION "${DeckLinkSDK_PATH}/${_platform}/NVIDIA_GPUDirect/bin/${BUILD_ARCHITECTURE}/dvp.dll"
                              INTERFACE_INCLUDE_DIRECTORIES "${DeckLinkSDK_PATH}/${_platform}/NVIDIA_GPUDirect/include"
                            )

      set_target_properties(DeckLinkSDK
                            PROPERTIES
                              INTERFACE_INCLUDE_DIRECTORIES
                                "${DeckLinkSDK_PATH}/${_platform}/include;${DeckLinkSDK_PATH}/${_platform}/DirectShow/include"
                            )
      SET(DeckLinkSDK_LIBS DeckLinkSDK NVIDIA_GPUDirect)
    ENDIF()
  ELSE()
    set_target_properties(DeckLinkSDK
                          PROPERTIES
                            INTERFACE_INCLUDE_DIRECTORIES
                              "${DeckLinkSDK_PATH}/${_platform}/include"
                          )
    IF(NOT APPLE)
      ADD_LIBRARY(NVIDIA_GPUDirect SHARED IMPORTED)
      set_target_properties(NVIDIA_GPUDirect
                            PROPERTIES
                              IMPORTED_LOCATION "${DeckLinkSDK_PATH}/${_platform}/NVIDIA_GPUDirect/${BUILD_ARCHITECTURE}/libdvp.so"
                              INTERFACE_INCLUDE_DIRECTORIES "${DeckLinkSDK_PATH}/${_platform}/NVIDIA_GPUDirect/include"
                            )
      set_target_properties(DeckLinkSDK
                            PROPERTIES
                              IMPORTED_LINK_INTERFACE_LIBRARIES
                                NVIDIA_GPUDirect
                            )
      SET(DeckLinkSDK_LIBS DeckLinkSDK NVIDIA_GPUDirect)
    ELSE()
      set_target_properties(DeckLinkSDK
                            PROPERTIES
                            )
      SET(DeckLinkSDK_LIBS DeckLinkSDK CoreFoundation)
    ENDIF()
  ENDIF()
ENDIF()
MARK_AS_ADVANCED(DeckLinkSDK_LIBS)