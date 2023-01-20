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
    "https://github.com/clariusdev/solum.git"
    "v10.1.1"
    )

  SET(ClariusOEM_OUTER_SRC_DIR "${CMAKE_BINARY_DIR}/ClariusOEM")
  SET(ClariusOEM_DIR "${ClariusOEM_OUTER_SRC_DIR}/desktop/src" CACHE PATH "Path to Clarius Solum SDK")
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

  SET(CLARIUS_OEM_PACKAGE_URL "https://github.com/clariusdev/solum/releases/download/v10.1.1/solum-10.1.1-windows.zip")
  SET(CLARIUS_OEM_PACKAGE_SHA256 "3d5f365ad1894d4d0ea226258e5b6440e9d338f191f521fb96c27dca3610f94b")

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