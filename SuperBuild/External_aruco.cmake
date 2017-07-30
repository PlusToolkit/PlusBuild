IF(aruco_DIR)
  FIND_PACKAGE(aruco 2.0.19 REQUIRED NO_MODULE)

  MESSAGE(STATUS "Using aruco available at: ${aruco_DIR}")

  FOREACH(lib ${aruco_LIBS})
    IF(NOT TARGET ${lib})
      continue()
    ENDIF()

    GET_TARGET_PROPERTY(DEBUG_FILE ${lib} IMPORTED_LOCATION_DEBUG)
    GET_TARGET_PROPERTY(RELEASE_FILE ${lib} IMPORTED_LOCATION_RELEASE)

    IF(MSVC OR ${CMAKE_GENERATOR} MATCHES "Xcode")
      IF(EXISTS ${RELEASE_FILE})
        FILE(COPY ${RELEASE_FILE} DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Release)
      ENDIF()
      IF(EXISTS ${DEBUG_FILE})
        FILE(COPY ${DEBUG_FILE} DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Debug)
      ENDIF()
    ELSE()
      IF(DEBUG_FILE EQUAL RELEASE_FILE AND EXISTS ${RELEASE_FILE})
        FILE(COPY ${RELEASE_FILE} DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
      ELSE()
        IF(EXISTS ${RELEASE_FILE})
          FILE(COPY ${RELEASE_FILE} DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
        ENDIF()
        IF(EXISTS ${DEBUG_FILE})
          FILE(COPY ${DEBUG_FILE} DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
        ENDIF()
      ENDIF()
    ENDIF()
  ENDFOREACH()

  SET (PLUS_aruco_DIR ${aruco_DIR} CACHE INTERNAL "Path to store aruco binaries")
ELSE()
  # aruco has not been built yet, so download and build it as an external project
  SET(aruco_GIT_REPOSITORY https://github.com/PlusToolkit/aruco.git)

  MESSAGE(STATUS "Downloading aruco from: ${aruco_GIT_REPOSITORY}")

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