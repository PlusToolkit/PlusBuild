IF(OpenIGTLinkIO_DIR)
  # OpenIGTLinkIO has been built already
  FIND_PACKAGE(OpenIGTLinkIO REQUIRED PATHS ${OpenIGTLinkIO_DIR} NO_DEFAULT_PATH)

  MESSAGE(STATUS "Using OpenIGTLinkIO available at: ${OpenIGTLinkIO_DIR}")
  
  # Copy libraries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
  IF( MSVC OR ${CMAKE_GENERATOR} MATCHES "Xcode" )
    FILE(COPY 
      ${OpenIGTLinkIO_LIBRARY_DIRS}/Release/
      DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Release
      FILES_MATCHING REGEX .*${CMAKE_SHARED_LIBRARY_SUFFIX}
      )
    FILE(COPY 
      ${OpenIGTLinkIO_LIBRARY_DIRS}/Debug/
      DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Debug
      FILES_MATCHING REGEX .*${CMAKE_SHARED_LIBRARY_SUFFIX}
      )    
  ELSE()
    FILE(COPY 
      ${OpenIGTLinkIO_LIBRARY_DIRS}/
      DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      FILES_MATCHING REGEX .*${CMAKE_SHARED_LIBRARY_SUFFIX}
      )
  ENDIF()

  SET (PLUS_OpenIGTLinkIO_DIR "${OpenIGTLinkIO_DIR}" CACHE INTERNAL "Path to store OpenIGTLinkIO binaries")
ELSE()
  # OpenIGTLinkIO has not been built yet, so download and build it as an external project
  MESSAGE(STATUS "Downloading OpenIGTLinkIO from ${GIT_PROTOCOL}://github.com/IGSIO/OpenIGTLinkIO.git")

  SET (PLUS_OpenIGTLinkIO_SRC_DIR "${CMAKE_BINARY_DIR}/Deps/OpenIGTLinkIO")
  SET (PLUS_OpenIGTLinkIO_DIR "${CMAKE_BINARY_DIR}/Deps/OpenIGTLinkIO-bin" CACHE INTERNAL "Path to store OpenIGTLinkIO binaries")
  ExternalProject_Add( OpenIGTLinkIO
    "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
    PREFIX "${CMAKE_BINARY_DIR}/Deps/OpenIGTLinkIO-prefix"
    SOURCE_DIR "${PLUS_OpenIGTLinkIO_SRC_DIR}"
    BINARY_DIR "${PLUS_OpenIGTLinkIO_DIR}"
    #--Download step--------------
    GIT_REPOSITORY "${GIT_PROTOCOL}://github.com/IGSIO/OpenIGTLinkIO.git"
    GIT_TAG "master"
    #--Configure step-------------
    CMAKE_ARGS 
      ${ep_common_args}
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      -DBUILD_SHARED_LIBS:BOOL=${PLUSBUILD_BUILD_SHARED_LIBS}
      -DBUILD_EXAMPLES:BOOL=OFF
      -DBUILD_TESTING:BOOL=OFF
      -DVTK_DIR:PATH=${PLUS_VTK_DIR}
      -DOpenIGTLink_DIR:PATH=${PLUS_OpenIGTLink_DIR}
      -DIGTLIO_USE_GUI:BOOL=OFF
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
    #--Build step-----------------
    #--Install step-----------------
    INSTALL_COMMAND ""
    DEPENDS ${OpenIGTLinkIO_DEPENDENCIES}
    )  
ENDIF()