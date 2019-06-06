IF(ITK_DIR)
  # ITK has been built already
  FIND_PACKAGE(ITK 5.0.0 REQUIRED PATHS ${ITK_DIR} NO_DEFAULT_PATH)

  MESSAGE(STATUS "Using ITK available at: ${ITK_DIR}")

  # Copy libraries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ${ITK_LIBRARIES})

  SET (PLUS_ITK_DIR ${ITK_DIR} CACHE INTERNAL "Path to store itk binaries")
ELSE()

  SET (PLUS_ITK_VERSION_MAJOR 5)
  SET (PLUS_ITK_VERSION_MINOR 0)
  SET (PLUS_ITK_VERSION_PATCH 0)
  # ITK has not been built yet, so download and build it as an external project
  SetGitRepositoryTag(
    itk
    "${GIT_PROTOCOL}://itk.org/ITK.git"
    "v${PLUS_ITK_VERSION_MAJOR}.${PLUS_ITK_VERSION_MINOR}.${PLUS_ITK_VERSION_PATCH}"
    )

  IF(UNIX AND NOT APPLE)
    SET(itk_common_cxx_flags "${ep_common_cxx_flags} -std=c++11")
  ELSEIF(MSVC)
    SET(itk_common_cxx_flags "${itk_common_cxx_flags} /MP ")
  ENDIF()

  SET (PLUS_ITK_SRC_DIR "${CMAKE_BINARY_DIR}/Deps/itk")
  SET (PLUS_ITK_BIN_DIR "${CMAKE_BINARY_DIR}/Deps/itk-bin" CACHE INTERNAL "Path to store itk binaries")
  SET (PLUS_ITK_INSTALL_DIR "${CMAKE_BINARY_DIR}/Deps/itk-int" CACHE INTERNAL "Path to install vtk")
  SET (PLUS_ITK_DIR ${PLUS_ITK_BIN_DIR})

  SET (ITK_INSTALL_OPTIONS "")
  IF (PLUSBUILD_INSTALL_ITK)
    LIST (APPEND ITK_INSTALL_OPTIONS 
      INSTALL_DIR "${PLUS_ITK_INSTALL_DIR}"
      )
    SET (PLUS_ITK_DIR "${PLUS_ITK_INSTALL_DIR}/lib/cmake/ITK-${PLUS_ITK_VERSION_MAJOR}.${PLUS_ITK_VERSION_MINOR}" CACHE INTERNAL "Path to installed itk binaries")
  ELSE()
    LIST (APPEND ITK_INSTALL_OPTIONS 
      INSTALL_COMMAND ""
      )    
  ENDIF()

  ExternalProject_Add( itk
    "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
    PREFIX "${CMAKE_BINARY_DIR}/Deps/itk-prefix"
    SOURCE_DIR "${PLUS_ITK_SRC_DIR}"
    BINARY_DIR "${PLUS_ITK_BIN_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${itk_GIT_REPOSITORY}
    GIT_TAG ${itk_GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS
      ${ep_common_args}
      -DCMAKE_INSTALL_PREFIX:PATH=${PLUS_ITK_INSTALL_DIR}
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      -DBUILD_SHARED_LIBS:BOOL=${PLUSBUILD_BUILD_SHARED_LIBS}
      -DBUILD_TESTING:BOOL=OFF
      -DBUILD_EXAMPLES:BOOL=OFF
      -DITK_LEGACY_REMOVE:BOOL=ON
      -DKWSYS_USE_MD5:BOOL=ON
      -DITK_USE_REVIEW:BOOL=ON
      -DCMAKE_CXX_FLAGS:STRING=${itk_common_cxx_flags}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DCMAKE_DEBUG_POSTFIX:STRING=D
    #--Build step-----------------
    BUILD_ALWAYS 1
    DEPENDS ${ITK_DEPENDENCIES}
    #--Install step-----------------
    ${ITK_INSTALL_OPTIONS}
    )
ENDIF()