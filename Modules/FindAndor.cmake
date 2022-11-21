# Find the Andor SDK
# ANDOR_FOUND - Andor SDK has been found on this system
# ANDOR_INCLUDE_DIR - where to find the header files
# ANDOR_LIBRARY_DIR - libraries to be linked
# ANDOR_BINARY_DIR - common shared libraries to be installed

SET( ANDOR_PATH_HINTS
  "C:/Program Files/Andor SDK"
  )

FIND_PATH(ANDOR_INCLUDE_DIR ATMCD32D.h
  DOC "ANDOR include directory (contains ATMCD32D.h)"
  PATHS ${ANDOR_PATH_HINTS}
  )

if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  set(bitness 64)
else()
  set(bitness 32)
endif()

set(ANDOR_LIBRARY "atmcd${bitness}m") # suffix m is for Microsoft compiler, d is for Borland
FIND_PATH(ANDOR_LIBRARY_DIR ${ANDOR_LIBRARY}${CMAKE_STATIC_LIBRARY_SUFFIX}
  DOC "ANDOR ${bitness}-bit library directory (contains ${ANDOR_LIBRARY}${CMAKE_STATIC_LIBRARY_SUFFIX}})"
  PATHS ${ANDOR_PATH_HINTS}
  )

set(ANDOR_DLL "atmcd${bitness}d")
FIND_PATH(ANDOR_BINARY_DIR ${ANDOR_DLL}${CMAKE_SHARED_LIBRARY_SUFFIX}
  DOC "Path to ANDOR ${bitness}-bit binary directory (contains ${bitness}-bit ${ANDOR_DLL}.dll)"
  PATHS ${ANDOR_PATH_HINTS}
  NO_DEFAULT_PATH # avoid finding installed DLLs in the system folders
  )

# handle the QUIETLY and REQUIRED arguments and set ANDOR_FOUND to TRUE if
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(ANDOR DEFAULT_MSG
  ANDOR_LIBRARY_DIR
  ANDOR_INCLUDE_DIR
  ANDOR_BINARY_DIR
  )
