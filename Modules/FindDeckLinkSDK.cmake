###############################################################################
# Find BlackMagic DeckLink SDK
#
#     find_package(DeckLinkSDK)
#
# Variables defined by this module:
#
#  DECKLINK_SDK_FOUND                True if BlackMagic DeckLink SDK was found
#  DECKLINK_SDK_VERSION              The version of the DeckLink SDK
#  DECKLINK_SDK_INCLUDE_DIR          The location(s) of DeckLink SDK headers

SET(DECKLINK_SDK_PATH_HINTS
  "../PLTools/BlackMagic/DeckLink"
  "../../PLTools/BlackMagic/DeckLink"
  "../trunk/PLTools/BlackMagic/DeckLink"
  "${CMAKE_CURRENT_BINARY_DIR}/PLTools/BlackMagic/DeckLink"
  )

FIND_PATH(DECKLINK_SDK_DIR Win/include/DeckLinkAPIVersion.h
  PATHS ${DECKLINK_SDK_PATH_HINTS}
  DOC "BlackMagic DeckLink SDK directory")

IF (DECKLINK_SDK_DIR)
  # Include directories
  IF (WIN32)
    set(DECKLINK_SDK_INCLUDE_DIR ${DECKLINK_SDK_DIR}/Win/include)
  ELSEIF (MAC)
    set(DECKLINK_SDK_INCLUDE_DIR ${DECKLINK_SDK_DIR}/Mac/include)
  ELSEIF(UNIX AND NOT MAC)
    set(DECKLINK_SDK_INCLUDE_DIR ${DECKLINK_SDK_DIR}/Linux/include)
  ENDIF()

  MARK_AS_ADVANCED(DECKLINK_SDK_INCLUDE_DIR)

  #Version
  #TODO: properly set SDK version using REGEX from NatNetTypes.h
  FILE(STRINGS ${DECKLINK_SDK_INCLUDE_DIR}/DeckLinkAPIVersion.h _VERSION_STR REGEX "BLACKMAGIC_DECKLINK_API_VERSION_STRING")
  STRING(REGEX MATCHALL "[0-9]+" _VERSION ${_VERSION_STR})
  set(DECKLINK_SDK_VERSION ${_VERSION})

endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(DECKLINK_SDK
  FOUND_VAR DECKLINK_SDK_FOUND
  REQUIRED_VARS DECKLINK_SDK_INCLUDE_DIR
  VERSION_VAR DECKLINK_SDK_VERSION
)