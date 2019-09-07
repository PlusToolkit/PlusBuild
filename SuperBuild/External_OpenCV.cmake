SET(PLUSBUILD_OpenCV_VERSION "3.4.7" CACHE STRING "Set OpenCV version (version: [major].[minor].[patch])")

IF(OpenCV_DIR)
  FIND_PACKAGE(OpenCV ${PLUSBUILD_OpenCV_VERSION} REQUIRED NO_MODULE)

  # Copy libraries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ${OpenCV_LIBS})

  SET(PLUS_OpenCV_DIR ${OpenCV_DIR} CACHE INTERNAL "Path to store OpenCV binaries")
 
  # Superbuild relies on existence of OpenCV target for dependency graph
  # Create a dummy target
  ADD_CUSTOM_TARGET(OpenCV)
ELSE()
  FIND_PACKAGE(CUDA QUIET)
  
  SET(OpenCV_PLATFORM_SPECIFIC_ARGS)
  SET(_cuda OFF)
  IF(CUDA_FOUND)
    IF(MSVC AND NOT "${CMAKE_GENERATOR}" MATCHES "Win64")
      # CUDA 32 bit is only available on versions <= 6.5
      IF(NOT ${CUDA_VERSION} VERSION_GREATER "6.5")
        SET(_cuda ON)
        LIST(APPEND OpenCV_PLATFORM_SPECIFIC_ARGS -DCUDA_TOOLKIT_ROOT_DIR:PATH=${CUDA_TOOLKIT_ROOT_DIR})
      ENDIF()
    ELSE()
      SET(_cuda ON)
      LIST(APPEND OpenCV_PLATFORM_SPECIFIC_ARGS -DCUDA_TOOLKIT_ROOT_DIR:PATH=${CUDA_TOOLKIT_ROOT_DIR})
    ENDIF()

    IF(_cuda)
      LIST(APPEND OpenCV_PLATFORM_SPECIFIC_ARGS -DWITH_CUDA:BOOL=ON)
    ELSE()
      LIST(APPEND OpenCV_PLATFORM_SPECIFIC_ARGS -DWITH_CUDA:BOOL=OFF)
    ENDIF()
    
    SET(_generations "Fermi" "Kepler" "Maxwell")
    IF(${CUDA_VERSION} VERSION_GREATER_EQUAL 8.0.0)
      LIST(APPEND _generations "Pascal" "Volta")
    ENDIF()
    IF(${CUDA_VERSION} VERSION_GREATER_EQUAL 10.0.0)
      LIST(APPEND _generations "Turing")
    ENDIF()
    IF(NOT CMAKE_CROSSCOMPILING)
      LIST(APPEND _generations "Auto")
    ENDIF()

    SET(PLUSBUILD_OpenCV_CUDA_GENERATION "" CACHE STRING "Build CUDA device code only for specific GPU architecture. Leave empty to build for all architectures.")
    set_property( CACHE PLUSBUILD_OpenCV_CUDA_GENERATION PROPERTY STRINGS "" ${_generations} )

    IF(PLUSBUILD_OpenCV_CUDA_GENERATION)
      IF(NOT ";${_generations};" MATCHES ";${PLUSBUILD_OpenCV_CUDA_GENERATION};")
        STRING(REPLACE ";" ", " _generations "${_generations}")
        MESSAGE(FATAL_ERROR "ERROR: Only CUDA ${_generations} generations are supported.")
      ENDIF()
    ENDIF()
    
    LIST(APPEND OpenCV_PLATFORM_SPECIFIC_ARGS -DCUDA_GENERATION:STRING=${PLUSBUILD_OpenCV_CUDA_GENERATION})
  ELSE()
    LIST(APPEND OpenCV_PLATFORM_SPECIFIC_ARGS -DWITH_CUDA:BOOL=OFF)
  ENDIF()
  
  IF(Qt5_FOUND)
    LIST(APPEND OpenCV_PLATFORM_SPECIFIC_ARGS -DWITH_QT:BOOL=ON -DQt5_DIR:PATH=${Qt5_DIR})
  ENDIF()

  IF(MSVC)
    LIST(APPEND OpenCV_PLATFORM_SPECIFIC_ARGS -DWITH_MSMF:BOOL=ON)
  ENDIF()

  IF(NOT PLUSBUILD_BUILD_SHARED_LIBS)
    LIST(APPEND OpenCV_PLATFORM_SPECIFIC_ARGS -DBUILD_WITH_STATIC_CRT:BOOL=OFF)
  ENDIF()

  # No OpenCV is specified, so download and build
  SetGitRepositoryTag(
    OpenCV
    "${GIT_PROTOCOL}://github.com/opencv/opencv.git"
    ${PLUSBUILD_OpenCV_VERSION}
    )

  SET (PLUS_OpenCV_src_DIR ${CMAKE_BINARY_DIR}/OpenCV CACHE INTERNAL "Path to store OpenCV contents.")
  SET (PLUS_OpenCV_prefix_DIR ${CMAKE_BINARY_DIR}/OpenCV-prefix CACHE INTERNAL "Path to store OpenCV prefix data.")
  SET (PLUS_OpenCV_DIR ${CMAKE_BINARY_DIR}/OpenCV-bin CACHE INTERNAL "Path to store OpenCV binaries")
  ExternalProject_Add( OpenCV
    PREFIX ${PLUS_OpenCV_prefix_DIR}
    "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
    SOURCE_DIR "${PLUS_OpenCV_src_DIR}"
    BINARY_DIR "${PLUS_OpenCV_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${OpenCV_GIT_REPOSITORY}
    GIT_TAG ${OpenCV_GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS
      ${ep_common_args}
      ${ep_qt_args}
      ${OpenCV_PLATFORM_SPECIFIC_ARGS}
      -DEXECUTABLE_OUTPUT_PATH:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      -DOpenCV_INSTALL_BINARIES_PREFIX:STRING= # Install to prefix directly, not arch/compiler/etc...
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DVTK_DIR:PATH=${PLUS_VTK_DIR}
      -DWITH_VTK:BOOL=ON
      -DBUILD_TESTS:BOOL=OFF
      -DBUILD_PERF_TESTS:BOOL=OFF
      -DBUILD_SHARED_LIBS:BOOL=${PLUSBUILD_BUILD_SHARED_LIBS}
      -DBUILD_DOCS:BOOL=OFF
    #--Build step-----------------
    BUILD_ALWAYS 1
    #--Install step-----------------
    INSTALL_COMMAND "" # Do not install, we have access to ${PLUS_OpenCV_DIR}/OpenCVConfig.cmake
    #--Dependencies-----------------
    DEPENDS ${VTK_BUILD_DEPENDENCY_TARGET}
    )
ENDIF()