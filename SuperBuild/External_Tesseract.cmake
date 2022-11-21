SET(tesseract_DEPENDENCIES leptonica)
IF(TARGET vtk)
  SET(leptonica_DEPENDENCIES vtk) #for vtkzlib
ENDIF()
SET(tesseract_ROOT_DIR ${CMAKE_BINARY_DIR})

# --------------------------------------------------------------------------
# leptonica
SetGitRepositoryTag(
  leptonica
  "${GIT_PROTOCOL}://github.com/PlusToolkit/leptonica.git"
  "master"
  )

IF(leptonica_DIR)
  FIND_PACKAGE(leptonica REQUIRED NO_MODULE)

  SET(PLUS_leptonica_DIR ${leptonica_DIR} CACHE INTERNAL "Path to store leptonica binaries.")
ELSE()
  SET (PLUS_leptonica_src_DIR ${tesseract_ROOT_DIR}/leptonica CACHE INTERNAL "Path to store leptonica contents.")
  SET (PLUS_leptonica_prefix_DIR ${tesseract_ROOT_DIR}/leptonica-prefix CACHE INTERNAL "Path to store leptonica prefix data.")
  SET (PLUS_leptonica_DIR "${tesseract_ROOT_DIR}/leptonica-bin" CACHE INTERNAL "Path to store leptonica binaries.")
  ExternalProject_Add( leptonica
    PREFIX ${PLUS_leptonica_prefix_DIR}
    "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
    SOURCE_DIR "${PLUS_leptonica_src_DIR}"
    BINARY_DIR "${PLUS_leptonica_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${leptonica_GIT_REPOSITORY}
    GIT_TAG ${leptonica_GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS
        ${ep_common_args}
        -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
        -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
        -DCMAKE_PREFIX_PATH:STRING=${CMAKE_PREFIX_PATH}
        -DVTK_DIR:PATH=${PLUS_VTK_DIR} #get vtkzlib and vtkpng from vtk
    #--Build step-----------------
    #--Install step-----------------
    INSTALL_COMMAND "" #don't install
    #--Dependencies-----------------
    DEPENDS ${leptonica_DEPENDENCIES}
    )
ENDIF()

# --------------------------------------------------------------------------
# tessdata
SetGitRepositoryTag(
  tessdata
  "${GIT_PROTOCOL}://github.com/PlusToolkit/tessdata.git"
  "master"
  )

IF(tessdata_DIR)
  IF(NOT EXISTS ${tessdata_DIR})
    MESSAGE(FATAL_ERROR "Folder specified by tessdata_DIR does not exist.")
  ENDIF()

  SET(PLUS_tessdata_src_DIR ${tessdata_DIR} CACHE INTERNAL "Path to store tesseract language data contents.")
ELSE()
  SET (PLUS_tessdata_src_DIR ${tesseract_ROOT_DIR}/tessdata CACHE INTERNAL "Path to store tesseract language data contents.")
  SET (PLUS_tessdata_prefix_DIR ${tesseract_ROOT_DIR}/tessdata-prefix CACHE INTERNAL "Path to store tesseract language prefix data.")
  ExternalProject_Add( tessdata
    "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
    PREFIX ${PLUS_tessdata_prefix_DIR}
    SOURCE_DIR "${PLUS_tessdata_src_DIR}"
    BINARY_DIR "${PLUS_tessdata_src_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${tessdata_GIT_REPOSITORY}
    GIT_TAG ${tessdata_GIT_TAG}
    #--Configure step-------------
    CONFIGURE_COMMAND ""
    #--Build step-----------------
    BUILD_COMMAND ""
    #--Install step-----------------
    #--Dependencies-----------------
    INSTALL_COMMAND ""
    DEPENDS ""
    )
  SET(tesseract_DEPENDENCIES ${tesseract_DEPENDENCIES} tessdata)
ENDIF()

# --------------------------------------------------------------------------
# tesseract
IF(tesseract_DIR)
  FIND_PACKAGE(tesseract REQUIRED NO_MODULE)

  SET (PLUS_tesseract_DIR ${tesseract_DIR} CACHE INTERNAL "Path to store tesseract binaries")
ELSE()
  SetGitRepositoryTag(
    tesseract
    "${GIT_PROTOCOL}://github.com/PlusToolkit/tesseract-ocr-cmake.git"
    "21855d0568a9253dede4e223aae71c0249b90438"
    )

  SET (PLUS_tesseract_src_DIR ${tesseract_ROOT_DIR}/tesseract CACHE INTERNAL "Path to store tesseract contents.")
  SET (PLUS_tesseract_prefix_DIR ${tesseract_ROOT_DIR}/tesseract-prefix CACHE INTERNAL "Path to store tesseract prefix data.")
  SET (PLUS_tesseract_DIR "${tesseract_ROOT_DIR}/tesseract-bin" CACHE INTERNAL "Path to store tesseract binaries")
  ExternalProject_Add( tesseract
    PREFIX ${PLUS_tesseract_prefix_DIR}
    "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
    SOURCE_DIR "${PLUS_tesseract_src_DIR}"
    BINARY_DIR "${PLUS_tesseract_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${tesseract_GIT_REPOSITORY}
    GIT_TAG ${tesseract_GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS
      ${ep_common_args}
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DCMAKE_PREFIX_PATH:STRING=${CMAKE_PREFIX_PATH}
      -DCMAKE_INSTALL_PREFIX:PATH=${PLUS_tesseract_DIR}
      -DLeptonica_DIR:PATH=${PLUS_leptonica_DIR}
      -Dtesseract_DATA_DIR:PATH=${PLUS_tessdata_src_DIR}
    #--Build step-----------------
    BUILD_ALWAYS 1
    #--Install step-----------------
    #--Dependencies-----------------
    DEPENDS ${tesseract_DEPENDENCIES}
  )
ENDIF()