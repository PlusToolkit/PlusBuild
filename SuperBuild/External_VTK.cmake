IF(VTK_DIR)
  # VTK has been built already
  FIND_PACKAGE(VTK REQUIRED)

  IF(NOT ${VTK_VERSION_MAJOR} GREATER 6)
    MESSAGE(FATAL_ERROR "VTK7+ required for Plus. Found VTK ${VTK_VERSION_MAJOR}.${VTK_VERSION_MINOR}.${VTK_VERSION_PATH}.")
    SET(VTK_DIR VTK-DIR_NOTFOUND FORCE)
  ENDIF()

  MESSAGE(STATUS "Using VTK available at: ${VTK_DIR}")

  # Copy libraries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ${VTK_LIBRARIES})

  SET(PLUS_VTK_DIR "${VTK_DIR}" CACHE INTERNAL "Path to store vtk binaries")

  IF((PLUSBUILD_BUILD_PLUSAPP OR PLUSBUILD_BUILD_PLUSLIB_WIDGETS) AND NOT TARGET vtkGUISupportQt)
    MESSAGE(SEND_ERROR "You have to build VTK with VTK_USE_QT flag ON if you need to use PLUSBUILD_BUILD_PLUSAPP.")
  ENDIF()

  # No target necessary, VTK is provided
  SET(VTK_BUILD_DEPENDENCY_TARGET CACHE INTERNAL "The name of the target to list as a dependency to ensure build order correctness.")
ELSE()
  # VTK has not been built yet, so download and build it as an external project
  IF(Qt5_FOUND)
    LIST(APPEND VTK_VERSION_SPECIFIC_ARGS -DVTK_Group_Qt:BOOL=ON)
    LIST(APPEND VTK_QT_ARGS -DVTK_QT_VERSION:STRING=${QT_VERSION_MAJOR})
  ENDIF()

  IF(APPLE)
    LIST(APPEND VTK_QT_ARGS
      -DVTK_USE_CARBON:BOOL=OFF
      -DVTK_USE_COCOA:BOOL=ON # Default to Cocoa, VTK/CMakeLists.txt will enable Carbon and disable cocoa if needed
      -DVTK_USE_X:BOOL=OFF
      )
  ENDIF()

  IF(PLUSBUILD_USE_Tesseract)
    LIST(APPEND VTK_VERSION_SPECIFIC_ARGS -DModule_vtkzlib:INTERNAL=ON)
  ENDIF()

  IF(MSVC)
    LIST(APPEND VTK_VERSION_SPECIFIC_ARGS -DCMAKE_CXX_MP_FLAG:BOOL=ON)
  ENDIF()

  SET(PLUSBUILD_EXTERNAL_VTK_VERSION "v8.2.0" CACHE STRING "User-selected VTK version to build Plus against")
  SET(_vtk_versions "v8.2.0")
  set_property( CACHE PLUSBUILD_EXTERNAL_VTK_VERSION PROPERTY STRINGS "" ${_vtk_versions} )

  IF(PLUSBUILD_EXTERNAL_VTK_VERSION STREQUAL "")
    SET(PLUSBUILD_EXTERNAL_VTK_VERSION "v8.2.0" CACHE STRING "User-selected VTK version to build Plus against" FORCE)
    SET(PLUSBUILD_VTK_VERSION 8.2.0 CACHE INTERNAL "Internal CMake version for VTK.")
  ELSE()
    STRING(FIND ${PLUSBUILD_EXTERNAL_VTK_VERSION} "." _is_tag)
    IF(_is_tag EQUAL -1)
      # not a tag, is a hash
      SET(PLUSBUILD_VTK_VERSION ${PLUSBUILD_EXTERNAL_VTK_VERSION})
    ELSE()
      STRING(REPLACE "v" "" _version_string ${PLUSBUILD_EXTERNAL_VTK_VERSION})
      STRING(REPLACE "." ";" _version_list ${_version_string})
      LIST(GET _version_list 0 _version_major)
      LIST(GET _version_list 1 _version_minor)
      LIST(GET _version_list 2 _version_patch)
      # List based variable is used elsewhere
      SET(PLUSBUILD_VTK_VERSION ${_version_major}.${_version_minor}.${_version_patch} CACHE INTERNAL "Internal CMake version for VTK.")
      SET(PLUSBUILD_VTK_VERSION_MAJOR ${_version_major})
      SET(PLUSBUILD_VTK_VERSION_MINOR ${_version_minor})
      SET(PLUSBUILD_VTK_VERSION_PATCH ${_version_patch})
    ENDIF()
  ENDIF()

  SetGitRepositoryTag(
    VTK
    "${GIT_PROTOCOL}://github.com/kitware/vtk.git"
    ${PLUSBUILD_EXTERNAL_VTK_VERSION}
    )

  SET (PLUS_VTK_SRC_DIR "${CMAKE_BINARY_DIR}/Deps/vtk")
  SET (PLUS_VTK_BIN_DIR "${CMAKE_BINARY_DIR}/Deps/vtk-bin" CACHE INTERNAL "Path to store vtk binaries")
  SET (PLUS_VTK_INSTALL_DIR "${CMAKE_BINARY_DIR}/Deps/vtk-int" CACHE INTERNAL "Path to install vtk")
  SET (PLUS_VTK_DIR ${PLUS_VTK_BIN_DIR})

  SET (VTK_INSTALL_OPTIONS "")
  IF (PLUSBUILD_INSTALL_VTK)
    LIST (APPEND VTK_INSTALL_OPTIONS 
      INSTALL_DIR "${PLUS_VTK_INSTALL_DIR}"
      )
    SET (PLUS_VTK_DIR "${PLUS_VTK_INSTALL_DIR}/lib/cmake/vtk-${PLUSBUILD_VTK_VERSION_MAJOR}.${PLUSBUILD_VTK_VERSION_MINOR}")
  ELSE()
    LIST (APPEND VTK_INSTALL_OPTIONS 
      INSTALL_COMMAND ""
      )    
  ENDIF()

  ExternalProject_Add( vtk
    "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
    PREFIX "${CMAKE_BINARY_DIR}/Deps/vtk-prefix"
    SOURCE_DIR "${PLUS_VTK_SRC_DIR}"
    BINARY_DIR "${PLUS_VTK_BIN_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${VTK_GIT_REPOSITORY}
    GIT_TAG ${VTK_GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS
      ${ep_common_args}
      ${ep_qt_args}
      ${VTK_VERSION_SPECIFIC_ARGS}
      -DCMAKE_INSTALL_PREFIX:PATH=${PLUS_VTK_INSTALL_DIR}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      -DBUILD_SHARED_LIBS:BOOL=${PLUSBUILD_BUILD_SHARED_LIBS}
      -DBUILD_TESTING:BOOL=OFF
      -DBUILD_EXAMPLES:BOOL=OFF
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DVTK_SMP_IMPLEMENTATION_TYPE:STRING="OpenMP"
      -DVTK_WRAP_PYTHON:BOOL=OFF
      -DVTK_RENDERING_BACKEND:STRING=${PLUSBUILD_VTK_RENDERING_BACKEND}
      -DCMAKE_DEBUG_POSTFIX:STRING=D
    #--Build step-----------------
    BUILD_ALWAYS 1
    DEPENDS ${VTK_DEPENDENCIES}
    #--Install step-----------------
    ${VTK_INSTALL_OPTIONS}
    )

  SET(VTK_BUILD_DEPENDENCY_TARGET vtk CACHE INTERNAL "The name of the target to list as a dependency to ensure build order correctness.")
ENDIF()