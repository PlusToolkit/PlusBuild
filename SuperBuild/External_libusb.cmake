SET(LibUSB_WinURL "https://sourceforge.net/projects/libusb/files/libusb-1.0/libusb-1.0.22/libusb-1.0.22.7z/download")

# Download libusb if windows
# In Linux install with sudo apt-get install libusb-1.0-0-dev
IF (${CMAKE_SYSTEM_NAME} STREQUAL "Windows")

  SET(DEPS_DIR        ${CMAKE_BINARY_DIR}/Deps)
  SET(LibUSB_SRC      ${DEPS_DIR}/libusb)
  SET(LibUSB_STAMP    ${DEPS_DIR}/libusb-stamp)
  SET(LibUSB_PREFIX   ${DEPS_DIR}/libusb-prefix)
  SET(LibUSB_ROOT_DIR ${LibUSB_SRC})

  # PATHS WHERE WE KNOW THE HEADERS WILL BE LOCATED
  SET(LibUSB_INCLUDE_DIRS ${LibUSB_SRC}/include)
  SET(LibUSB_INCLUDES     ${LibUSB_SRC}/include)
  SET(LIBUSB_INCLUDE_DIR  ${LibUSB_SRC}/include)

  # PATH WHERE WE KNOW THE LIBRARY WILL BE LOCATED
  IF(MSVC OR ${CMAKE_GENERATOR} MATCHES "Xcode")
    SET(LibUSB_LIBRARY_DIR  ${LibUSB_SRC}/MS32/dll)
  ELSE ()
    SET(LibUSB_LIBRARY_DIR  ${LibUSB_SRC}/MinGW32/dll)
  ENDIF ()
  SET(LIBUSB_LIBRARY ${LibUSB_LIBRARY_DIR}/libusb-1.0.lib)

  # DOWNLOAD LIBUSB
  INCLUDE(ExternalProject)
  ExternalProject_Add(LibUSB
    PREFIX     ${LibUSB_PREFIX}
    SOURCE_DIR ${LibUSB_SRC}
    BINARY_DIR ${LibUSB_SRC} # No build step
    STAMP_DIR  ${LibUSB_STAMP}
    #--Download step--------------
    DOWNLOAD_NAME libusb.7z
    DOWNLOAD_DIR  ${LibUSB_SRC}
    URL           ${LibUSB_WinURL}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    )

ELSE ()

  # LIBUSB LOCATION IF INSTALLED IN LINUX
  # Copied from original repository https://github.com/maartenvds/libseek-thermal
  SET(LibUSB_INCLUDE_DIRS /usr/include/LibUSB-1.0)
  SET(LibUSB_INCLUDES     /usr/include/LibUSB-1.0)
  SET(LIBUSB_INCLUDE_DIR  /usr/include/LibUSB-1.0)
  SET(LibUSB_LIBS    -lusb-1.0)
  SET(LIBUSB_LIBRARY -lusb-1.0)

ENDIF ()
