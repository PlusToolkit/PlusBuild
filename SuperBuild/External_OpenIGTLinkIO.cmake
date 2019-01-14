IF(OpenIGTLinkIO_DIR)
  # OpenIGTLinkIO has been built already
  FIND_PACKAGE(OpenIGTLinkIO REQUIRED PATHS ${OpenIGTLinkIO_DIR} NO_DEFAULT_PATH)

  MESSAGE(STATUS "Using OpenIGTLinkIO available at: ${OpenIGTLinkIO_DIR}")
  
  # Copy libraries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ${OpenIGTLinkIO_LIBRARIES})

  SET (PLUS_OpenIGTLinkIO_DIR "${OpenIGTLinkIO_DIR}" CACHE INTERNAL "Path to store OpenIGTLinkIO binaries")
ELSE()
  # OpenIGTLinkIO has not been built yet, so download and build it as an external project
  SetGitRepositoryTag(
    OpenIGTLinkIO
    "${GIT_PROTOCOL}://github.com/IGSIO/OpenIGTLinkIO.git"
    "1a2eda5ddb795df8bb5bfbba589c9650095ba4cd"
    )

  SET (PLUS_OpenIGTLinkIO_SRC_DIR "${CMAKE_BINARY_DIR}/Deps/OpenIGTLinkIO")
  SET (PLUS_OpenIGTLinkIO_DIR "${CMAKE_BINARY_DIR}/Deps/OpenIGTLinkIO-bin" CACHE INTERNAL "Path to store OpenIGTLinkIO binaries")
  ExternalProject_Add( OpenIGTLinkIO
    "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
    PREFIX "${CMAKE_BINARY_DIR}/Deps/OpenIGTLinkIO-prefix"
    SOURCE_DIR "${PLUS_OpenIGTLinkIO_SRC_DIR}"
    BINARY_DIR "${PLUS_OpenIGTLinkIO_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${OpenIGTLinkIO_GIT_REPOSITORY}
    GIT_TAG ${OpenIGTLinkIO_GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS 
      ${ep_common_args}
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      -DBUILD_SHARED_LIBS:BOOL=${PLUSBUILD_BUILD_SHARED_LIBS}
      -DBUILD_EXAMPLES:BOOL=OFF
      -DBUILD_TESTING:BOOL=OFF
      -DVTK_DIR:PATH=${PLUS_VTK_DIR}
      -DOpenIGTLink_DIR:PATH=${PLUS_OpenIGTLink_DIR}
      -DIGTLIO_USE_GUI:BOOL=OFF
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
    #--Build step-----------------
    #--Install step-----------------
    INSTALL_COMMAND ""
    DEPENDS ${OpenIGTLinkIO_DEPENDENCIES}
    )  
ENDIF()