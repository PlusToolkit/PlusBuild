IF(ClariusOEM_DIR AND NOT DEFINED ${SUPERBUILD_ClariusOEM})

  FIND_PACKAGE(ClariusOEM REQUIRED)

  MESSAGE(STATUS "Using Clarius OEM library available at: ${ClariusOEM_DIR}")

  # Copy libraries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ${ClariusOEM_BINARY_PATH})

ELSE()

  # git clone of OEM interface

  SET(SUPERBUILD_ClariusOEM ON CACHE BOOL "Should ClariusOEM be downloaded using ExternalProject")
  MARK_AS_ADVANCED(SUPERBUILD_ClariusOEM)

  SetGitRepositoryTag(
    ClariusOEM
    "${GIT_PROTOCOL}://github.com/clariusdev/oem.git"
    "v9.3.0"
    )

  SET(ClariusOEM_OUTER_SRC_DIR "${CMAKE_BINARY_DIR}/ClariusOEM")
  SET(ClariusOEM_DIR "${ClariusOEM_OUTER_SRC_DIR}/src" CACHE PATH "Path to Clarius OEM SDK")
  SET(ClariusOEM_PREFIX_DIR "${CMAKE_BINARY_DIR}/ClariusOEM-prefix")

  ExternalProject_Add(ClariusOEM
    ${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}
    PREFIX ${ClariusOEM_PREFIX_DIR}
    SOURCE_DIR ${ClariusOEM_OUTER_SRC_DIR}
    #--Download step--------------
    GIT_REPOSITORY ${ClariusOEM_GIT_REPOSITORY}
    GIT_TAG ${ClariusOEM_GIT_TAG}
    #--Configure step-------------
    CONFIGURE_COMMAND ""
    #--Build step-----------------
    BUILD_COMMAND ""
    #--Install step---------------
    INSTALL_COMMAND ""
    DEPENDS ""
    )

  # download zipped lib/dll files

  SET(CLARIUS_OEM_PACKAGE_URL "https://github.com/clariusdev/oem/releases/download/v9.3.0/clarius-oem-v930-windows.zip")
  SET(CLARIUS_OEM_PACKAGE_SHA256 "65d08864ec24c16c83290ca82b82f5f36889e7b4b0b4b9e8c7479a7d5aa15505")

  ExternalProject_Add(ClariusOEM-Libs
    ${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}
    PREFIX ${ClariusOEM_PREFIX_DIR}
    SOURCE_DIR ${ClariusOEM_DIR}/lib
    #--Download step--------------
    URL ${CLARIUS_OEM_PACKAGE_URL}
    URL_HASH SHA256=${CLARIUS_OEM_PACKAGE_SHA256}
    #--Configure step-------------
    CONFIGURE_COMMAND ""
    #--Build step-----------------
    BUILD_COMMAND ""
    #--Install step---------------
    INSTALL_COMMAND ""
    DEPENDS ClariusOEM
    )

ENDIF()