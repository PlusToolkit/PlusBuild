@echo off
for /f "skip=1" %%x in ('wmic os get localdatetime') do if not defined MyDate set MyDate=%%x
set today=%MyDate:~0,4%-%MyDate:~4,2%-%MyDate:~6,2%-%MyDate:~8,6%-%MyDate:~15,2%
set A=.\Plus-bin_applied_%today%.tar.gz

set ParentPath=..\..\..
set PB=.\Plus-bin
set PApp=%PB%\PlusApp
set PAppDoc=%PApp%\Documentation
set PL=%PB%\PlusLib
set PLsrc=%PL%\src
set PLsrcDoc=%PLsrc%\Documentation
set PLsrcDocUM=%PLsrcDoc%\UserManual
set PLsrcDC=%PLsrc%\PlusDataCollection
set PLsrcDCTEEV2=%PLsrcDC%\InfraredTEEV2Cam
set PLsrcDCPCOUV=%PLsrcDC%\UltravioletPCOUVCam
set PLsrcDCTest=%PLsrcDC%\Testing
set PLsrcUtil=%PLsrc%\Utilities
set PLsrcUtilTEEV2=%PLsrcUtil%\InfraredTEEV2Camera
set PLsrcUtilPCOUV=%PLsrcUtil%\UltravioletPCOUVCamera
set PLData=%PB%\PlusLibData
set PLDataConfig=%PLData%\ConfigFiles
set PLDataConfigTest=%PLDataConfig%\Testing


echo copy %PAppDoc%\Configuration.dox %ParentPath%\%PAppDoc%\    
copy %PAppDoc%\Configuration.dox %ParentPath%\%PAppDoc%\    
echo copy %PL%\CMakeLists.txt %ParentPath%\%PL%\    
copy %PL%\CMakeLists.txt %ParentPath%\%PL%\    
echo copy %PLsrc%\PlusConfigure.h.in %ParentPath%\%PLsrc%\
copy %PLsrc%\PlusConfigure.h.in %ParentPath%\%PLsrc%\
echo copy %PLsrc%\UsePlusLib.cmake.in %ParentPath%\%PLsrc%\
copy %PLsrc%\UsePlusLib.cmake.in %ParentPath%\%PLsrc%\
echo copy %PLsrcDocUM%\DeviceInfraredTEEV2Cam.dox %ParentPath%\%PLsrcDocUM%\
copy %PLsrcDocUM%\DeviceInfraredTEEV2Cam.dox %ParentPath%\%PLsrcDocUM%\
echo copy %PLsrcDocUM%\DeviceUltravioletPCOUVCam.dox %ParentPath%\%PLsrcDocUM%\
copy %PLsrcDocUM%\DeviceUltravioletPCOUVCam.dox %ParentPath%\%PLsrcDocUM%\
echo copy %PLsrcDC%\CMakeLists.txt %ParentPath%\%PLsrcDC%\
copy %PLsrcDC%\CMakeLists.txt %ParentPath%\%PLsrcDC%\
echo copy %PLsrcDC%\vtkPlusDeviceFactory.cxx %ParentPath%\%PLsrcDC%\
copy %PLsrcDC%\vtkPlusDeviceFactory.cxx %ParentPath%\%PLsrcDC%\
echo copy %PLsrcDCTEEV2%\*.* %ParentPath%\%PLsrcDCTEEV2%\
copy %PLsrcDCTEEV2%\*.* %ParentPath%\%PLsrcDCTEEV2%\
echo copy %PLsrcDCPCOUV%\*.* %ParentPath%\%PLsrcDCPCOUV%\
copy %PLsrcDCPCOUV%\*.* %ParentPath%\%PLsrcDCPCOUV%\
echo copy %PLsrcDCTest%\CMakeLists.txt %ParentPath%\%PLsrcDCTest%\
copy %PLsrcDCTest%\CMakeLists.txt %ParentPath%\%PLsrcDCTest%\
echo copy %PLsrcDCTest%\vtkInfraredTEEV2CamTest.cxx %ParentPath%\%PLsrcDCTest%\
copy %PLsrcDCTest%\vtkInfraredTEEV2CamTest.cxx %ParentPath%\%PLsrcDCTest%\
echo copy %PLsrcDCTest%\vtkUltravioletPCOUVCamTest.cxx %ParentPath%\%PLsrcDCTest%\
copy %PLsrcDCTest%\vtkUltravioletPCOUVTest.cxx %ParentPath%\%PLsrcDCTest%\
echo copy %PLsrcUtilTEEV2%\*.* %ParentPath%\%PLsrcUtilTEEV2%\
copy %PLsrcUtilTEEV2%\*.* %ParentPath%\%PLsrcUtilTEEV2%\
echo copy %PLsrcUtilPCOUV%\*.* %ParentPath%\%PLsrcUtilPCOUV%\
copy %PLsrcUtilPCOUV%\*.* %ParentPath%\%PLsrcUtilPCOUV%\
echo copy %PLDataConfig%\PlusDeviceSet_Server_InfraredTEEV2Camera.xml %ParentPath%\%PLDataConfig%\
copy %PLDataConfig%\PlusDeviceSet_Server_InfraredTEEV2Camera.xml %ParentPath%\%PLDataConfig%\
echo copy %PLDataConfig%\PlusDeviceSet_Server_UltravioletPCOUVCamera.xml %ParentPath%\%PLDataConfig%\
copy %PLDataConfig%\PlusDeviceSet_Server_UltravioletPCOUVCamera.xml %ParentPath%\%PLDataConfig%\
echo copy %PLDataConfigTest%\PlusDeviceSet_DataCollectionOnly_InfraredTEEV2CamTest.xml %ParentPath%\%PLDataConfigTest%\
copy %PLDataConfigTest%\PlusDeviceSet_DataCollectionOnly_InfraredTEEV2CamTest.xml %ParentPath%\%PLDataConfigTest%\
echo copy %PLDataConfigTest%\PlusDeviceSet_DataCollectionOnly_UltravioletPCOUVCamTest.xml %ParentPath%\%PLDataConfigTest%\
copy %PLDataConfigTest%\PlusDeviceSet_DataCollectionOnly_UltravioletPCOUVCamTest.xml %ParentPath%\%PLDataConfigTest%\
     
pause