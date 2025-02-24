IF(ClariusOEM_DIR)

  FIND_PACKAGE(ClariusOEM REQUIRED)

  MESSAGE(STATUS "Using Clarius OEM library available at: ${ClariusOEM_DIR}")

  # Copy libraries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ${ClariusOEM_BINARY_PATH})

  SET(Plus_ClariusOEM_DIR ${ClariusOEM_DIR} CACHE PATH "Path to Clarius Solum SDK")
ELSE()

  SET(Plus_ClariusOEM_OUTER_SRC_DIR "${CMAKE_BINARY_DIR}/ClariusOEM")
  SET(Plus_ClariusOEM_DIR "${Plus_ClariusOEM_OUTER_SRC_DIR}" CACHE PATH "Path to Clarius Solum SDK")
  SET(Plus_ClariusOEM_PREFIX_DIR "${CMAKE_BINARY_DIR}/ClariusOEM-prefix")

  # download zipped header/lib/dll files

  SET(CLARIUS_OEM_PACKAGE_URL "https://github.com/clariusdev/solum/releases/download/v12.0.2/solum-12.0.2-windows.x86_64.zip")
  SET(CLARIUS_OEM_PACKAGE_SHA256 "07f6e77f48aa7b1667eb9c3048b775260c62d82e39730c298452a484b95c5cc4")

  ExternalProject_Add(ClariusOEM
    ${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}
    PREFIX ${Plus_ClariusOEM_PREFIX_DIR}
    SOURCE_DIR ${Plus_ClariusOEM_DIR}
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