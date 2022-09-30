# Windows 64 bit path hints
SET (PLATFORM_SUFFIX "Win10 - x64")
IF(WIN32 AND CMAKE_SIZEOF_VOID_P EQUAL 4)
  # Windows 32 bit path hints
  SET(PLATFORM_SUFFIX "Win10 - x86")
ENDIF()

SET(IntersonArray_PATH_HINTS
  C:/IntersonArraySDK/Libraries/${PLATFORM_SUFFIX}
  ../PLTools/Interson/ArraySDK_3.007_2021-11/Libraries/${PLATFORM_SUFFIX}
  ../../PLTools/Interson/ArraySDK_3.007_2021-11/Libraries/${PLATFORM_SUFFIX}
  )

# Check for path to IntersonArraySDK and raise an error during configure step
FIND_PATH(IntersonArraySDK_DIR
  NAMES IntersonArray.dll
  PATHS ${IntersonArray_PATH_HINTS} )
IF(NOT IntersonArraySDK_DIR)
  MESSAGE(FATAL_ERROR "Please specify the path to the IntersonArraySDK in IntersonArraySDK_DIR")
ENDIF()

IF(IntersonArraySDKCxx_DIR)
  # IntersonArraySDKCxx has been built already
  FIND_PACKAGE(IntersonArraySDKCxx REQUIRED PATHS ${IntersonArraySDKCxx_DIR} NO_DEFAULT_PATH)

  MESSAGE(STATUS "Using IntersonArraySDKCxx available at: ${IntersonArraySDKCxx_DIR}")

  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ${IntersonArraySDKCxx_LIBRARIES})

  SET(PLUS_IntersonArraySDKCxx_DIR "${IntersonArraySDKCxx_DIR}" CACHE INTERNAL "Path to store IntersonArraySDKCxx binaries")
ELSE()
  # IntersonArraySDKCxx has not been built yet, so download and build it as an external project
  SetGitRepositoryTag(
    IntersonArraySDKCxx
    "${GIT_PROTOCOL}://github.com/KitwareMedical/IntersonArraySDKCxx.git"
    "master"
    )

  SET (PLUS_IntersonArraySDKCxx_SRC_DIR "${CMAKE_BINARY_DIR}/IntersonArraySDKCxx")
  SET (PLUS_IntersonArraySDKCxx_DIR "${CMAKE_BINARY_DIR}/IntersonArraySDKCxx-bin" CACHE INTERNAL "Path to store IntersonArraySDKCxx binaries")
  ExternalProject_Add( IntersonArraySDKCxx
    PREFIX "${CMAKE_BINARY_DIR}/IntersonArraySDKCxx-prefix"
    SOURCE_DIR "${PLUS_IntersonArraySDKCxx_SRC_DIR}"
    BINARY_DIR "${PLUS_IntersonArraySDKCxx_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${IntersonArraySDKCxx_GIT_REPOSITORY}
    GIT_TAG ${IntersonArraySDKCxx_GIT_TAG}
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
      -DIntersonArraySDK_DIR:PATH=${IntersonArraySDK_DIR}
    #--Build step-----------------
    BUILD_ALWAYS 1
    #--Install step-----------------
    INSTALL_COMMAND ""
    DEPENDS ${IntersonArraySDKCxx_DEPENDENCIES}
    )
ENDIF()