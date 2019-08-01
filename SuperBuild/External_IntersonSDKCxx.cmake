# Check for path to IntersonSDK and raise an error during configure step
FIND_PATH(IntersonSDK_DIR 
  NAMES Libraries/Interson.dll
  PATHS C:/IntersonSDK )
IF(NOT IntersonSDK_DIR)
  MESSAGE(FATAL_ERROR "Please specify the path to the IntersonSDK in IntersonSDK_DIR")
ENDIF()

IF(IntersonSDKCxx_DIR)
  # IntersonSDKCxx has been built already
  FIND_PACKAGE(IntersonSDKCxx REQUIRED PATHS ${IntersonSDKCxx_DIR} NO_DEFAULT_PATH)
  
  MESSAGE(STATUS "Using IntersonSDKCxx available at: ${IntersonSDKCxx_DIR}")

  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ${IntersonSDKCxx_LIBRARIES})

  SET(PLUS_IntersonSDKCxx_DIR "${IntersonSDKCxx_DIR}" CACHE INTERNAL "Path to store IntersonSDKCxx binaries")
ELSE()
  # IntersonSDKCxx has not been built yet, so download and build it as an external project
  SetGitRepositoryTag(
    IntersonSDKCxx
    "${GIT_PROTOCOL}://github.com/KitwareMedical/IntersonSDKCxx.git"
    "819d620052be7e9b232e12d8946793c15cfbf5a3"
    )

  SET (PLUS_IntersonSDKCxx_SRC_DIR "${CMAKE_BINARY_DIR}/IntersonSDKCxx")
  SET (PLUS_IntersonSDKCxx_DIR "${CMAKE_BINARY_DIR}/IntersonSDKCxx-bin" CACHE INTERNAL "Path to store IntersonSDKCxx binaries")
  ExternalProject_Add( IntersonSDKCxx
    PREFIX "${CMAKE_BINARY_DIR}/IntersonSDKCxx-prefix"
    SOURCE_DIR "${PLUS_IntersonSDKCxx_SRC_DIR}"
    BINARY_DIR "${PLUS_IntersonSDKCxx_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${IntersonSDKCxx_GIT_REPOSITORY}
    GIT_TAG ${IntersonSDKCxx_GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS 
      ${ep_common_args}
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      -DBUILD_SHARED_LIBS:BOOL=${PLUSBUILD_BUILD_SHARED_LIBS} 
      -DBUILD_TESTING:BOOL=OFF
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
    #--Build step-----------------
    BUILD_ALWAYS 1    
    #--Install step-----------------
    INSTALL_COMMAND ""
    DEPENDS ${IntersonSDKCxx_DEPENDENCIES}
    )
ENDIF()