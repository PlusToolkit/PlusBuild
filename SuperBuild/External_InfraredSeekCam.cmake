IF(SeekCameraLib_DIR)
  FIND_PACKAGE(SeekCameraLib REQUIRED NO_MODULE)

  MESSAGE(STATUS "Using SeekCameraLib available at: ${SeekCameraLib_DIR}")

  # Copy libraries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ${SeekCameraLib_LIBRARIES})

  SET(PLUS_SeekCameraLib_DIR ${SeekCameraLib_DIR} CACHE INTERNAL "Path to store SeekCameraLib binaries")
ELSE()
  # SeekCameraLib has not been built yet, so download and build it as an external project
  SetGitRepositoryTag(
    SeekCameraLib
    "${GIT_PROTOCOL}://github.com/medtec4susdev/libseek-thermal.git"
    master
    )

  SET (PLUS_SeekCameraLib_SRC_DIR "${CMAKE_BINARY_DIR}/Deps/SeekCameraLib")
  SET (PLUS_SeekCameraLib_DIR "${CMAKE_BINARY_DIR}/Deps/SeekCameraLib-bin" CACHE INTERNAL "Path to store SeekCameraLib binaries")

  ExternalProject_Add( SeekCameraLib
    "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
    PREFIX "${CMAKE_BINARY_DIR}/Deps/SeekCameraLib-prefix"
    SOURCE_DIR "${PLUS_SeekCameraLib_SRC_DIR}"
    BINARY_DIR "${PLUS_SeekCameraLib_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${SeekCameraLib_GIT_REPOSITORY}
    GIT_TAG ${SeekCameraLib_GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS
      ${ep_common_args}
      -DLibUSB_ROOT_DIR:PATH=${LibUSB_ROOT_DIR}
      -DOpenCV_DIR:PATH=${PLUS_OpenCV_DIR}
      -DBUILD_EXAMPLES:BOOL=FALSE
      -DINSTALL_DLL:BOOL=FALSE
      -DWITH_ADDRESS_SANITIZER:BOOL=FALSE
      -DWITH_DEBUG_VERBOSITY:BOOL=FALSE
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
    DEPENDS LibUSB OpenCV ${SeekCameraLib_DEPENDENCIES}
   )
ENDIF()
