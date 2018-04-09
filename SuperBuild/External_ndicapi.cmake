IF(ndicapi_DIR)
  FIND_PACKAGE(ndicapi REQUIRED NO_MODULE)

  MESSAGE(STATUS "Using ndicapi available at: ${ndicapi_DIR}")
  
  IF(MSVC OR ${CMAKE_GENERATOR} MATCHES "Xcode")
    SET(_rel_dest ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Release)
    SET(_deb_dest ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Debug)
  ELSE()
    SET(_rel_dest ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
    SET(_deb_dest ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
  ENDIF()

  GET_TARGET_PROPERTY(_ndi_debug_dll ndicapi IMPORTED_LOCATION_DEBUG)
  IF(_ndi_debug_dll)
    FILE(COPY _ndi_debug_dll DESTINATION ${_deb_dest})
  ENDIF()
  
  GET_TARGET_PROPERTY(_ndi_release_dll ndicapi IMPORTED_LOCATION_RELEASE)
  IF(_ndi_release_dll)
    FILE(COPY _ndi_release_dll DESTINATION ${_rel_dest})
  ENDIF()
  
  GET_TARGET_PROPERTY(_ndi_dll ndicapi IMPORTED_LOCATION)
  IF(_ndi_dll)
    FILE(COPY _ndi_dll DESTINATION ${_deb_dest})
    FILE(COPY _ndi_dll DESTINATION ${_rel_dest})
  ENDIF()

  SET(PLUS_ndicapi_DIR ${ndicapi_DIR} CACHE INTERNAL "Path to store ndicapi binaries")
ELSE()
  SetGitRepositoryTag(
    ndicapi
    "${GIT_PROTOCOL}://github.com/PlusToolkit/ndicapi.git"
    "c79aec212c0793c3cb0cfb3acd6435ff2ac4cdc1"
    )

  # --------------------------------------------------------------------------
  # OvrvisionPro SDK
  SET (PLUS_ndicapi_src_DIR ${CMAKE_BINARY_DIR}/Deps/ndicapi CACHE INTERNAL "Path to store ndicapi contents.")
  SET (PLUS_ndicapi_prefix_DIR ${CMAKE_BINARY_DIR}/Deps/ndicapi-prefix CACHE INTERNAL "Path to store ndicapi prefix data.")
  SET (PLUS_ndicapi_DIR ${CMAKE_BINARY_DIR}/Deps/ndicapi-bin CACHE INTERNAL "Path to store ndicapi binaries")
  
  ExternalProject_Add( ndicapi
    PREFIX ${PLUS_ndicapi_prefix_DIR}
    "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
    SOURCE_DIR "${PLUS_ndicapi_src_DIR}"
    BINARY_DIR "${PLUS_ndicapi_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${ndicapi_GIT_REPOSITORY}
    GIT_TAG ${ndicapi_GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS
      ${ep_common_args}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DBUILD_SHARED_LIBS:BOOL=${PLUSBUILD_BUILD_SHARED_LIBS}
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
    #--Build step-----------------
    BUILD_ALWAYS 1
    #--Override install step-----------------
    INSTALL_COMMAND "" # Do not install
    #--Dependencies-----------------
    DEPENDS ""
    )
ENDIF()
