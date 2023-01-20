@echo off
for /f "skip=1" %%x in ('wmic os get localdatetime') do if not defined MyDate set MyDate=%%x
set today=%MyDate:~0,4%-%MyDate:~4,2%-%MyDate:~6,2%-%MyDate:~8,6%-%MyDate:~15,2%
set A=.\Plus-bin_old_%today%_bak.tar.gz
set B=.\Plus-bin_new_%today%_bak.tar.gz
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

if exist %PB% (
    tar -cvzf %A% .\Plus-bin 
) else (
    mkdir %PB%
    mkdir %PApp%
    mkdir %PAppDoc%
    mkdir %PL%
    mkdir %PLsrc%
    mkdir %PLsrcDoc%
    mkdir %PLsrcDocUM%
    mkdir %PLsrcDC%
    mkdir %PLsrcDCTEEV2%
    mkdir %PLsrcDCPCOUV%
    mkdir %PLsrcDCTest%
    mkdir %PLsrcUtil%
    mkdir %PLsrcUtilTEEV2%   
    mkdir %PLsrcUtilPCOUV%   
    mkdir %PLData%
    mkdir %PLDataConfig%
    mkdir %PLDataConfigTest%
)

echo copy %ParentPath%\%PAppDoc%\Configuration.dox %PAppDoc%\    
copy %ParentPath%\%PAppDoc%\Configuration.dox %PAppDoc%\    
echo copy %ParentPath%\%PL%\CMakeLists.txt %PL%\    
copy %ParentPath%\%PL%\CMakeLists.txt %PL%\    
echo copy %ParentPath%\%PLsrc%\PlusConfigure.h.in %PLsrc%\
copy %ParentPath%\%PLsrc%\PlusConfigure.h.in %PLsrc%\
echo copy %ParentPath%\%PLsrc%\UsePlusLib.cmake.in %PLsrc%\
copy %ParentPath%\%PLsrc%\UsePlusLib.cmake.in %PLsrc%\
echo copy %ParentPath%\%PLsrcDocUM%\DeviceInfraredTEEV2Cam.dox %PLsrcDocUM%\
copy %ParentPath%\%PLsrcDocUM%\DeviceInfraredTEEV2Cam.dox %PLsrcDocUM%\
echo copy %ParentPath%\%PLsrcDocUM%\DeviceUltravioletPCOUVCam.dox %PLsrcDocUM%\
copy %ParentPath%\%PLsrcDocUM%\DeviceUltravioletPCOUVCam.dox %PLsrcDocUM%\
echo copy %ParentPath%\%PLsrcDC%\CMakeLists.txt %PLsrcDC%\
copy %ParentPath%\%PLsrcDC%\CMakeLists.txt %PLsrcDC%\
echo copy %ParentPath%\%PLsrcDC%\vtkPlusDeviceFactory.cxx %PLsrcDC%\
copy %ParentPath%\%PLsrcDC%\vtkPlusDeviceFactory.cxx %PLsrcDC%\
echo copy %ParentPath%\%PLsrcDCTEEV2%\*.* %PLsrcDCTEEV2%\
copy %ParentPath%\%PLsrcDCTEEV2%\*.* %PLsrcDCTEEV2%\
echo copy %ParentPath%\%PLsrcDCPCOUV%\*.* %PLsrcDCPCOUV%\
copy %ParentPath%\%PLsrcDCPCOUV%\*.* %PLsrcDCPCOUV%\
echo copy %ParentPath%\%PLsrcDCTest%\CMakeLists.txt %PLsrcDCTest%\
copy %ParentPath%\%PLsrcDCTest%\CMakeLists.txt %PLsrcDCTest%\
echo copy %ParentPath%\%PLsrcDCTest%\vtkInfraredTEEV2CamTest.cxx %PLsrcDCTest%\
copy %ParentPath%\%PLsrcDCTest%\vtkInfraredTEEV2CamTest.cxx %PLsrcDCTest%\
echo copy %ParentPath%\%PLsrcDCTest%\vtkUltravioletPCOUVCamTest.cxx %PLsrcDCTest%\
copy %ParentPath%\%PLsrcDCTest%\vtkUltravioletPCOUVCamTest.cxx %PLsrcDCTest%\
echo copy %ParentPath%\%PLsrcUtilTEEV2%\*.* %PLsrcUtilTEEV2%\
copy %ParentPath%\%PLsrcUtilTEEV2%\*.* %PLsrcUtilTEEV2%\
echo copy %ParentPath%\%PLsrcUtilPCOUV%\*.* %PLsrcUtilPCOUV%\
copy %ParentPath%\%PLsrcUtilPCOUV%\*.* %PLsrcUtilPCOUV%\
echo copy %ParentPath%\%PLDataConfig%\PlusDeviceSet_Server_InfraredTEEV2Camera.xml %PLDataConfig%\
copy %ParentPath%\%PLDataConfig%\PlusDeviceSet_Server_InfraredTEEV2Camera.xml %PLDataConfig%\
echo copy %ParentPath%\%PLDataConfig%\PlusDeviceSet_Server_UltravioletPCOUVCamera.xml %PLDataConfig%\
copy %ParentPath%\%PLDataConfig%\PlusDeviceSet_Server_UltravioletPCOUVCamera.xml %PLDataConfig%\
echo copy %ParentPath%\%PLDataConfigTest%\PlusDeviceSet_DataCollectionOnly_InfraredTEEV2CamTest.xml %PLDataConfigTest%\
copy %ParentPath%\%PLDataConfigTest%\PlusDeviceSet_DataCollectionOnly_InfraredTEEV2CamTest.xml %PLDataConfigTest%\
echo copy %ParentPath%\%PLDataConfigTest%\PlusDeviceSet_DataCollectionOnly_UltravioletPCOUVCamTest.xml %PLDataConfigTest%\
copy %ParentPath%\%PLDataConfigTest%\PlusDeviceSet_DataCollectionOnly_UltravioletPCOUVCamTest.xml %PLDataConfigTest%\
    
tar -cvzf %B% .\Plus-bin     

pause