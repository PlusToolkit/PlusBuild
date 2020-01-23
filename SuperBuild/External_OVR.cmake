IF(OVR_DIR)
  # OpenVR has been built already
  FIND_PACKAGE(OVR REQUIRED NO_MODULE)

  MESSAGE(STATUS "Using OpenVR available at: ${OVR_DIR}")

  # Copy libraries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ${OVR_LIBRARIES})

  SET (PLUS_OVR_DIR ${OVR_DIR} CACHE INTERNAL "Path to store OpenVR binaries")
ELSE()
  # OpenVR has not been built yet, so download and build it as an external project
  SetGitRepositoryTag(
    OVR
    "${GIT_PROTOCOL}://github.com/ValveSoftware/openvr.git"
    "master"
    )

  SET (PLUS_OVR_SRC_DIR "${CMAKE_BINARY_DIR}/Deps/OpenVR")
  SET (PLUS_OVR_DIR "${CMAKE_BINARY_DIR}/Deps/OpenVR" CACHE INTERNAL "Path to store OpenVR binaries")
  ExternalProject_Add( OVR
    "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
    PREFIX "${CMAKE_BINARY_DIR}/Deps/OpenVR-prefix"
    SOURCE_DIR "${PLUS_OVR_SRC_DIR}"
    BINARY_DIR "${PLUS_OVR_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${OVR_GIT_REPOSITORY}
    GIT_TAG ${OVR_GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS 
      ${ep_common_args}
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      -DBUILD_SHARED_LIBS:BOOL=${PLUSBUILD_BUILD_SHARED_LIBS}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
    #--Build step-----------------
    BUILD_ALWAYS 1
    #--Install step-----------------
    INSTALL_COMMAND ""
    DEPENDS ${OVR_DEPENDENCIES}
    )

ENDIF()
