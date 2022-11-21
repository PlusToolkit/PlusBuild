# Check the Windows sensor API lib is available on the system
#

IF(NOT WIN32)
  MESSAGE(FATAL_ERROR "The generic sensor API is available for Windows target only.")
ENDIF()

INCLUDE(CheckIncludeFile)
INCLUDE(CheckCXXSourceCompiles)

CHECK_INCLUDE_FILE(Sensorsapi.h HAS_SENSOR_API_HEADER)

IF (NOT HAS_SENSOR_API_HEADER)
  MESSAGE(FATAL_ERROR "Windows Sensor API not found on this platform: Sensorsapi.h not found")
ENDIF()

CHECK_CXX_SOURCE_COMPILES("
#pragma comment(lib, \"Sensorsapi\")
#pragma comment(lib, \"PortableDeviceGUIDs\")
#include <SensorsApi.h>
int main() {
  ISensorManager* sensorManager{nullptr};
  HRESULT hr = CoCreateInstance(CLSID_SensorManager, NULL, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&sensorManager));
  if(FAILED(hr)){
    return 1;
  }
  IPortableDeviceKeyCollection* pKeys = NULL;
  hr = CoCreateInstance(CLSID_PortableDeviceKeyCollection,
                                NULL,
                                CLSCTX_INPROC_SERVER,
                                IID_PPV_ARGS(&pKeys));
  if(FAILED(hr)){
	  return 1;
  }
  return 0;
}" HAS_SENSOR_API_LIB)

IF (NOT HAS_SENSOR_API_LIB)
  MESSAGE(FATAL_ERROR "Windows Sensor API not found on this platform: Sensorsapi.lib OR PortableDeviceGUIDs.lib seems missing")
ENDIF()

set(WindowsSensorAPI_FOUND TRUE)