###############################################################################
# Find Clarius SOLUM SDK
#
#     find_package(ClariusOEM)
#
# Variables defined by this module:
#
#  ClariusOEM_DIR                  Location of the Clarius SOLUM SDK
#  ClariusOEM_INCLUDE_DIR          The location(s) of Clarius SOLUM SDK headers
#  ClariusOEM_LIBRARY_PATH         Path to library needed to use Clarius SOLUM SDK
#  ClariusOEM_BINARY_PATH          Path to binary needed to use Clarius SOLUM SDK
#  ClariusOEM_FOUND                True if Clarius SOLUM SDK was found

# if ClariusOEM_DIR is unset, attempt to locate the SDK files
IF(NOT DEFINED ClariusOEM_DIR)

  # path hints
  IF(WIN32)
    SET(ClariusOEM_PATH_HINTS
      "."
      )
  ELSE()
    MESSAGE(FATAL_ERROR "Clarius SOLUM SDK is currently only supported on Windows")
  ENDIF()

  # find path to Clarius SOLUM SDK dir
  FIND_PATH(_oem_root solum/solum.h
    PATHS ${ClariusOEM_PATH_HINTS}
    DOC "Clarius SOLUM SDK dir"
    )

  SET(ClariusOEM_DIR ${_oem_root} CACHE PATH "Path to Clarius SOLUM SDK")

ENDIF()


IF(ClariusOEM_DIR)
  # set path to Clarius SOLUM SDK include directory
  SET(ClariusOEM_INCLUDE_DIRS ${ClariusOEM_DIR}/solum CACHE PATH "Clarius SOLUM SDK include directories")
  MARK_AS_ADVANCED(ClariusOEM_INCLUDE_DIRS)

  # find Clarius SOLUM SDK library file
  FIND_LIBRARY(ClariusOEM_LIBRARY_PATH
    NAMES solum${CMAKE_STATIC_LIBRARY_SUFFIX}
    PATHS "${ClariusOEM_DIR}" NO_DEFAULT_PATH
    DOC "Clarius SOLUM SDK library"
    )
  MARK_AS_ADVANCED(ClariusOEM_LIBRARY_PATH)

  # find Clarius SOLUM SDK binary file
  FIND_FILE(ClariusOEM_BINARY_PATH
    NAMES solum${CMAKE_SHARED_LIBRARY_SUFFIX}
    PATHS "${ClariusOEM_DIR}" NO_DEFAULT_PATH
    DOC "Clarius SOLUM SDK binary"
    )
  MARK_AS_ADVANCED(ClariusOEM_BINARY_PATH)

ENDIF()


# standard find_package stuff
include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(
  ClariusOEM
  FOUND_VAR ClariusOEM_FOUND
  REQUIRED_VARS ClariusOEM_INCLUDE_DIRS ClariusOEM_LIBRARY_PATH ClariusOEM_BINARY_PATH
)


# if library found create ClariusOEM target
IF(ClariusOEM_FOUND)
  ADD_LIBRARY(ClariusOEM SHARED IMPORTED)
  SET_TARGET_PROPERTIES(ClariusOEM PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${ClariusOEM_INCLUDE_DIRS}
    IMPORTED_IMPLIB ${ClariusOEM_LIBRARY_PATH}
    IMPORTED_LOCATION ${ClariusOEM_BINARY_PATH}
    )
ENDIF()
