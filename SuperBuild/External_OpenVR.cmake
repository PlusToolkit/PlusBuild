IF(OpenVR_DIR)
  # OpenVR has been built already
  FIND_PACKAGE(OpenVR REQUIRED)

  MESSAGE(STATUS "Using OpenVR available at: ${OpenVR_DIR}")

  # Copy libraries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} OpenVR)

  SET (PLUS_OVR_DIR ${OpenVR_DIR} CACHE INTERNAL "Path to store OpenVR SDK")
ELSEIF(OPENVR_ROOT_DIR)
  FIND_PACKAGE(OpenVR REQUIRED)

  MESSAGE(STATUS "Using OpenVR available at: ${OpenVR_DIR}")

  # Copy libraries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} OpenVR)

  SET (PLUS_OVR_DIR ${OPENVR_ROOT_DIR} CACHE INTERNAL "Path to store OpenVR SDK")
ELSE()
  # OpenVR has not been built yet, so download and build it as an external project
  SetGitRepositoryTag(
    OpenVR
    "https://github.com/ValveSoftware/openvr.git"
    "ebd425331229365dc3ec42d1bb8b2cc3c2332f81"
    )

  SET (PLUS_OpenVR_SRC_DIR "${CMAKE_BINARY_DIR}/OpenVR")
  SET (PLUS_OpenVR_DIR "${CMAKE_BINARY_DIR}/OpenVR" CACHE INTERNAL "Path to store OpenVR SDK")
  ExternalProject_Add( OpenVR
    "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
    PREFIX "${CMAKE_BINARY_DIR}/Deps/OpenVR-prefix"
    SOURCE_DIR "${PLUS_OpenVR_SRC_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${OpenVR_GIT_REPOSITORY}
    GIT_TAG ${OpenVR_GIT_TAG}
    #--Configure step-------------
    CONFIGURE_COMMAND ""
    #--Build step-----------------
    BUILD_COMMAND ""
    #--Install step-----------------
    INSTALL_COMMAND ""
    DEPENDS ${OpenVR_DEPENDENCIES}
    )

  SET(PLUS_OVR_DIR ${PLUS_OpenVR_SRC_DIR} CACHE INTERNAL "Path to store OpenVR SDK")
ENDIF()
