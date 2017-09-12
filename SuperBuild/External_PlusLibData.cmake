#--------------------------------------------------------------------------
# PlusLibData
IF( "${PLUSBUILD_PLUSLIBDATA_GIT_REVISION}" STREQUAL "master" )
  SET(PLUSLIBDATA_GIT_TAG)
ELSE()
  SET(PLUSLIBDATA_GIT_TAG "GIT_TAG ${PLUSBUILD_PLUSLIBDATA_GIT_REVISION}")
ENDIF()

SET (PLUS_PLUSLIBDATA_DIR ${CMAKE_BINARY_DIR}/PlusLibData CACHE INTERNAL "Path to store PlusLib contents.")
ExternalProject_Add(PlusLibData
  "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
  SOURCE_DIR "${PLUS_PLUSLIBDATA_DIR}"
  #--Download step--------------
  GIT_REPOSITORY "${GIT_PROTOCOL}://github.com/PlusToolkit/PlusLibData.git"
  ${PLUSLIBDATA_GIT_TAG}
  #--Configure step-------------
  CONFIGURE_COMMAND ""
  #--Build step-----------------
  BUILD_COMMAND ""
  #--Install step-----------------
  INSTALL_COMMAND ""
  )
SET(PLUSLIB_DATA_DIR ${PLUS_PLUSLIBDATA_DIR} CACHE PATH "The directory containing PlusLib data" FORCE)