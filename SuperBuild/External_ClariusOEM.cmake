IF(ClariusOEM_DIR)

  FIND_PACKAGE(ClariusOEM REQUIRED)

  MESSAGE(STATUS "Using Clarius OEM library available at: ${ClariusOEM_DIR}")

  # Copy libraries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ${ClariusOEM_BINARY_PATH})

  SET(Plus_ClariusOEM_DIR ${ClariusOEM_DIR} CACHE PATH "Path to Clarius Solum SDK")
ELSE()

  # git clone of OEM interface
  SetGitRepositoryTag(
    ClariusOEM
    "https://github.com/Sunderlandkyl/solum.git"
    "6210b7675c70e4e2cfc08c429d0ad0239cd3257c"
    )

  SET(Plus_ClariusOEM_OUTER_SRC_DIR "${CMAKE_BINARY_DIR}/ClariusOEM")
  SET(Plus_ClariusOEM_DIR "${Plus_ClariusOEM_OUTER_SRC_DIR}" CACHE PATH "Path to Clarius Solum SDK")
  SET(Plus_ClariusOEM_PREFIX_DIR "${CMAKE_BINARY_DIR}/ClariusOEM-prefix")

  ExternalProject_Add(ClariusOEM
    ${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}
    PREFIX ${Plus_ClariusOEM_PREFIX_DIR}
    SOURCE_DIR ${Plus_ClariusOEM_OUTER_SRC_DIR}
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

  SET(CLARIUS_OEM_PACKAGE_URL "https://github.com/clariusdev/solum/releases/download/v11.0.0/solum-11.0.0-windows.x64.zip")
  SET(CLARIUS_OEM_PACKAGE_SHA256 "69959162d3ff9930a7fc7352b46b1072586be8155a1243343017c6e9cd1933fe")

  ExternalProject_Add(ClariusOEM-Libs
    ${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}
    PREFIX ${Plus_ClariusOEM_PREFIX_DIR}
    SOURCE_DIR ${Plus_ClariusOEM_DIR}/lib
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