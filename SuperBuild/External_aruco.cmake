IF(aruco_DIR)
  FIND_PACKAGE(aruco 2.0.19 REQUIRED NO_MODULE)

  MESSAGE(STATUS "Using aruco available at: ${aruco_DIR}")

  # Copy libraries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ${aruco_LIBS})

  SET (PLUS_aruco_DIR ${aruco_DIR} CACHE INTERNAL "Path to store aruco binaries")
ELSE()
  # aruco has not been built yet, so download and build it as an external project
  SetGitRepositoryTag(
    aruco
    "${GIT_PROTOCOL}://github.com/PlusToolkit/aruco.git"
    "cf93865edf157aa45c64c8f2084dcef59e58dda3"
    )

  SET (PLUS_aruco_src_DIR ${CMAKE_BINARY_DIR}/Deps/aruco CACHE INTERNAL "Path to store aruco contents")
  SET (PLUS_aruco_prefix_DIR ${CMAKE_BINARY_DIR}/Deps/aruco-prefix CACHE INTERNAL "Path to store aruco prefix data.")
  SET (PLUS_aruco_DIR ${CMAKE_BINARY_DIR}/Deps/aruco-bin CACHE INTERNAL "Path to store aruco binaries.")

  ExternalProject_Add( aruco
    PREFIX ${PLUS_aruco_prefix_DIR}
    "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
    SOURCE_DIR "${PLUS_aruco_src_DIR}"
    BINARY_DIR "${PLUS_aruco_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${aruco_GIT_REPOSITORY}
    GIT_TAG ${aruco_GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS
      ${ep_common_args}
      ${aruco_PLATFORM_SPECIFIC_ARGS}
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      -DOpenCV_INSTALL_BINARIES_PREFIX:STRING= # Install to prefix directly, not arch/compiler/etc...
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DOpenCV_DIR:PATH=${PLUS_OpenCV_DIR}
      -DUSE_OWN_EIGEN3=OFF
      -DBUILD_TESTS:BOOL=OFF
      -DBUILD_PERF_TESTS:BOOL=OFF
      -DBUILD_SHARED_LIBS:BOOL=${PLUSBUILD_BUILD_SHARED_LIBS}
    #--Build step-----------------
    BUILD_ALWAYS 1
    #--Install step-----------------
    INSTALL_COMMAND "" # don't install
    #--Dependencies-----------------
    DEPENDS OpenCV
  )
ENDIF()