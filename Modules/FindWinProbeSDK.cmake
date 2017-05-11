# WinProbeSDK_FOUND - WinProbe SDK has been found on this system
# WINPROBESDK_DIR - the path to header files etc

FIND_PATH(WINPROBESDK_DIR UltraVisionManagedDll.h
  DOC "WinProbeSDK directory (contains UltraVisionManagedDll.h)"
  PATHS "C:/WinProbeSDK"
  )

if (WINPROBESDK_DIR)
  set(WinProbeSDK_FOUND 1)
else()
  set(WinProbeSDK_FOUND 0)
endif()