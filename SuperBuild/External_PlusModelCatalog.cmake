# --------------------------------------------------------------------------
# PlusModelCatalog

SetGitRepositoryTag(
  PlusModelCatalog
  "https://github.com/PlusToolkit/PlusModelCatalog.git"
  "0f0d0a511bed5010b95c6df5ba498fe16d148820"
  )

SET (PLUS_PLUSMODELCATALOG_DIR ${CMAKE_BINARY_DIR}/PlusModelCatalog CACHE INTERNAL "Path to store Plus Model Catalog.")
ExternalProject_Add(PlusModelCatalog
  "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
  SOURCE_DIR "${PLUS_PLUSMODELCATALOG_DIR}"
  BINARY_DIR "PlusModelCatalog-bin"
  #--Download step--------------
  GIT_REPOSITORY ${PlusModelCatalog_GIT_REPOSITORY}
  GIT_TAG ${PlusModelCatalog_GIT_TAG}
  #--Configure step-------------
  CMAKE_ARGS
    ${ep_common_args}
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
    -DPLUSLIB_DIR:PATH=${PLUSLIB_DIR}
    -DGIT_EXECUTABLE:FILEPATH=${GIT_EXECUTABLE}
    -DGITCOMMAND:FILEPATH=${GITCOMMAND}
    -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
    -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
  #--Build step-----------------
  BUILD_ALWAYS 1
  #--Install step-----------------
  INSTALL_COMMAND ""
  DEPENDS ${PlusModelCatalog_DEPENDENCIES}
  )
SET(PlusModelCatalog_DIR ${CMAKE_BINARY_DIR}/PlusModelCatalog-bin CACHE PATH "The directory containing Plus Model Catalog generated files" FORCE)
