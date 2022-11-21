#--------------------------------------------------------------------------
# PlusLibData
IF(NOT DEFINED(PLUSBUILD_PLUSLIBDATA_GIT_REPOSITORY))
  SET(PLUSBUILD_PLUSLIBDATA_GIT_REPOSITORY "https://github.com/PlusToolkit/PlusLibData.git" CACHE STRING "Set PlusLibData desired git url.")
ENDIF()
IF(NOT DEFINED(PLUSBUILD_PLUSLIBDATA_GIT_REVISION))
  SET(PLUSBUILD_PLUSLIBDATA_GIT_REVISION "master" CACHE STRING "Set PlusLibData desired git hash (master means latest).")
ENDIF()

SET (PLUS_PLUSLIBDATA_DIR ${CMAKE_BINARY_DIR}/PlusLibData CACHE INTERNAL "Path to store PlusLib contents.")
ExternalProject_Add(PlusLibData
  "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
  SOURCE_DIR "${PLUS_PLUSLIBDATA_DIR}"
  #--Download step--------------
  GIT_REPOSITORY ${PLUSBUILD_PLUSLIBDATA_GIT_REPOSITORY}
  GIT_TAG ${PLUSBUILD_PLUSLIBDATA_GIT_REVISION}
  #--Configure step-------------
  CONFIGURE_COMMAND ""
  #--Build step-----------------
  BUILD_COMMAND ""
  #--Install step-----------------
  INSTALL_COMMAND ""
  )
SET(PLUSLIB_DATA_DIR ${PLUS_PLUSLIBDATA_DIR} CACHE PATH "The directory containing PlusLib data" FORCE)