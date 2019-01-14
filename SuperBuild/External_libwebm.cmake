IF(libwebm_DIR)
  # libwebm has been built already
  FIND_PACKAGE(libwebm REQUIRED NO_MODULE)
  MESSAGE(STATUS "Using libwebm available at: ${libwebm_DIR}")
  
  # Copy libraries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ${libwebm_LIBRARIES})

  SET (PLUS_libwebm_DIR "${libwebm_DIR}" CACHE INTERNAL "Path to store libwebm binaries")
ELSE()

 SetGitRepositoryTag(
   libwebm
   "${GIT_PROTOCOL}://github.com/Sunderlandkyl/libwebm.git"
   "e1d4caa3f52d9496a7910b5cbbf280056e994030"
   )

 SET (PLUS_libwebm_SRC_DIR ${CMAKE_BINARY_DIR}/Deps/libwebm CACHE INTERNAL "Path to store libwebm contents.")
 SET (PLUS_libwebm_PREFIX_DIR ${CMAKE_BINARY_DIR}/Deps/libwebm-prefix CACHE INTERNAL "Path to store libwebm prefix data.")
 SET (PLUS_libwebm_DIR ${CMAKE_BINARY_DIR}/Deps/libwebm-bin CACHE INTERNAL "Path to store libwebm binaries")

 ExternalProject_Add( libwebm
   PREFIX ${PLUS_libwebm_PREFIX_DIR}
   "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
   SOURCE_DIR ${PLUS_libwebm_SRC_DIR}
   BINARY_DIR ${PLUS_libwebm_DIR}
   #--Download step--------------
   GIT_REPOSITORY ${libwebm_GIT_REPOSITORY}
   GIT_TAG ${libwebm_GIT_TAG}
   #--Configure step-------------
   CMAKE_ARGS
     ${ep_common_args}
     -DEXECUTABLE_OUTPUT_PATH:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
     -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
     -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
     -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
     -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
     -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
     -DBUILD_SHARED_LIBS:BOOL=OFF
     # Options
     -DENABLE_WEBMINFO:BOOL=OFF
     -DENABLE_WEBMTS:BOOL=OFF
     -DENABLE_WEBM_PARSER:BOOL=OFF
     -DENABLE_SAMPLES:BOOL=OFF
     -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS:BOOL=ON
   #--Build step-----------------
   BUILD_ALWAYS 1
   #--Install step-----------------
   INSTALL_COMMAND ""
   )
ENDIF()
