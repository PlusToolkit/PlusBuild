CMAKE_MINIMUM_REQUIRED(VERSION 3.16.0)

PROJECT(PlusBuild)

# Configure the build to work (although with limited functionalities) if only
# src directory of the repository is available

#-----------------------------------------------------------------------------
# Setting C++ Standard
#-----------------------------------------------------------------------------
set(_msg "Setting C++ standard")
message(STATUS "${_msg}")
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 11)
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
message(STATUS "${_msg} - C++${CMAKE_CXX_STANDARD}")

IF (PLUS_USE_CLARIUS_OEM)
  # ClariusOEM device uses C++/WinRT interface for managing Bluetooth LE connection to the probe, this requires C++ 17
  SET(_minimum_cxx_standard "17")
  IF("${CMAKE_CXX_STANDARD}" LESS "${_minimum_cxx_standard}")
    MESSAGE("The C++17 standard is required for the Clarius OEM device, updating CMAKE_CXX_STANDARD to 17")
    SET(CMAKE_CXX_STANDARD "${_minimum_cxx_standard}" CACHE STRING "C++ standard" FORCE)
  ENDIF()
ENDIF()

IF(COMMAND cmake_policy)
  cmake_policy(SET CMP0003 NEW)
  cmake_policy(SET CMP0097 NEW) # Empty string in git submodules means no submodules, cmake 3.16+
ENDIF(COMMAND cmake_policy)

SET(CMAKE_MODULE_PATH
  ${CMAKE_CURRENT_SOURCE_DIR}/Modules
  ${CMAKE_MODULE_PATH}
  )

SET(PLUSBUILD_DEFAULT_INSTALL_OPTION OFF)
IF(MSVC)
  SET(PLUSBUILD_DEFAULT_INSTALL_OPTION ON)
ENDIF()
OPTION(PLUSBUILD_INSTALL_VTK "" ${PLUSBUILD_DEFAULT_INSTALL_OPTION})
OPTION(PLUSBUILD_INSTALL_ITK "" ${PLUSBUILD_DEFAULT_INSTALL_OPTION})

# Include our build macros
INCLUDE(${CMAKE_CURRENT_SOURCE_DIR}/CMake/PlusBuildMacros.cmake)

OPTION(PLUSBUILD_OFFLINE_BUILD "Build Plus without an internet connection. All libraries must be downloaded and updated manually." OFF)
MARK_AS_ADVANCED(PLUSBUILD_OFFLINE_BUILD)

# Macro to set the Git repository and tag, and display a message
MACRO(SetGitRepositoryTag project_name git_repository git_tag)
  SET(${project_name}_GIT_REPOSITORY ${git_repository})
  SET(${project_name}_GIT_TAG ${git_tag})
  MESSAGE(STATUS "${project_name} repository: ${git_repository} (${git_tag})")
ENDMACRO(SetGitRepositoryTag)

IF (PLUSBUILD_OFFLINE_BUILD)
  # Set an empty download and update command for external projects
  SET(PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS DOWNLOAD_COMMAND "" UPDATE_COMMAND "")
ELSE()
  # Don't change the default download command
  # This argument will be used for ExternalProject_Add macro, which does its
  # very strict parsing, which throws a warning if an empty argument is passed.
  # Therefore, we need to pass a harmless parameter to prevent warnings
  # (TIMEOUT parameter is chosen, as no download operation should be performed
  # for offline builds, therefore the timeout parameter is not used anyway).
  SET(PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS TIMEOUT 1000)

  #-----------------------------------------------------------------------------
  # GIT - Let's check if a valid version of GIT is available
  #-----------------------------------------------------------------------------
  OPTION(PLUSBUILD_USE_GIT_PROTOCOL "If behind a firewall turn this off to use https instead." OFF)

  SET(GIT_PROTOCOL "git")
  IF(NOT PLUSBUILD_USE_GIT_PROTOCOL)
    SET(GIT_PROTOCOL "https")
  ENDIF()

  FIND_FILE(GIT_EXECUTABLE git${CMAKE_EXECUTABLE_SUFFIX}
    PATHS
      "c:/Program Files/Git/bin/"
      "c:/Program Files (x86)/Git/bin/"
    )
  FIND_PACKAGE(Git)

  IF(NOT GIT_FOUND)
    MESSAGE(FATAL_ERROR "Install Git and re-configure.")
  ENDIF()
ENDIF()

# --------------------------------------------------------------------------
# Developer setup
#
IF(Git_FOUND)
  GET_FILENAME_COMPONENT(_git_directory ${GIT_EXECUTABLE} DIRECTORY)
ENDIF()
SET(_x86env "ProgramFiles(x86)")
FIND_PROGRAM(BASH_EXECUTABLE bash
  HINTS
    ${_git_directory}
    $ENV{ProgramFiles}/Git/bin
    $ENV{${_x86env}}/Git/bin
  )
MARK_AS_ADVANCED(BASH_EXECUTABLE)
IF(BASH_EXECUTABLE AND Git_FOUND)
  IF(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/.git)
    EXECUTE_PROCESS(COMMAND "${BASH_EXECUTABLE}" -c "cd ${CMAKE_SOURCE_DIR} && ${CMAKE_SOURCE_DIR}/Utilities/SetupForDevelopment.sh copyOnly"
      OUTPUT_VARIABLE _bashOutput
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}}
    )
  ENDIF()
ENDIF()

#-----------------------------------------------------------------------------
# Options to control build process
#-----------------------------------------------------------------------------

SET(BUILD_ARCHITECTURE "x64")
IF(CMAKE_SIZEOF_VOID_P EQUAL 4)
  SET(BUILD_ARCHITECTURE "x86")
ENDIF()

# Determine the operating system to set default values accordingly
SET(ENABLED_BY_DEFAULT_ON_WINDOWS_ONLY OFF)
SET(ENABLED_BY_DEFAULT_ON_WINDOWS32_ONLY OFF)
SET(ENABLED_BY_DEFAULT_ON_WINDOWS64_ONLY OFF)
IF(CMAKE_HOST_WIN32)
  SET(ENABLED_BY_DEFAULT_ON_WINDOWS_ONLY ON)
  IF(BUILD_ARCHITECTURE MATCHES "x86")
    SET(ENABLED_BY_DEFAULT_ON_WINDOWS32_ONLY ON)
  ELSE()
    SET(ENABLED_BY_DEFAULT_ON_WINDOWS64_ONLY ON)
  ENDIF()
ENDIF()

OPTION(PLUSBUILD_USE_3DSlicer "Instead of building ITK, VTK, OpenIGTLink, etc., get them from a 3D Slicer build tree." OFF)
MARK_AS_ADVANCED(PLUSBUILD_USE_3DSlicer)
OPTION(PLUSBUILD_USE_OpenIGTLink "Use OpenIGTLink" ON)
OPTION(PLUSBUILD_BUILD_SHARED_LIBS "Build shared libraries instead of statically-linked libraries" ON)
OPTION(PLUSBUILD_BUILD_PLUSAPP "Build PlusApp applications" ON)
OPTION(PLUSBUILD_BUILD_PLUSLIB_WIDGETS "Build PlusLib widgets (required Qt)" ON)
OPTION(PLUSBUILD_BUILD_PlusLib_TOOLS "Build the PlusLib tools (PlusServer, PlusServerRemoteControl...)" ON)
OPTION(PLUSBUILD_BUILD_PLUSMODELCATALOG "Build Plus 3D printable model catalog" OFF)
OPTION(PLUSBUILD_USE_Tesseract "Use OCR in PlusLib for recognizing ultrasound imaging parameters by reading text from grabbed images." OFF)
OPTION(PLUSBUILD_USE_OpenCV "Use OpenCV for optical marker tracking and other features." OFF)
OPTION(PLUSBUILD_USE_aruco "Use aruco for optical marker tracking." OFF)
OPTION(PLUSBUILD_DOWNLOAD_PLUSLIBDATA "Download sample and test data. Required for automatic tests." ON)

# Documentation
OPTION(PLUSBUILD_DOCUMENTATION "Build Plus documentation (Doxygen)." OFF)
IF(PLUSBUILD_DOCUMENTATION)
  # Try to detect GraphViz path (CMake's Doxygen package finder only tries some obsolete paths on Windows)
  # Parentheses is not permitted due to CMP0053
  SET(PROGRAMFILESX86 "ProgramFiles(x86)")
  FIND_PROGRAM(DOXYGEN_DOT_EXECUTABLE
    NAMES dot
    PATHS
      "$ENV{ProgramFiles}/Graphviz2.38/bin"
      "$ENV{${PROGRAMFILESX86}}/Graphviz2.38/bin"
      "$ENV{ProgramFiles}/Graphviz2.34/bin"
      "$ENV{${PROGRAMFILESX86}}/Graphviz2.34/bin"
    DOC "Graphviz Dot tool for using Doxygen"
    NO_SYSTEM_ENVIRONMENT_PATH
  )
  FIND_PACKAGE(Doxygen REQUIRED)

  IF(NOT DOXYGEN_FOUND)
    MESSAGE(FATAL_ERROR "Documentation: Doxygen not found. Either specify location of doxygen or disable PLUSBUILD_DOCUMENTATION.")
  ENDIF()
  IF(NOT DOXYGEN_DOT_FOUND)
    MESSAGE(FATAL_ERROR "Documentation: Graphviz dot tool not found (http://www.graphviz.org/Download.php, required by Doxygen for diagram generation). Either specify location of dot or disable PLUSBUILD_DOCUMENTATION.")
  ENDIF()

  OPTION(PLUSBUILD_DOCUMENTATION_SEARCH_SERVER_INDEXED "Search index for documentation is generated by the web server. Provides full-text search but only works on web servers." OFF)
  MARK_AS_ADVANCED(PLUSBUILD_DOCUMENTATION_SEARCH_SERVER_INDEXED)

  SET(PLUSBUILD_DOCUMENTATION_GOOGLE_ANALYTICS_TRACKING_ID "" CACHE STRING "Tracking ID used for reporting documentation usage to Google Analytics. Only usable on web servers. If left empty, Google Analytics will not be included in the documentation HTML.")
  MARK_AS_ADVANCED(PLUSBUILD_DOCUMENTATION_GOOGLE_ANALYTICS_TRACKING_ID)
ENDIF()

OPTION(PLUSBUILD_PLUSLIB_DOCUMENTATION "Clone the PlusDoc submodule in PlusLib" ON)

# Determine current OS
IF("$ENV{PROCESSOR_ARCHITEW6432}" STREQUAL "")
  IF("$ENV{PROCESSOR_ARCHITECTURE}" STREQUAL "x86")
    SET(TEMP_OS_ARCH "x86")
  ELSE()
    SET(TEMP_OS_ARCH "x64")
  ENDIF()
ELSE()
  SET(TEMP_OS_ARCH "x64")
ENDIF()

# ---------- Imaging Hardware ------------
OPTION(PLUS_USE_ULTRASONIX_VIDEO "Provide support for the Ultrasonix ultrasound systems" OFF)
IF(PLUS_USE_ULTRASONIX_VIDEO)
  SET(PLUS_ULTRASONIX_SDK_MAJOR_VERSION 5 CACHE STRING "Set Ultrasonix SDK major version (version: [major].[minor].[patch])")
  SET(PLUS_ULTRASONIX_SDK_MINOR_VERSION 7 CACHE STRING "Set Ultrasonix SDK minor version (version: [major].[minor].[patch])")
  SET(PLUS_ULTRASONIX_SDK_PATCH_VERSION 4 CACHE STRING "Set Ultrasonix SDK patch version (version: [major].[minor].[patch])")
  OPTION(PLUS_TEST_ULTRASONIX "Enable testing of acquisition from Ultrasonix ultrasound systems. Enable this only if an Ultrasonix device accessible from this computer. " OFF)
  IF(PLUS_TEST_ULTRASONIX)
    SET(PLUS_TEST_ULTRASONIX_IP_ADDRESS "130.15.7.24" CACHE STRING "IP address of the Ultrasonix scanner that is used during testing")
  ENDIF()
ENDIF()

OPTION(PLUS_USE_BKPROFOCUS_VIDEO "Provide support for BK ProFocus ultrasound systems through the OEM (TCP/IP) interface" OFF)
IF(PLUS_USE_BKPROFOCUS_VIDEO)
  OPTION(PLUS_USE_BKPROFOCUS_CAMERALINK "Enable acquisition from BK ProFocus ultrasound systems through CameraLink interface" OFF)
  OPTION(PLUS_TEST_BKPROFOCUS "Enable testing of acquisition from BK ProFocus ultrasound systems. Enable this only if a BK ProFocus device is connected to this computer. " OFF)
ENDIF()
IF((NOT BUILD_ARCHITECTURE MATCHES "x64") AND TEMP_OS_ARCH MATCHES "x64" AND PLUS_USE_BKPROFOCUS_CAMERALINK)
  # warning regarding cross compilation of bkprofocus
  MESSAGE("BK ProFocus support on a 64-bit OS requires 64-bit Plus build. A 64-bit OS and a 32-bit Plus build configuration is detected. Compilation will be successful, but the resulting executables will fail to start.")
ENDIF()
IF(PLUS_USE_BKPROFOCUS_CAMERALINK AND (NOT PLUS_USE_BKPROFOCUS_VIDEO))
  MESSAGE(FATAL_ERROR "error: PLUS_USE_BKPROFOCUS_VIDEO must be enabled if the PLUS_USE_BKPROFOCUS_CAMERALINK option is enabled")
ENDIF()

OPTION(PLUS_USE_ICCAPTURING_VIDEO "Provide support for the IC framegrabber device" OFF)
OPTION(PLUS_USE_VFW_VIDEO "Provide support for the Video-for-Windows video digitizer (legacy, use Microsoft Media Foundation instead)" OFF)
OPTION(PLUS_USE_MMF_VIDEO "Provide support for the Microsoft Media Foundation video digitizers (requires installation of Windows Platform SDK 7.1 or later)" OFF)
IF(PLUS_USE_MMF_VIDEO)
  OPTION(PLUS_TEST_MMF_VIDEO "Enable testing of acquisition from MMF video device (webcam). Enable this only if an MMF device is connected to this computer." OFF)
ENDIF()
OPTION(PLUS_USE_EPIPHAN "Provide support for the Epiphan framegrabber device" OFF)
OPTION(PLUS_USE_CAPISTRANO_VIDEO "Provide support for the Capistrano Labs USB ultrasound probes" OFF)
OPTION(PLUS_USE_WINPROBE_VIDEO "Provide support WinProbe ultrasound systems" OFF)
OPTION(PLUS_USE_INTERSON_VIDEO "Provide support for the Interson USB ultrasound probes" OFF)
OPTION(PLUS_USE_INTERSONSDKCXX_VIDEO "Provide support for the Interson SDK 1.X with C++ Wrapper USB ultrasound probes" OFF)
OPTION(PLUS_USE_INTERSONARRAYSDKCXX_VIDEO "Provide support for the Interson Array SDK with C++ Wrapper USB ultrasound probes" OFF)
OPTION(PLUS_USE_TELEMED_VIDEO "Provide support for the Telemed ultrasound probes" OFF)
OPTION(PLUS_USE_AGILENT "Provide support for the Agilent digitizer device" OFF)
IF(PLUS_USE_TELEMED_VIDEO)
  OPTION(PLUS_TEST_TELEMED "Enable testing of acquisition from Telemed ultrasound systems. Enable this only if a Telemed device is connected to this computer. " OFF)
ENDIF()
OPTION(PLUS_USE_THORLABS_VIDEO "Provide support for the ThorLabs Compact Spectrometers" OFF)
OPTION(PLUS_USE_OpenCV_VIDEO "Provide support for capturing an OpenCV capture stream" OFF)
OPTION(PLUS_USE_INFRARED_SEEK_CAM "Provide support for capturing an Infrared Seek Camera capture stream" OFF)
OPTION(PLUS_USE_INFRARED_TEQ1_CAM "Provide support for capturing an Infrared Therma Expert Q1 Camera capture stream" OFF)
OPTION(PLUS_USE_PHILIPS_3D_ULTRASOUND "Provide support for the Philips ie33 3D ultrasound probe" OFF)
IF(PLUS_USE_PHILIPS_3D_ULTRASOUND)
  OPTION(PLUS_TEST_PHILIPS_3D_ULTRASOUND "Enable testing of acquisition from Philips 3D ultrasound systems. Enable this only if a Philips device is accessible from this computer. " OFF)
  IF (PLUS_TEST_PHILIPS_3D_ULTRASOUND)
    SET (PLUS_TEST_PHILIPS_3D_ULTRASOUND_IP_ADDRESS "129.100.44.8" CACHE STRING "IP address of the Philips scanner that is used during testing")
  ENDIF()
ENDIF()
OPTION(PLUS_USE_CLARIUS "Provide support for Clarius Ultrasound devices via the Listen API" OFF)
OPTION(PLUS_USE_CLARIUS_OEM "Provide support for Clarius OEM SDK interface to Clarius Ultrasound devices." OFF)
OPTION(PLUS_USE_ANDOR_CAMERA "Provide support for the Andor cameras capture stream" OFF)

# ---------- Tracking Hardware ------------
OPTION(PLUS_USE_OPTITRACK "Provide support for the OptiTrack tracking system" OFF)
IF (PLUS_USE_OPTITRACK)
  IF(NOT BUILD_ARCHITECTURE MATCHES "x64")
    SET(MOTIVE_VERSION_DEFAULT "1.10.3")
  ELSE()
    SET(MOTIVE_VERSION_DEFAULT "2.2.0")
  ENDIF()
  SET(MOTIVE_VERSION ${MOTIVE_VERSION_DEFAULT} CACHE STRING "Choose the motive API version.")
  IF (TEMP_OS_ARCH MATCHES "x86" AND MOTIVE_VERSION VERSION_GREATER "2.1.0")
    MESSAGE(FATAL_ERROR "MOTIVE_VERSION cannot be greater than 2.1.0 for 32-bit builds")
  ENDIF()
  set_property(CACHE MOTIVE_VERSION PROPERTY STRINGS "1.10.3" "2.2.0")
ENDIF()

OPTION(PLUS_USE_OPTIMET_CONOPROBE "Provide support for the Optimet ConoProbe" OFF)

OPTION(PLUS_USE_NDI "Provide support for the NDI POLARIS and AURORA" OFF)
OPTION(PLUS_USE_NDI_CERTUS "Provide support for the NDI Certus" OFF)

OPTION(PLUS_USE_POLARIS "Provide support for the NDI POLARIS and AURORA" OFF)
MARK_AS_ADVANCED(PLUS_USE_POLARIS)
OPTION(PLUS_USE_CERTUS "Provide support for the NDI Certus" OFF)
MARK_AS_ADVANCED(PLUS_USE_CERTUS)
IF(PLUS_USE_POLARIS)
  MESSAGE("PLUS_USE_POLARIS has been deprecated. Changing to PLUS_USE_NDI instead.")
  SET(PLUS_USE_POLARIS OFF CACHE BOOL "Provide support for the NDI POLARIS and AURORA" FORCE)
  SET(PLUS_USE_NDI ON CACHE BOOL "Provide support for the NDI POLARIS and AURORA" FORCE)
ENDIF()
IF(PLUS_USE_CERTUS)
  MESSAGE("PLUS_USE_CERTUS has been deprecated. Changing to PLUS_USE_NDI_CERTUS instead.")
  SET(PLUS_USE_CERTUS OFF CACHE BOOL "Provide support for the NDI Certus" FORCE)
  SET(PLUS_USE_NDI_CERTUS ON CACHE BOOL "Provide support for the NDI Certus" FORCE)
ENDIF()

OPTION(PLUS_USE_MICRONTRACKER "Provide support for the Claron MicronTracker" OFF)
OPTION(PLUS_USE_INTELREALSENSE "Provide support for Intel RealSense cameras" OFF)
OPTION(PLUS_USE_ATRACSYS "Provide support for Atracsys optical trackers" OFF)
OPTION(PLUS_USE_SPINNAKER_VIDEO "Provide support for Point Grey Spinnaker API compatible imaging devices" OFF)
OPTION(PLUS_USE_OPTICAL_MARKER_TRACKER "Provide support of tracking of markers (2D barcodes) in image streams using ArUco and OpenCV." OFF)
OPTION(PLUS_USE_BRACHY_TRACKER "Provide support for the Brachy Steppers" ${ENABLED_BY_DEFAULT_ON_WINDOWS32_ONLY})
OPTION(PLUS_USE_USDIGITALENCODERS_TRACKER "Provide support for multiple USDigital encoders tracking device" ${ENABLED_BY_DEFAULT_ON_WINDOWS32_ONLY})
OPTION(PLUS_USE_Ascension3DG "Provide support for the Ascension 3DG Tracker" ${ENABLED_BY_DEFAULT_ON_WINDOWS32_ONLY})
OPTION(PLUS_USE_Ascension3DGm "Provide support for the Ascension MedSafe Tracker" OFF)
OPTION(PLUS_USE_PHIDGET_SPATIAL_TRACKER "Provide support for the Phidget Spatial accelerometer" OFF)
OPTION(PLUS_USE_3dConnexion_TRACKER "Provide support for the 3dConnexion 3d mouse" OFF)
OPTION(PLUS_USE_STEALTHLINK "Provide support for the Medtronick StealthLink Server" OFF)
OPTION(PLUS_USE_IntuitiveDaVinci "Provide support for the da Vinci Surgical System" OFF)
OPTION(PLUS_USE_OvrvisionPro "Provide support for the OvrvisionPro Stereo Camera" OFF)
IF(PLUS_USE_OvrvisionPro)
  OPTION(PLUS_TEST_OvrvisionPro "Enable testing of acquisition of stereo images from the OvrvisionPro" OFF)
ENDIF()
OPTION(PLUS_USE_OPENHAPTICS "Provide support of OpenHaptics devices" OFF)
OPTION(PLUS_USE_WITMOTIONTRACKER "Provide support for the WitMotion IMU Trackers" OFF)
OPTION(PLUS_USE_LEAPMOTION "Provide support for the LeapMotion hand tracker" OFF)
IF(PLUS_USE_LEAPMOTION)
  OPTION(PLUS_TEST_LEAPMOTION "Enable testing of LeapMotion device" OFF)
  FIND_PACKAGE(LeapSDK 4.0 REQUIRED
    PATHS
    ../VASSTTools/LeapMotion/LeapSDK/lib/cmake/LeapSDK # Convenience for members of the VASST lab
    )
ENDIF()
OPTION(PLUS_USE_BLACKMAGIC_DECKLINK "Provide support for BlackMagic DeckLink capture cards." OFF)
OPTION(PLUS_USE_STEAMVR "Provide support for SteamVR tracking system" OFF)
OPTION(PLUS_USE_PICOSCOPE "Provide support for PicoScope 2xxx series oscilloscopes" OFF)
OPTION(PLUS_USE_GENERIC_SENSOR_TRACKER "Provide support for generic sensor data collection" OFF)
OPTION(PLUS_USE_AZUREKINECT "Provide support for Azure Kinect cameras" OFF)
OPTION(PLUS_USE_REVOPOINT3DCAMERA "Provide support for Revopoint 3D cameras" OFF)

# ---------- Other devices ------------
OPTION(PLUS_USE_TextRecognizer "Enable the text recognizer virtual device" OFF)

OPTION(PLUS_USE_NVIDIA_DVP "Provide support for the NVidia Digital Video Pipeline" OFF)
IF(PLUS_USE_NVIDIA_DVP)
  FIND_PACKAGE(QuadroSDI REQUIRED)
  FIND_PACKAGE(OpenGL REQUIRED)
ENDIF()

IF(UNIX AND NOT APPLE)
  OPTION(PLUS_USE_V4L2 "Provide support for video4linux devices" OFF)
  IF(PLUS_USE_V4L2)
    FIND_PACKAGE(V4L2 REQUIRED)
  ENDIF()
ENDIF()

OPTION(PLUS_ENABLE_VIDEOSTREAMING "Provide support for streaming compressed video from Plus" OFF)
OPTION(PLUS_USE_VP9 "Compile OpenIGTLink with VP9 support for compressed video streaming" OFF)
IF (PLUS_USE_VP9)
  SET(PLUS_ENABLE_VIDEOSTREAMING ON CACHE BOOL "Provide support for streaming compressed video from Plus" FORCE)
ENDIF()

#-----------------------------------------------------------------------------
# Other
SET(PLUSBUILD_VTK_RENDERING_BACKEND "OpenGL2" CACHE STRING "Choose the rendering backend. OpenGL2 is only compatible with more recent graphics cards and does not work on embedded systems like Ultrasonix Windows XPe based systems.")
set_property(CACHE PLUSBUILD_VTK_RENDERING_BACKEND PROPERTY STRINGS "None" "OpenGL2")

OPTION(PLUSAPP_TEST_GUI "Enable GUI tests" ON)

OPTION(PLUS_TEST_HIGH_ACCURACY_TIMING "Enable testing of high-accuracy timing. High-accuracy timing may not be available on virtual machines and so testing may be turned off to avoid false alarams." ON)
MARK_AS_ADVANCED(PLUS_TEST_HIGH_ACCURACY_TIMING)

SET(PLUSAPP_PACKAGE_EDITION "" CACHE STRING "Specifies a name that refers to the combination of hardware devices the created install package supports. The name is added to the package filename.")

#-----------------------------------------------------------------------------
# Warnings for incompatible build options
#-----------------------------------------------------------------------------
if(MSVC)
  # See https://cmake.org/cmake/help/latest/variable/MSVC_VERSION.html
  # and https://en.wikipedia.org/wiki/Microsoft_Visual_Studio#Version_history
  # 1600      = VS 10.0 (v100 toolset) (Visual Studio 2010)
  # 1700      = VS 11.0 (v110 toolset) (Visual Studio 2012)
  # 1800      = VS 12.0 (v120 toolset) (Visual Studio 2013)
  # 1900      = VS 14.0 (v140 toolset) (Visual Studio 2015)
  # 1910-1919 = VS 15.0 (v141 toolset)
  # 1920-1929 = VS 16.0 (v142 toolset)
  # 1930-1939 = VS 17.0 (v143 toolset)
  if(PLUS_USE_STEALTHLINK)
    if(NOT MSVC_VERSION MATCHES "^(1800|1600)$")
      message(FATAL_ERROR "SteathLink compatibility requires Visual Studio 2013 or 2010.")
    endif()
  endif()
endif()

IF(PLUS_USE_Ascension3DG AND PLUS_USE_Ascension3DGm)
  MESSAGE(FATAL_ERROR "PLUS_USE_Ascension3DG and PLUS_USE_Ascension3DGm options cannot be enabled at the same time. See more details at https://www.assembla.com/spaces/plus/tickets/851")
ENDIF()

#-----------------------------------------------------------------------------
# Plus revision - Set Plus stable relase revision (master means latest)
#-----------------------------------------------------------------------------
SET(PLUSLIB_GIT_REPOSITORY "${GIT_PROTOCOL}://github.com/PlusToolkit/PlusLib.git" CACHE STRING "Set PlusLib desired git url")
MARK_AS_ADVANCED(PLUSLIB_GIT_REPOSITORY)
SET(PLUSLIB_GIT_REVISION "master" CACHE STRING "Set PlusLib desired git hash (master means latest)")
MARK_AS_ADVANCED(PLUSLIB_GIT_REVISION)

SET(PLUSAPP_GIT_REPOSITORY "${GIT_PROTOCOL}://github.com/PlusToolkit/PlusApp.git" CACHE STRING "Set PlusApp desired git url")
MARK_AS_ADVANCED(PLUSAPP_GIT_REPOSITORY)
SET(PLUSAPP_GIT_REVISION "master" CACHE STRING "Set PlusApp desired git hash (master means latest)")
MARK_AS_ADVANCED(PLUSAPP_GIT_REVISION)

IF(PLUSBUILD_DOWNLOAD_PLUSLIBDATA)
  SET(PLUSBUILD_PLUSLIBDATA_GIT_REPOSITORY "${GIT_PROTOCOL}://github.com/PlusToolkit/PlusLibData.git" CACHE STRING "Set PlusLibData desired git url.")
  MARK_AS_ADVANCED(PLUSBUILD_PLUSLIBDATA_GIT_REPOSITORY)
  SET(PLUSBUILD_PLUSLIBDATA_GIT_REVISION "master" CACHE STRING "Set PlusLibData desired git hash (master means latest).")
  MARK_AS_ADVANCED(PLUSBUILD_PLUSLIBDATA_GIT_REVISION)
ENDIF()

#-----------------------------------------------------------------------------
# Plus executable output path
#-----------------------------------------------------------------------------
IF(NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
  SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
ENDIF()

IF(NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
  SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
ENDIF()

IF(NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
  SET(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
ENDIF()

#-----------------------------------------------------------------------------
# Specify common external project properties
#-----------------------------------------------------------------------------
INCLUDE(${CMAKE_ROOT}/Modules/ExternalProject.cmake)

SET(ep_base "${CMAKE_BINARY_DIR}")
SET(ep_common_args -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD} -DCMAKE_CXX_STANDARD_REQUIRED:BOOL=${CMAKE_CXX_STANDARD_REQUIRED})

IF(UNIX AND CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
  SET(ADDITIONAL_CXX_FLAGS "-fPIC")
  SET(ADDITIONAL_C_FLAGS "-fPIC")
ENDIF()

IF(NOT MSVC)
  LIST(APPEND ep_common_args -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE})
ENDIF()

SET(ep_common_c_flags "${CMAKE_C_FLAGS_INIT} ${ADDITIONAL_C_FLAGS}")
SET(ep_common_cxx_flags "${CMAKE_CXX_FLAGS_INIT} ${ADDITIONAL_CXX_FLAGS}")

# Compute -G arg for configuring external projects with the same CMake generator:
IF(CMAKE_EXTRA_GENERATOR)
  SET(gen "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
ELSE()
  SET(gen "${CMAKE_GENERATOR}")
ENDIF()

#------------------------------------------------------------------------------
# Specify external projects
#------------------------------------------------------------------------------
IF(PLUSBUILD_USE_3DSlicer)
  SET(PLUSBUILD_SLICER_BIN_DIRECTORY "PLUSBUILD_SLICER_BIN_DIRECTORY-NOT-FOUND" CACHE PATH "Path to 3D Slicer binary directory")

  IF("${PLUSBUILD_SLICER_BIN_DIRECTORY}" STREQUAL "PLUSBUILD_SLICER_BIN_DIRECTORY-NOT-FOUND")
    MESSAGE(FATAL_ERROR "Cannot use 3D Slicer if PLUSBUILD_SLICER_BIN_DIRECTORY is not defined.")
  ENDIF()

  # The Slicer4 config file complains if these are set.
  UNSET (VTK_DIR CACHE)
  UNSET (ITK_DIR CACHE)

  # Try to find Slicer4
  FIND_PACKAGE(Slicer PATHS ${PLUSBUILD_SLICER_BIN_DIRECTORY} NO_DEFAULT_PATH QUIET)
  IF(Slicer_FOUND)
    SET(Slicer_SKIP_EXTENSION_NAME_CHECK TRUE)
    INCLUDE( ${Slicer_USE_FILE})
  ENDIF()

  IF(NOT Slicer_FOUND)
    MESSAGE(FATAL_ERROR "Unable to find Slicer at ${PLUSBUILD_SLICER_BIN_DIRECTORY} directory. Please verify configuration")
  ENDIF()
ENDIF()

#-----------------------------------------------------------------------------
# Qt - Let's check if a valid version of Qt is available
#-----------------------------------------------------------------------------
SET(ep_qt_args) # Arguments that will have to be passed to external projects that use Qt
SET(PLUSBUILD_QT_COMPONENTS Core Widgets Designer OpenGL Sql Test Xml XmlPatterns Concurrent Network Gui)
IF(PLUS_USE_OPTITRACK)
  LIST(APPEND PLUSBUILD_QT_COMPONENTS Multimedia)
ENDIF()

IF(PLUSBUILD_BUILD_PLUSAPP OR PLUSBUILD_BUILD_PLUSLIB_WIDGETS)
  FIND_PACKAGE(Qt5 COMPONENTS ${PLUSBUILD_QT_COMPONENTS} QUIET)

  IF(NOT Qt5_FOUND)
    MESSAGE(FATAL_ERROR "This project requires Qt5 for building PlusApp but Qt was not found. Please specify Qt5_DIR or turn off PLUSBUILD_BUILD_PLUSAPP/PLUSBUILD_BUILD_PLUSLIB_WIDGETS options.")
  ENDIF()

  # WebKitWidgets is deprecated in Qt 5.3 and removed in 5.6.0
  FIND_PACKAGE(Qt5 OPTIONAL_COMPONENTS WebKitWidgets QUIET)
  IF(Qt5WebKitWidgets_FOUND)
    LIST(APPEND PLUSBUILD_QT_COMPONENTS WebKitWidgets)
  ENDIF()

  SET(ep_qt_args -DQt5_DIR:PATH=${Qt5_DIR})
  FOREACH(component ${PLUSBUILD_QT_COMPONENTS})
    LIST(APPEND ep_qt_args -DQt5${Component}_DIR:PATH=${Qt5${Component}_DIR})
  ENDFOREACH()
ENDIF()

INCLUDE(SuperBuild/External_VTK.cmake)

SET(PLUS_ITK_VERSION 5 CACHE STRING "Set version of ITK to use.")
MARK_AS_ADVANCED(PLUS_ITK_VERSION)
set_property(CACHE PLUS_ITK_VERSION PROPERTY STRINGS "5" "4")
IF(PLUS_USE_STEALTHLINK AND PLUS_ITK_VERSION VERSION_GREATER "4")
  MESSAGE("The StealthLink device only supports up to Visual Studio 2013, therefore it must use ITK 4. Changing ITK version to 4.")
  SET(PLUS_ITK_VERSION 4 CACHE STRING "Set version of ITK to use." FORCE)
ELSEIF(PLUS_ITK_VERSION MATCHES "4")
  MESSAGE("Only the StealthLink device is still supported to use ITK 4. Changing ITK version to 5.")
  SET(PLUS_ITK_VERSION 5 CACHE STRING "Set version of ITK to use." FORCE)
ENDIF()
INCLUDE(SuperBuild/External_ITK.cmake)

IF(PLUSBUILD_USE_OpenIGTLink)
  SET(OpenIGTLink_DEPENDENCIES)
  INCLUDE(SuperBuild/External_OpenIGTLink.cmake)

  SET(OpenIGTLinkIO_DEPENDENCIES OpenIGTLink)
  IF(TARGET vtk)
    LIST(APPEND OpenIGTLinkIO_DEPENDENCIES vtk)
  ENDIF()
  INCLUDE(SuperBuild/External_OpenIGTLinkIO.cmake)
ENDIF()

IF(PLUS_USE_NDI)
  INCLUDE(SuperBuild/External_ndicapi.cmake)
ENDIF()

IF(PLUS_USE_BKPROFOCUS_CAMERALINK)
  INCLUDE(SuperBuild/External_GrabbieLib.cmake)
ENDIF()

OPTION(PLUS_USE_MKV_IO "Enable reading/writing MKV files using libwebm." OFF)
INCLUDE(SuperBuild/External_IGSIO.cmake)

#-- TextRecognizer dependency verification ----------------------------------------------
IF(PLUS_USE_TextRecognizer AND NOT PLUSBUILD_USE_Tesseract)
  MESSAGE("PLUS_USE_TextRecognizer requires PLUSBUILD_USE_Tesseract option enabled, enabling.")
  SET(PLUSBUILD_USE_Tesseract ON CACHE BOOL "Use OCR in PlusLib for recognizing ultrasound imaging parameters by reading text from grabbed images." FORCE)
ENDIF()

#-- OvrvisionPro/OPTICAL_TRACKER dependency verification ----------------------------------------------
IF(PLUS_USE_OvrvisionPro AND NOT PLUSBUILD_USE_OpenCV)
  MESSAGE("PLUS_USE_OvrvisionPro requires PLUSBUILD_USE_OpenCV option enabled, enabling.")
  SET(PLUSBUILD_USE_OpenCV ON CACHE BOOL "Use OpenCV for optical marker tracking and other features." FORCE)
ENDIF()
IF(PLUS_USE_OpenCV_VIDEO AND NOT PLUSBUILD_USE_OpenCV)
  MESSAGE("PLUS_USE_OpenCV_VIDEO requires PLUSBUILD_USE_OpenCV option enabled, enabling.")
  SET(PLUSBUILD_USE_OpenCV ON CACHE BOOL "Use OpenCV for optical marker tracking and other features." FORCE)
ENDIF()
IF(PLUS_USE_INFRARED_SEEK_CAM AND NOT PLUSBUILD_USE_OpenCV)
  MESSAGE("PLUS_USE_INFRARED_SEEK_CAM requires PLUSBUILD_USE_OpenCV option enabled, enabling.")
  SET(PLUSBUILD_USE_OpenCV ON CACHE BOOL "Use OpenCV for infrared Seek camera and other features." FORCE)
ENDIF()
IF(PLUS_USE_OPTICAL_MARKER_TRACKER)
  IF (NOT PLUSBUILD_USE_aruco)
    MESSAGE("PLUS_USE_OPTICAL_MARKER_TRACKER requires PLUSBUILD_USE_aruco option enabled, enabling.")
    SET(PLUSBUILD_USE_aruco ON CACHE BOOL "Use OpenCV for optical marker tracking and other features." FORCE)
  ENDIF()
  IF (NOT PLUSBUILD_USE_OpenCV)
    MESSAGE("PLUS_USE_OPTICAL_MARKER_TRACKER requires PLUSBUILD_USE_OpenCV option enabled, enabling.")
    SET(PLUSBUILD_USE_OpenCV ON CACHE BOOL "Use OpenCV for optical marker tracking and other features." FORCE)
  ENDIF()
ENDIF()
IF (PLUS_USE_CLARIUS)
    IF (NOT PLUSBUILD_USE_OpenCV)
    MESSAGE("PLUS_USE_CLARIUS (Listen API) requires PLUSBUILD_USE_OpenCV option enabled, enabling.")
    SET(PLUSBUILD_USE_OpenCV ON CACHE BOOL "Use OpenCV for Clarius device and other features." FORCE)
  ENDIF()
ENDIF()
#-- END OvrvisionPro/OPTICAL_TRACKER dependency verification ------------------------------------------

#-- ANDOR dependency on opencv -----
IF (PLUS_USE_ANDOR_CAMERA AND NOT PLUSBUILD_USE_OpenCV)
  MESSAGE("PLUSE_USE_ANDOR_CAMERA requires openCV option enabled, enabling.")
  SET(PLUSBUILD_USE_OpenCV ON CACHE BOOL "Use OpenCV for optical marker tracking and other features." FORCE)
ENDIF()
#--- END ANDOR dependency on opencv

# OpenCV dependency, MUST COME AFTER VTK external inclusion
IF(PLUSBUILD_USE_OpenCV)
  MESSAGE(STATUS "")
  MESSAGE(STATUS "------")
  INCLUDE(SuperBuild/External_OpenCV.cmake)
  MESSAGE(STATUS "If building OpenCV with GPU code enabled, consider setting PLUSBUILD_OpenCV_CUDA_GENERATION as it will significantly reduce build time.")
  MESSAGE(STATUS "------")
  MESSAGE(STATUS "")
ENDIF()

IF(PLUSBUILD_USE_Tesseract)
  INCLUDE(SuperBuild/External_Tesseract.cmake)
ENDIF()

# Infrared Thermal Seek camera
IF(PLUS_USE_INFRARED_SEEK_CAM)
  INCLUDE(SuperBuild/External_libusb.cmake)
  INCLUDE(SuperBuild/External_InfraredSeekCam.cmake)
ENDIF()

# ArUco dependency
IF(PLUSBUILD_USE_aruco)
  INCLUDE(SuperBuild/External_aruco.cmake)
ENDIF()

# OvrvisionPro dependency
IF(PLUS_USE_OvrvisionPro)
  FIND_PACKAGE(OpenGL REQUIRED)
  FIND_PACKAGE(OpenCL REQUIRED)
  INCLUDE(SuperBuild/External_OvrvisionPro.cmake)
ENDIF()

IF(PLUS_USE_OPTIMET_CONOPROBE)
  FIND_PACKAGE(OPTIMETSMART32SDK)
  IF(NOT OPTIMETSMART32SDK_FOUND)
    MESSAGE(FATAL_ERROR "This project requires the Optimet Smart 32 SDK for ConoProbe tracking. One of the components is missing. Please verify configuration or turn off PLUS_USE_OPTIMET_CONOPROBE.")
  ENDIF()
ENDIF()

IF(PLUS_USE_NDI_CERTUS)
  FIND_PACKAGE(NDIOAPI)
  IF(NOT NDIOAPI_FOUND)
    MESSAGE(FATAL_ERROR "This project requires NDI Oapi for CERTUS tracking. One of the components is missing. Please verify configuration or turn off PLUS_USE_CERTUS.")
  ENDIF()
ENDIF()

IF(PLUS_USE_ULTRASONIX_VIDEO)
  FIND_PACKAGE(ULTRASONIX_SDK)
  IF(NOT ULTRASONIX_SDK_FOUND)
    MESSAGE(FATAL_ERROR "This project requires Ultrasonix SDK ${ULTRASONIX_SDK_VERSION} for Ultrasonix video. One of the components is missing. Please verify configuration or turn off PLUS_USE_ULTRASONIX_VIDEO.")
  ENDIF()
ENDIF()

IF(PLUS_USE_MICRONTRACKER)
  FIND_PACKAGE(MicronTracker)
  IF(NOT MICRONTRACKER_FOUND)
    MESSAGE(FATAL_ERROR "This project requires Claron MicronTracker SDK for supporting the MicronTracker tracking device. One of the components is missing. Please verify configuration or turn off PLUS_USE_MICRONTRACKER.")
  ENDIF()
ENDIF()

IF(PLUS_USE_INTELREALSENSE)
  FIND_PACKAGE(RSSDK)
  IF(NOT RSSDK_FOUND)
    MESSAGE(FATAL_ERROR "This project requires the Intel RealSense SDK 2.0 for supporting the Intel RealSense device. One of the components is missing. Please verify configuration or turn off PLUS_USE_INTELREALSENSE.")
  ENDIF()
ENDIF()

IF(PLUS_USE_INFRARED_TEQ1_CAM)
  FIND_PACKAGE(TEQ1SDK)
  IF(NOT TEQ1SDK_FOUND)
    MESSAGE(FATAL_ERROR "This project requires Thermal Expert SDK for supporting the Q1 camera device. One of the components is missing. Please verify configuration or turn off PLUS_USE_INFRARED_TEQ1_CAM.")
  ENDIF()
ENDIF()

IF(PLUS_USE_ATRACSYS)
  SET(PLUS_USE_ATRACSYS_DEVICE_TYPE "SET_DEVICE_TYPE" CACHE STRING "Type of Atracsys device to build support for.")
  SET_PROPERTY(CACHE PLUS_USE_ATRACSYS_DEVICE_TYPE PROPERTY STRINGS stk ftk ftksim)
  SET(ATRACSYS_DEVICE_TYPE ${PLUS_USE_ATRACSYS_DEVICE_TYPE})
  IF(ATRACSYS_DEVICE_TYPE STREQUAL "SET_DEVICE_TYPE")
    MESSAGE(FATAL_ERROR "Please choose an Atracsys device type to build support for. Options are stk (spryTrack), ftk (fusionTrack), or ftksim (fusionTrack simulator).")
  ENDIF()
  FIND_PACKAGE(Atracsys)
  IF(NOT ATRACSYS_SDK_FOUND)
    MESSAGE(FATAL_ERROR "This project requires the Atracsys sTk Passive Tracking SDK to support the use of Atacsys optical trackers. One of the components is missing. Please verify configuration or turn off PLUS_USE_ATRACSYS")
  ENDIF()
ENDIF()

IF(PLUS_USE_SPINNAKER_VIDEO)
  FIND_PACKAGE(SpinnakerAPI)
  IF(NOT SPINNAKER_API_FOUND)
    MESSAGE(FATAL_ERROR "This project requires the Point Grey Spinnaker API to support the use of Point Grey imaging devices. One of the components is missing. Please verify configuration or turn off PLUS_USE_SPINNAKER_VIDEO")
  ENDIF()
ENDIF()

IF(PLUS_USE_PICOSCOPE)
  FIND_PACKAGE(PicoScopeSDK)
  IF(NOT PicoScopeSDK_FOUND)
    MESSAGE(FATAL_ERROR "This project requires the PicoScope SDK for supporting PicoScope oscilloscopes.")
  ENDIF()
ENDIF()

IF(PLUS_USE_ICCAPTURING_VIDEO)
 FIND_PACKAGE(ICCAPTURING)
  IF(NOT ICCAPTURING_FOUND)
    MESSAGE(FATAL_ERROR "This project requires IC Capturing SDK for supporting the Imaging Source USB frame grabber. One of the components is missing. Please verify configuration or turn off PLUS_USE_ICCAPTURING_VIDEO.")
  ENDIF()
ENDIF()

IF(PLUS_USE_OPTITRACK)
  FIND_PACKAGE(MotiveAPI)
  IF(NOT MotiveAPI_FOUND)
    MESSAGE(FATAL_ERROR "This project requires OptiTrack Motive API for supporting OptiTrack devices.")
  ENDIF()
  FIND_PACKAGE(NatNetSDK)
  IF(NOT NatNetSDK_FOUND)
    MESSAGE(FATAL_ERROR "This project requires OptiTrack NatNetSDK for supporting OptiTrack devices.")
  ENDIF()
ENDIF()

IF(PLUS_USE_STEALTHLINK)
  FIND_PACKAGE(STEALTHLINK)
  IF(NOT STEALTHLINK_FOUND)
    MESSAGE(FATAL_ERROR "This project requires Stealthlink2 SDK for supporting communication with Medtronic StealthStation. Please verify configuration or turn off PLUS_USE_STEALTHLINK.")
  ENDIF()

  IF(UNIX AND NOT APPLE)
    MESSAGE(WARNING "StealthLink for linux API was built against the old cpp ABI. You must build Plus with -D_GLIBCXX_USE_CXX11_ABI=0 added to CXX_FLAGS.")
  ENDIF()
ENDIF()

IF(PLUS_USE_CAPISTRANO_VIDEO)
 FIND_PACKAGE(CAPISTRANO)
  IF(NOT CAPISTRANO_FOUND)
    MESSAGE(FATAL_ERROR "This project requires Capistrano Labs cSDK for supporting the Capistrano Labs USB ultrasound probes. One of the components is missing. Please verify configuration or turn off PLUS_USE_CAPISTRANO_VIDEO.")
  ENDIF()
ENDIF()

IF(PLUS_USE_WINPROBE_VIDEO)
 FIND_PACKAGE(WinProbeSDK)
  IF(NOT WinProbeSDK_FOUND)
    MESSAGE(FATAL_ERROR "This project requires WinProbeSDK for supporting WinProbe ultrasound systems. One of the components is missing. Please verify configuration or turn off PLUS_USE_WINPROBE_VIDEO.")
  ENDIF()
ENDIF()

IF(PLUS_USE_INTERSON_VIDEO)
 FIND_PACKAGE(INTERSON)
  IF(NOT INTERSON_FOUND)
    MESSAGE(FATAL_ERROR "This project requires Interson iSDK for supporting the Interson USB ultrasound probes. One of the components is missing. Please verify configuration or turn off PLUS_USE_INTERSON_VIDEO.")
  ENDIF()
ENDIF()

IF(PLUS_USE_IntuitiveDaVinci)
  FIND_PACKAGE(IntuitiveDaVinci)
  IF(NOT IntuitiveDaVinci_FOUND)
    MESSAGE(FATAL_ERROR "This project requires headers and library provided by Intuitive. One of the components is missing. Please verify configuration or turn off PLUS_USE_IntuitiveDaVinci.")
  ENDIF()
ENDIF()

IF(PLUS_USE_TELEMED_VIDEO)
  FIND_PACKAGE(Telemed)
  IF(NOT TELEMED_FOUND)
    MESSAGE(FATAL_ERROR "This project requires Telemed SDK for supporting the Telemed ultrasound probes. One of the components is missing. Please verify configuration or turn off PLUS_USE_TELEMED_VIDEO.")
  ENDIF()
ENDIF()

IF(PLUS_USE_THORLABS_VIDEO)
  FIND_PACKAGE(ThorLabs)
  IF(NOT THORLABS_FOUND)
    MESSAGE(FATAL_ERROR "This project requires ThorLabs CCS VISA  SDK for supporting the ThorLabs devices. One of the components is missing. Please verify configuration or turn off PLUS_USE_THORLABS_VIDEO.")
  ENDIF()
ENDIF()

IF(PLUS_USE_OPENHAPTICS)
  FIND_PACKAGE(OpenHaptics)
  IF(NOT OPENHAPTICS_FOUND)
    MESSAGE(FATAL_ERROR "This project requires the OpenHaptics  SDK for supporting the Geomagic Touch devices. One of the components is missing. Please verify configuration or turn off PLUS_USE_OPENHAPTICS.")
  ENDIF()
ENDIF()

IF(PLUS_USE_BLACKMAGIC_DECKLINK)
  FIND_PACKAGE(DeckLinkSDK)
  IF(NOT DeckLinkSDK_FOUND)
    MESSAGE(FATAL_ERROR "This project requires the BlackMagic DeckLink SDK to provide support for DeckLink capture cards. Please select the BlackMagic SDK directory, or turn off PLUS_USE_BLACKMAGIC_DECKLINK.")
  ENDIF()
ENDIF()

IF (PLUS_USE_PHILIPS_3D_ULTRASOUND)
  IF(NOT CMAKE_HOST_WIN32)
    # Philips is windows only
    MESSAGE(FATAL_ERROR "Philips SDK is only available for Windows.")
  ENDIF()

  IF(PLUS_USE_ULTRASONIX_VIDEO)
    # Ultrasonix contains its own libmmd.dll which does not support all the functionality needed for the philips probe
    # They both cannot be enabled at the same time.
    MESSAGE(FATAL_ERROR "Plus cannot enable both Ultrasonix and Philips devices due to .dll conflicts in their respective SDK packages.")
  ELSE()
    SET (PLUS_Philips_MAJOR_VERSION 1 CACHE STRING "Set Philips library major version (version: [major].[minor].[patch])")
    SET (PLUS_Philips_MINOR_VERSION 0 CACHE STRING "Set Philips library minor version (version: [major].[minor].[patch])")
    SET (PLUS_Philips_PATCH_VERSION 0 CACHE STRING "Set Philips library patch version (version: [major].[minor].[patch])")
    FIND_PACKAGE(Philips)
    IF(NOT PHILIPS_FOUND)
      MESSAGE(FATAL_ERROR "In order to use the Philips ie33 ultrasound system, the requisite DLLs must be made available. Please verify configuration or turn off PLUS_USE_PHILIPS_3D_ULTRASOUND.")
    ENDIF()
      MESSAGE(STATUS "To use the Philips devices you must:")
      MESSAGE(STATUS "1. Register '${CMAKE_CURRENT_BINARY_DIR}/bin/Debug|Release/Stream3d.dll'. If you are using a 32-bit OS, this can be done by running 'regsvr32 Stream3d.dll' in command line. If you are using a 64-bit OS, this can be done by the following procedure. Open the command line in administrator mode (Right click on cmd, choose 'Run as administrator'). Go to directory 'C:/Windows/SysWow64'. Run the regsvr32 command in SysWow64.")
  ENDIF()
ENDIF()

IF(PLUS_USE_CLARIUS)
  FIND_PACKAGE(CLARIUS)
  IF(NOT CLARIUS_FOUND)
    MESSAGE(FATAL_ERROR "This project requires Clarius Listen API for supporting Clarius Ultrasound scanner")
  ENDIF()
ENDIF()

IF(PLUS_USE_CLARIUS_OEM)
  # Check Win32, Clarius OEM is only supported on Windows
  IF(NOT WIN32)
    message(FATAL_ERROR "Clarius OEM device is only available on Windows. Please use Windows to compile PLUS, or set PLUS_USE_CLARIUS_OEM to OFF.")
  ENDIF()

  INCLUDE(Superbuild/External_ClariusOEM.cmake)
ENDIF()

IF(PLUS_USE_STEAMVR)
  INCLUDE(SuperBuild/External_OpenVR.cmake)
ENDIF()

IF(PLUS_USE_ANDOR_CAMERA)
 FIND_PACKAGE(ANDOR)
  IF(NOT ANDOR_FOUND)
    MESSAGE(FATAL_ERROR "This project requires ANDOR SDK for supporting the Andor Camera. One of the components is missing. Please verify configuration or turn off PLUS_USE_ANDOR_CAMERA.")
  ENDIF()
ENDIF()

IF(PLUS_USE_GENERIC_SENSOR_TRACKER)
  FIND_PACKAGE(WindowsSensorAPI)
  IF(NOT WindowsSensorAPI_FOUND)
    MESSAGE(FATAL_ERROR "This project requires the Windows Sensor API for supporting the generic sensor tracker. One of the components is missing. Please verify configuration or turn off PLUS_USE_GENERIC_SENSOR_TRACKER.")
  ENDIF()
ENDIF()

IF(PLUS_USE_AZUREKINECT)
 FIND_PACKAGE(K4A)
  IF(NOT K4A_FOUND)
    MESSAGE(FATAL_ERROR "This project requires Azure Kinect SDK (k4a) for supporting the Azure Kinect Camera. One of the components is missing. Please verify configuration or turn off PLUS_USE_AZUREKINECT.")
  ENDIF()
ENDIF()

IF(PLUS_USE_REVOPOINT3DCAMERA)
  FIND_PACKAGE(REVOPOINT3DSDK)
  IF(NOT REVOPOINT3DSDK_FOUND)
    MESSAGE(FATAL_ERROR "This project requires RevoPoint 3D SDK for supporting the Revopoint 3D cameras. One of the components is missing. Please verify configuration or turn off PLUS_USE_REVOPOINT3DCAMERA.")
  ENDIF()
ENDIF()

#------------------------------------------------------------------------------
# Specify target dependencies
#------------------------------------------------------------------------------
SET(PlusLib_DEPENDENCIES)

IF(NOT VTK_DIR)
  # VTK_DIR is not supplied, so it is built inside Plus, therefore we need to specify dependencies to make sure it is built early enough
  SET(VTK_DEPENDENCIES)
  LIST(APPEND PlusLib_DEPENDENCIES vtk)
ENDIF()

IF(NOT ITK_DIR)
  # ITK_DIR is not supplied, so it is built inside Plus, therefore we need to specify dependencies to make sure it is built early enough
  SET(ITK_DEPENDENCIES)
  LIST(APPEND PlusLib_DEPENDENCIES itk)
ENDIF()

IF (NOT IGSIO_DIR)
  SET(IGSIO_DEPENDENCIES)
  LIST(APPEND PlusLib_DEPENDENCIES IGSIO)
ENDIF()

IF(PLUSBUILD_USE_OpenIGTLink AND NOT OpenIGTLink_DIR)
  # OpenIGTLink_DIR is not supplied, so it is built inside Plus, therefore we need to specify dependencies to make sure it is built early enough
  LIST(APPEND PlusLib_DEPENDENCIES OpenIGTLink)
  LIST(APPEND PlusLib_DEPENDENCIES OpenIGTLinkIO)
ENDIF()

IF(PLUS_USE_BKPROFOCUS_CAMERALINK)
  SET(GrabbieLib_DEPENDENCIES)
  LIST(APPEND PlusLib_DEPENDENCIES GrabbieLib)
ENDIF()

IF(PLUS_USE_INTERSONSDKCXX_VIDEO AND NOT IntersonSDKCxx_DIR)
  SET(IntersonSDKCxx_DEPENDENCIES)
  LIST(APPEND PlusLib_DEPENDENCIES IntersonSDKCxx)
  INCLUDE(SuperBuild/External_IntersonSDKCxx.cmake)
ENDIF()

IF(PLUS_USE_INTERSONARRAYSDKCXX_VIDEO AND NOT IntersonArraySDKCxx_DIR)
  SET(IntersonArraySDKCxx_DEPENDENCIES)
  LIST(APPEND PlusLib_DEPENDENCIES IntersonArraySDKCxx)
  INCLUDE(SuperBuild/External_IntersonArraySDKCxx.cmake)
ENDIF()

IF(PLUS_USE_OvrvisionPro AND NOT OvrvisionPro_DIR)
  LIST(APPEND PlusLib_DEPENDENCIES OvrvisionPro)
ENDIF()

IF(PLUSBUILD_USE_aruco AND NOT aruco_DIR)
  LIST(APPEND PlusLib_DEPENDENCIES aruco)
ENDIF()

IF(PLUSBUILD_USE_Tesseract)
  LIST(APPEND PlusLib_DEPENDENCIES tesseract)
ENDIF()

IF(PLUSBUILD_USE_OpenCV AND NOT OpenCV_DIR)
  LIST(APPEND PlusLib_DEPENDENCIES OpenCV)
ENDIF()

IF(PLUS_USE_NDI AND NOT ndicapi_DIR)
  LIST(APPEND PlusLib_DEPENDENCIES ndicapi)
ENDIF()

IF(PLUS_USE_INFRARED_SEEK_CAM)
  LIST(APPEND PlusLib_DEPENDENCIES SeekCameraLib)
ENDIF()

IF(PLUS_USE_LEAPMOTION)
  LIST(APPEND PlusLib_DEPENDENCIES LeapSDK::LeapC)
ENDIF()

IF(PLUS_USE_STEAMVR AND NOT OpenVR_DIR)
  LIST(APPEND PlusLib_DEPENDENCIES OpenVR)
ENDIF()

SET(PlusApp_DEPENDENCIES PlusLib)
SET(PlusModelCatalog_DEPENDENCIES PlusLib)

#------------------------------------------------------------------------------
# Construct a descriptive build name
#------------------------------------------------------------------------------

IF(UNIX AND NOT APPLE)
  SET(LINUX TRUE)
ENDIF()

#Build a nice system and compiler name
IF(LINUX)
  # System name
  IF(EXISTS /etc/issue.net)
    EXECUTE_PROCESS(COMMAND cat /etc/issue.net OUTPUT_VARIABLE SYSTEM_NAME_FULL)
    STRING(REGEX REPLACE "[ \n\t\r]" "" SYSTEM_NAME ${SYSTEM_NAME_FULL})
  ELSEIF(EXISTS /etc/issue)
    EXECUTE_PROCESS(COMMAND cat /etc/issue OUTPUT_VARIABLE SYSTEM_NAME_FULL)
    STRING(REGEX REPLACE "[ \n\t\r]" "" SYSTEM_NAME ${SYSTEM_NAME_FULL})
  ELSEIF(EXISTS /etc/redhat-release)
    EXECUTE_PROCESS(COMMAND cat /etc/redhat-release OUTPUT_VARIABLE SYSTEM_NAME_FULL)
    STRING(REGEX REPLACE "[ \n\t\r]" "" SYSTEM_NAME ${SYSTEM_NAME_FULL})
  ELSE()
    SET(SYSTEM_NAME ${CMAKE_SYSTEM_NAME})
  ENDIF()
  STRING(TOLOWER ${SYSTEM_NAME} SYSTEM_NAME)

  # Compiler name
  EXECUTE_PROCESS(COMMAND ${CMAKE_C_COMPILER} -dumpversion OUTPUT_VARIABLE GCC_VERSION)
  STRING(REGEX REPLACE "[ \n\t\r]" "" GCC_VERSION ${GCC_VERSION})
  SET(COMPILER_NAME "gcc-${GCC_VERSION}")
ELSEIF(APPLE)
  EXECUTE_PROCESS(COMMAND sw_vers -productName OUTPUT_VARIABLE SYSTEM_NAME_FULL)
  STRING(REGEX REPLACE "[ \n\t\r]" "" SYSTEM_NAME ${SYSTEM_NAME_FULL})
  EXECUTE_PROCESS(COMMAND sw_vers -productVersion OUTPUT_VARIABLE SYSTEM_VERSION_FULL)
  STRING(REGEX REPLACE "[ \n\t\r]" "" SYSTEM_VERSION ${SYSTEM_VERSION_FULL})
  SET(SYSTEM_NAME "${SYSTEM_NAME}-${SYSTEM_VERSION}")
  EXECUTE_PROCESS(COMMAND clang --version OUTPUT_VARIABLE CLANG_VERSION)
  STRING(REGEX MATCH "Apple LLVM version ([0-9]+.[0-9]+.[0-9]+)" CLANG_VERSION ${CLANG_VERSION})
  SET(COMPILER_NAME "clang${CMAKE_MATCH_1}")
ELSEIF(MSVC)
  # Use generator to determine name
  IF(${CMAKE_GENERATOR} MATCHES "Visual Studio 9")
    SET(COMPILER_NAME vs9)
  ELSEIF(${CMAKE_GENERATOR} MATCHES "Visual Studio 10")
    SET(COMPILER_NAME vs10)
  ELSEIF(${CMAKE_GENERATOR} MATCHES "Visual Studio 11")
    SET(COMPILER_NAME vs11)
  ELSEIF(${CMAKE_GENERATOR} MATCHES "Visual Studio 12")
    SET(COMPILER_NAME vs12)
  ELSEIF(${CMAKE_GENERATOR} MATCHES "Visual Studio 14")
    SET(COMPILER_NAME vs14)
  ELSEIF(${CMAKE_GENERATOR} MATCHES "Visual Studio 15")
    SET(COMPILER_NAME vs15)
  ELSEIF(${CMAKE_GENERATOR} MATCHES "Visual Studio 16")
    SET(COMPILER_NAME vs16)
  ELSEIF(${CMAKE_GENERATOR} MATCHES "Visual Studio 17")
    SET(COMPILER_NAME vs17)
  ELSE()
    SET(COMPILER_NAME vs??)
  ENDIF()
ELSEIF(MINGW)
  # Compiler name
  EXECUTE_PROCESS(COMMAND ${CMAKE_C_COMPILER} -dumpversion OUTPUT_VARIABLE GCC_VERSION)
  STRING(REGEX REPLACE "[ \n\t\r]" "" GCC_VERSION ${GCC_VERSION})
  SET(COMPILER_NAME "mingwgcc-${GCC_VERSION}")
ENDIF()

IF(WIN32)
  SET(SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_VERSION}")
ENDIF()

SET(PLUSBUILD_BUILDNAME_POSTFIX "" CACHE STRING "Postfix that will be appended to the build name on the dashboard. If defined then BUILDNAME variable is always overwritten.")
MARK_AS_ADVANCED(PLUSBUILD_BUILDNAME_POSTFIX)
SET(GENERATED_BUILDNAME "${COMPILER_NAME}${BUILD_ARCHITECTURE}-${SYSTEM_NAME}")

IF ("${PLUSBUILD_BUILDNAME_POSTFIX}" STREQUAL "")
  SET(BUILDNAME "${GENERATED_BUILDNAME}" CACHE STRING "Name of the build on the dashboard" FORCE)
ELSE()
  SET(BUILDNAME "${GENERATED_BUILDNAME}-${PLUSBUILD_BUILDNAME_POSTFIX}" CACHE STRING "Name of the build on the dashboard. Value is generated automatically from build options and PLUSBUILD_BUILDNAME_POSTFIX." FORCE)
ENDIF()
MARK_AS_ADVANCED(BUILDNAME)

#------------------------------------------------------------------------------
# Set up project for PlusLib, PlusApp, and PlusModelCatalog
#------------------------------------------------------------------------------
INCLUDE(CTest)

IF(PLUSBUILD_DOWNLOAD_PLUSLIBDATA AND NOT PLUSBUILD_OFFLINE_BUILD)
  INCLUDE(SuperBuild/External_PlusLibData.cmake)
ENDIF()

INCLUDE(SuperBuild/External_PlusLib.cmake)

IF(PLUSBUILD_BUILD_PLUSAPP)
  INCLUDE(SuperBuild/External_PlusApp.cmake)
ENDIF()

IF(PLUSBUILD_BUILD_PLUSMODELCATALOG)
  INCLUDE(SuperBuild/External_PlusModelCatalog.cmake)
ENDIF()

#-----------------------------------------------------------------------------
# Generate convenience files for automatic update build and test
#-----------------------------------------------------------------------------
IF(WIN32)
  CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/BuildAndTest.bat.in
    ${CMAKE_CURRENT_BINARY_DIR}/BuildAndTest.bat
    )

  STRING(REPLACE "/" "\\" PLUSBUILD_BIN_DIR_WIN "${CMAKE_BINARY_DIR}")
  CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/PlusBuildAndTest.bat.in
    ${CMAKE_CURRENT_BINARY_DIR}/PlusBuildAndTest.bat
    )
ELSE()
  CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/BuildAndTest.sh.in
    ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_FILES_DIRECTORY}/BuildAndTest.sh
    @ONLY
    )
  CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/PlusBuildAndTest.sh.in
    ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_FILES_DIRECTORY}/PlusBuildAndTest.sh
    )

  # Copy the files so that we can set the permissions (execute bit)
  FILE(COPY ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_FILES_DIRECTORY}/PlusBuildAndTest.sh
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ WORLD_READ)
  FILE(COPY ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_FILES_DIRECTORY}/BuildAndTest.sh
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ WORLD_READ)
ENDIF()

#-----------------------------------------------------------------------------
# Display errors for options that are not compatible with VS2010
#-----------------------------------------------------------------------------
IF(${CMAKE_GENERATOR} MATCHES "Visual Studio 10")
  FOREACH(OPTION_NAME PLUSBUILD_USE_aruco PLUS_USE_USDIGITALENCODERS_TRACKER)
    IF (${OPTION_NAME})
      MESSAGE(FATAL_ERROR "Option ${OPTION_NAME} is not compatible with Visual Studio 2010. Disable ${OPTION_NAME} or use a more recent compiler.")
    ENDIF()
  ENDFOREACH()
ENDIF()
