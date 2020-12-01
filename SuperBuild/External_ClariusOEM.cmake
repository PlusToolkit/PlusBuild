IF(ClariusOEM_DIR)
  
  FIND_PACKAGE(ClariusOEM REQUIRED)

  MESSAGE(STATUS "Using Clarius OEM library available at: ${ClariusOEM_DIR}")

  # Copy libraries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ${ClariusOEM_BINARY_PATH})

ELSE()

  # git clone of OEM interface
  
  SetGitRepositoryTag(
    ClariusOEM
    "${GIT_PROTOCOL}://github.com/clariusdev/oem.git"
    "v9.1.0"
    )

  SET(ClariusOEM_DIR "${CMAKE_BINARY_DIR}/ClariusOEM" CACHE PATH "Path to Clarius OEM SDK")
  SET(ClariusOEM_PREFIX_DIR "${ClariusOEM_DIR}-prefix")

  ExternalProject_Add(ClariusOEM
    ${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}
    PREFIX ${ClariusOEM_PREFIX_DIR}
    SOURCE_DIR ${ClariusOEM_DIR}
    #--Download step--------------
    GIT_REPOSITORY ${ClariusOEM_GIT_REPOSITORY}
    GIT_TAG ${ClariusOEM_GIT_TAG}
    #--Configure step-------------
    CONFIGURE_COMMAND ""
    #--Build step-----------------
    BUILD_COMMAND ""
    #--Install step-----------------
    INSTALL_COMMAND ""
    DEPENDS ""
    )

  # download zipped lib/dll files
  
  SET(CLARIUS_OEM_PACKAGE_URL "https://github.com/clariusdev/oem/releases/download/v9.1.0/clarius-oem-v910-windows.zip")
  SET(CLARIUS_OEM_PACKAGE_SHA256 "534C1B25AA01C436911EC73B286AD46A488BCC02DBA9A6542EB749F961CA2DC1")

  ExternalProject_Add(ClariusOEM-Libs
    ${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}
    PREFIX ${ClariusOEM_PREFIX_DIR}
    SOURCE_DIR ${ClariusOEM_DIR}/src/lib
    #--Download step--------------
    URL ${CLARIUS_OEM_PACKAGE_URL}
    URL_HASH SHA256=${CLARIUS_OEM_PACKAGE_SHA256}
    #--Configure step-------------
    CONFIGURE_COMMAND ""
    #--Build step-----------------
    BUILD_COMMAND ""
    #--Install step-----------------
    INSTALL_COMMAND ""
    DEPENDS ClariusOEM
    )

ENDIF()