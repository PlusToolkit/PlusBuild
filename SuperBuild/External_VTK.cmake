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

  IF(PLUSBUILD_BUILD_PLUSAPP AND NOT TARGET vtkGUISupportQt)
    MESSAGE(SEND_ERROR "You have to build VTK with VTK_USE_QT flag ON if you need to use PLUSBUILD_BUILD_PLUSAPP.")
  ENDIF()

  # No target necessary, VTK is provided
  SET(VTK_BUILD_DEPENDENCY_TARGET CACHE INTERNAL "The name of the target to list as a dependency to ensure build order correctness.")
ELSE()
  # VTK has not been built yet, so download and build it as an external project
  SET(VTK_VERSION_SPECIFIC_ARGS)
  IF(PLUSBUILD_BUILD_PLUSAPP)
    LIST(APPEND VTK_VERSION_SPECIFIC_ARGS -DVTK_Group_Qt:BOOL=ON)
  ENDIF()

  SET(VTK_QT_ARGS)
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

  SET(PLUSBUILD_EXTERNAL_VTK_VERSION "v7.1.0" CACHE STRING "Which VTK version to build Plus against")
  SET(_vtk_versions "v7.1.0" "v8.1.0" "v9.0.0")
  set_property( CACHE PLUSBUILD_EXTERNAL_VTK_VERSION PROPERTY STRINGS "" ${_vtk_versions} )

  IF(PLUSBUILD_EXTERNAL_VTK_VERSION STREQUAL "")
    SET(PLUSBUILD_EXTERNAL_VTK_VERSION "v7.1.0" CACHE STRING "Which VTK version to build Plus against" FORCE)
    SET(PLUSBUILD_VTK_VERSION "v7.1.0" CACHE INTERNAL "VTK version chosen to build.")
  ELSEIF(PLUSBUILD_EXTERNAL_VTK_VERSION STREQUAL "v9.0.0")
    # No v9.0.0 tag yet, replace with specific hash
    SET(PLUSBUILD_EXTERNAL_VTK_VERSION "eee2024889dcaf4ef8168da372b9859b457d66c9" CACHE STRING "Which VTK version to build Plus against" FORCE)
    SET(PLUSBUILD_VTK_VERSION "v9.0.0" CACHE INTERNAL "VTK version chosen to build.")
  ELSE()
    SET(PLUSBUILD_VTK_VERSION ${PLUSBUILD_EXTERNAL_VTK_VERSION} CACHE INTERNAL "VTK version chosen to build.")
  ENDIF()

  SetGitRepositoryTag(
    VTK
    "${GIT_PROTOCOL}://github.com/kitware/vtk.git"
    ${PLUSBUILD_EXTERNAL_VTK_VERSION}
    )

  SET (PLUS_VTK_SRC_DIR "${CMAKE_BINARY_DIR}/Deps/vtk")
  SET (PLUS_VTK_DIR "${CMAKE_BINARY_DIR}/Deps/vtk-bin" CACHE INTERNAL "Path to store vtk binaries")

  ExternalProject_Add( vtk
    "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
    PREFIX "${CMAKE_BINARY_DIR}/Deps/vtk-prefix"
    SOURCE_DIR "${PLUS_VTK_SRC_DIR}"
    BINARY_DIR "${PLUS_VTK_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${VTK_GIT_REPOSITORY}
    GIT_TAG ${VTK_GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS 
      ${ep_common_args}
      ${ep_qt_args}
      ${VTK_VERSION_SPECIFIC_ARGS}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      -DBUILD_SHARED_LIBS:BOOL=${PLUSBUILD_BUILD_SHARED_LIBS}
      -DBUILD_TESTING:BOOL=OFF 
      -DBUILD_EXAMPLES:BOOL=OFF
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DVTK_SMP_IMPLEMENTATION_TYPE:STRING="OpenMP"
      -DVTK_QT_VERSION:STRING=${QT_VERSION_MAJOR}
      -DVTK_WRAP_PYTHON:BOOL=OFF
      -DVTK_RENDERING_BACKEND=${PLUSBUILD_VTK_RENDERING_BACKEND}
    #--Build step-----------------
    BUILD_ALWAYS 1
    #--Install step-----------------
    INSTALL_COMMAND ""
    DEPENDS ${VTK_DEPENDENCIES}
    )

  SET(VTK_BUILD_DEPENDENCY_TARGET vtk CACHE INTERNAL "The name of the target to list as a dependency to ensure build order correctness.")
ENDIF()