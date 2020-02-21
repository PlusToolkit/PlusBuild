IF(OpenCV_DIR AND PLUSBUILD_USE_aruco)
  FIND_PACKAGE(OpenCV 4.2.0 REQUIRED NO_MODULE)

  IF(NOT OPENCV_ARUCO_FOUND)
    MESSAGE(FATAL_ERROR "OpenCV not built with aruco module enabled. Please specify a compatible OpenCV build.")
  ENDIF()

  MESSAGE(STATUS "Using aruco (in OpenCV-contrib) available at: ${OpenCV_DIR}")
ELSEIF(PLUSBUILD_USE_aruco)
  # aruco has not been built yet, so download and build it as an external project
  SetGitRepositoryTag(
    aruco
    "${GIT_PROTOCOL}://github.com/opencv/opencv_contrib"
    4.2.0
    )

  SET (PLUS_aruco_src_DIR ${CMAKE_BINARY_DIR}/OpenCV-contrib CACHE INTERNAL "Path to store aruco contents")
  SET (PLUS_aruco_prefix_DIR ${CMAKE_BINARY_DIR}/OpenCV-contrib-prefix CACHE INTERNAL "Path to store aruco prefix data.")
  SET (PLUS_aruco_DIR ${CMAKE_BINARY_DIR}/OpenCV-contrib-bin CACHE INTERNAL "Path to store aruco binaries.")

  ExternalProject_Add( aruco
    PREFIX ${PLUS_aruco_prefix_DIR}
    "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
    SOURCE_DIR "${PLUS_aruco_src_DIR}"
    BINARY_DIR "${PLUS_aruco_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${aruco_GIT_REPOSITORY}
    GIT_TAG ${aruco_GIT_TAG}
    #--Configure step-------------
    CONFIGURE_COMMAND "" # don't configure
    #--Build step-----------------
    BUILD_COMMAND "" # don't build
    #--Install step-----------------
    INSTALL_COMMAND "" # don't install
    #--Dependencies-----------------
    DEPENDS ""
  )
ENDIF()