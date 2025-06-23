IF(ITK_DIR)
  # ITK has been built already
  FIND_PACKAGE(ITK 5.4 REQUIRED PATHS ${ITK_DIR} NO_DEFAULT_PATH)

  MESSAGE(STATUS "Using ITK available at: ${ITK_DIR}")

  # Copy libraries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ${ITK_LIBRARIES})

  SET (PLUS_ITK_DIR ${ITK_DIR} CACHE INTERNAL "Path to store itk binaries")
ELSE()

  SET (PLUS_ITK_VERSION_MAJOR 5)
  SET (PLUS_ITK_VERSION_MINOR 4)
  SET (PLUS_ITK_VERSION_PATCH 2)
  SET (PLUS_ITK_VERSION_STRING "v${PLUS_ITK_VERSION_MAJOR}.${PLUS_ITK_VERSION_MINOR}.${PLUS_ITK_VERSION_PATCH}")
  IF (PLUS_ITK_VERSION EQUAL 4)
    MESSAGE(WARNING "ITK 4.12.0 is not recommended! It should only be used to build Plus with support for devices which require Visual Studio 2013!")
    SET (PLUS_ITK_VERSION_MAJOR 4)
    SET (PLUS_ITK_VERSION_MINOR 12)
    SET (PLUS_ITK_VERSION_PATCH 0)
    SET (PLUS_ITK_VERSION_STRING "v${PLUS_ITK_VERSION_MAJOR}.${PLUS_ITK_VERSION_MINOR}.${PLUS_ITK_VERSION_PATCH}")
  ENDIF()
  # ITK has not been built yet, so download and build it as an external project
  SetGitRepositoryTag(
    itk
    "https://github.com/InsightSoftwareConsortium/ITK"
    ${PLUS_ITK_VERSION_STRING}
    )

  OPTION(PLUS_ITK_USE_SYSTEM_PNG "Use system PNG library for ITK" OFF)
  MARK_AS_ADVANCED(PLUS_ITK_USE_SYSTEM_PNG)

  IF(PLUS_ITK_USE_SYSTEM_PNG)
    LIST(APPEND PLUS_ITK_OPTIONAL_ARGS -DITK_USE_SYSTEM_PNG:BOOL=ON)
  ENDIF()

  IF(UNIX AND NOT APPLE)

    SET(itk_common_cxx_flags "${ep_common_cxx_flags} -std=c++${CMAKE_CXX_STANDARD}")
  ELSEIF(MSVC)
    SET(itk_common_cxx_flags "${itk_common_cxx_flags} /MP ")
  ENDIF()

  SET (PLUS_ITK_SRC_DIR "${CMAKE_BINARY_DIR}/itk")
  SET (PLUS_ITK_BIN_DIR "${CMAKE_BINARY_DIR}/itk-bin" CACHE INTERNAL "Path to store itk binaries")
  SET (PLUS_ITK_INSTALL_DIR "${CMAKE_BINARY_DIR}/itk-int" CACHE INTERNAL "Path to install vtk")
  SET (PLUS_ITK_DIR ${PLUS_ITK_BIN_DIR})

  SET (ITK_INSTALL_COMMAND "")
  IF (PLUSBUILD_INSTALL_ITK)
    SET (PLUS_ITK_DIR "${PLUS_ITK_INSTALL_DIR}/lib/cmake/ITK-${PLUS_ITK_VERSION_MAJOR}.${PLUS_ITK_VERSION_MINOR}" CACHE INTERNAL "Path to installed itk binaries")
  ELSE()
    SET (ITK_INSTALL_COMMAND
      INSTALL_COMMAND ""
      )
  ENDIF()

  ExternalProject_Add( itk
    "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
    PREFIX "${CMAKE_BINARY_DIR}/itk-prefix"
    SOURCE_DIR "${PLUS_ITK_SRC_DIR}"
    BINARY_DIR "${PLUS_ITK_BIN_DIR}"
    INSTALL_DIR "${PLUS_ITK_INSTALL_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${itk_GIT_REPOSITORY}
    GIT_TAG ${itk_GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS
      ${ep_common_args}
      ${PLUS_ITK_OPTIONAL_ARGS}
      -DCMAKE_INSTALL_PREFIX:PATH=${PLUS_ITK_INSTALL_DIR}
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      -DBUILD_SHARED_LIBS:BOOL=${PLUSBUILD_BUILD_SHARED_LIBS}
      -DBUILD_TESTING:BOOL=OFF
      -DBUILD_EXAMPLES:BOOL=OFF
      -DITK_LEGACY_REMOVE:BOOL=OFF
      -DKWSYS_USE_MD5:BOOL=ON
      -DITK_USE_REVIEW:BOOL=ON
      -DITK_CXX_OPTIMIZATION_FLAGS:STRING= # Force compiler-default instruction set to ensure compatibility with older CPUs
      -DITK_C_OPTIMIZATION_FLAGS:STRING=  # Force compiler-default instruction set to ensure compatibility with older CPUs
      -DCMAKE_CXX_FLAGS:STRING=${itk_common_cxx_flags}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DCMAKE_DEBUG_POSTFIX:STRING=D
    #--Build step-----------------
    BUILD_ALWAYS 1
    DEPENDS ${ITK_DEPENDENCIES}
    #--Install step-----------------
    "${ITK_INSTALL_COMMAND}"
    )
ENDIF()
