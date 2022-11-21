# --------------------------------------------------------------------------
# PlusApp
SET(PLUSBUILD_ADDITIONAL_SDK_ARGS)

IF(BUILDNAME)
  SET(PLUSBUILD_ADDITIONAL_SDK_ARGS ${PLUSBUILD_ADDITIONAL_SDK_ARGS}
    -DBUILDNAME:STRING=${BUILDNAME}
  )
ENDIF()

IF(NOT DEFINED(PLUSAPP_GIT_REPOSITORY))
  SET(PLUSAPP_GIT_REPOSITORY "${GIT_PROTOCOL}://github.com/PlusToolkit/PlusApp.git" CACHE STRING "Set PlusApp desired git url")
ENDIF()
IF(NOT DEFINED(PLUSAPP_GIT_REVISION))
  SET(PLUSAPP_GIT_REVISION "master" CACHE STRING "Set PlusApp desired git hash (master means latest)")
ENDIF()

IF(PLUSBUILD_DOCUMENTATION)
  LIST(APPEND PLUSBUILD_ADDITIONAL_SDK_ARGS
    -DPLUSAPP_DOCUMENTATION_SEARCH_SERVER_INDEXED:BOOL=${PLUSBUILD_DOCUMENTATION_SEARCH_SERVER_INDEXED}
    -DPLUSAPP_DOCUMENTATION_GOOGLE_ANALYTICS_TRACKING_ID:STRING=${PLUSBUILD_DOCUMENTATION_GOOGLE_ANALYTICS_TRACKING_ID}
    -DDOXYGEN_DOT_EXECUTABLE:FILEPATH=${DOXYGEN_DOT_EXECUTABLE}
    -DDOXYGEN_EXECUTABLE:FILEPATH=${DOXYGEN_EXECUTABLE}
    )
ENDIF()

SET (PLUS_PLUSAPP_DIR ${CMAKE_BINARY_DIR}/PlusApp CACHE INTERNAL "Path to store PlusApp contents.")
SET (PLUSAPP_DIR ${CMAKE_BINARY_DIR}/PlusApp-bin CACHE PATH "The directory containing PlusApp binaries" FORCE)
ExternalProject_Add(PlusApp
  "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
  SOURCE_DIR "${PLUS_PLUSAPP_DIR}"
  BINARY_DIR "${PLUSAPP_DIR}"
  #--Download step--------------
  GIT_REPOSITORY ${PLUSAPP_GIT_REPOSITORY}
  GIT_TAG ${PLUSAPP_GIT_REVISION}
  #--Configure step-------------
  CMAKE_ARGS
    ${ep_common_args}
    ${ep_qt_args}
    -DGIT_EXECUTABLE:FILEPATH=${GIT_EXECUTABLE}
    -DGITCOMMAND:FILEPATH=${GITCOMMAND}
    -DCMAKE_MODULE_PATH:PATH=${CMAKE_MODULE_PATH}
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
    -DPlusLib_DIR:PATH=${PLUSLIB_DIR}
    -DBUILD_SHARED_LIBS:BOOL=${PLUSBUILD_BUILD_SHARED_LIBS}
    -DPLUSAPP_OFFLINE_BUILD:BOOL=${PLUSBUILD_OFFLINE_BUILD}
    -DPLUSAPP_BUILD_DiagnosticTools:BOOL=ON
    -DPLUSAPP_BUILD_fCal:BOOL=ON
    -DPLUSAPP_TEST_GUI:BOOL=${PLUSAPP_TEST_GUI}
    -DBUILD_DOCUMENTATION:BOOL=${PLUSBUILD_DOCUMENTATION}
    -DPLUSAPP_PACKAGE_EDITION:STRING=${PLUSAPP_PACKAGE_EDITION}
    -DPLUSBUILD_DOWNLOAD_PLUSLIBDATA:BOOL=${PLUSBUILD_DOWNLOAD_PLUSLIBDATA}
    -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
    -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
    -DVTK_BIN_DIR:PATH=${PLUS_VTK_BIN_DIR} #TODO: Remove when VTK_DIR packages correctly
    -DITK_BIN_DIR:PATH=${PLUS_ITK_BIN_DIR} #TODO: Remove when ITK_DIR packages correctly
    ${PLUSBUILD_ADDITIONAL_SDK_ARGS}
  #--Build step-----------------
  BUILD_ALWAYS 1
  #--Install step-----------------
  INSTALL_COMMAND ""
  DEPENDS ${PlusApp_DEPENDENCIES}
  )

# --------------------------------------------------------------------------
# If Qt build is shared, copy Qt binaries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
IF(TARGET Qt5::Core) # redundant, but check anyways
  GET_TARGET_PROPERTY(_qt_lib_type Qt5::Core TYPE)
  IF(_qt_lib_type STREQUAL "SHARED_LIBRARY")
    # Recursively build list of targets to copy
    LIST(LENGTH PLUSBUILD_QT_COMPONENTS _old_len)
    SET(_new_len 0)
    WHILE(NOT _old_len EQUAL _new_len)
      UNSET(_old_len)
      LIST(LENGTH _components _old_len)
      FOREACH(_component ${PLUSBUILD_QT_COMPONENTS})
        LIST(APPEND _components ${_component} ${_Qt5${_component}_MODULE_DEPENDENCIES})
      ENDFOREACH()
      LIST(REMOVE_DUPLICATES _components)
      UNSET(_new_len)
      LIST(LENGTH _components _new_len)
    ENDWHILE()

    FOREACH(_component ${_components})
      FIND_PACKAGE(Qt5 COMPONENTS ${_component})
      GET_TARGET_PROPERTY(_type Qt5::${_component} TYPE)
      IF(${_type} STREQUAL "INTERFACE_LIBRARY")
        CONTINUE()
      ENDIF()

      # Release files
      GET_TARGET_PROPERTY(_release_shared_lib Qt5::${_component} IMPORTED_LOCATION_RELEASE)
      IF(EXISTS ${_release_shared_lib})
        IF(MSVC)
          SET(_suffix "/Release")
          STRING(REPLACE ${CMAKE_SHARED_LIBRARY_SUFFIX} ".pdb" _release_pdb ${_release_shared_lib})
          IF(EXISTS ${_release_pdb})
            FILE(COPY ${_release_pdb}
              DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}${_suffix}
              )
          ENDIF()
        ENDIF()
        FILE(COPY ${_release_shared_lib}
          DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}${_suffix}
          )
      ENDIF()

      # Debug files
      GET_TARGET_PROPERTY(_debug_shared_lib Qt5::${_component} IMPORTED_LOCATION_DEBUG)
      IF(EXISTS ${_debug_shared_lib})
        IF(MSVC)
          SET(_suffix "/Debug")
          STRING(REPLACE ${CMAKE_SHARED_LIBRARY_SUFFIX} ".pdb" _debug_pdb ${_debug_shared_lib})
          IF(EXISTS ${_debug_pdb})
            FILE(COPY ${_debug_pdb}
              DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}${_suffix}
              )
          ENDIF()
        ENDIF()
        FILE(COPY ${_debug_shared_lib}
          DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}${_suffix}
          )
      ENDIF()
    ENDFOREACH()
  ENDIF()
ENDIF()

IF(MSVC)
  GET_FILENAME_COMPONENT(QT_BINARY_DIR ${QT_MOC_EXECUTABLE} DIRECTORY)
  FILE(COPY "${QT_BINARY_DIR}/"
    DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Debug
    FILES_MATCHING REGEX ${PDB_REGEX_PATTERN}
    )
ENDIF()
