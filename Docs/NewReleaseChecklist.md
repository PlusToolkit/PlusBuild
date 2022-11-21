# Creating new stable version

A new stable version of Plus is created when significant amount of new features and/or bugfixes are implemented and the library is stable and well tested. Preferably stable versions are released 3-4 times a year. Release schedule is determined by [PlusToolkit core team](https://github.com/orgs/PlusToolkit/teams/core-team).

Documentation of each release is generated automatically from files in the repositories and included in the release package (doc\PlusApp-UserManual.chm).

## Create new branch

If the major or minor version is updated then a new branch shall be created that can be used to deliver patch releases independently from the developments in the trunk. Follow these steps to create a new stable branch:

### PlusBuild
  - Create a new branch from the trunk as Plus-X.Y
  - In the new branch:
    - Update PLUSBUILD_PLUSLIBDATA_GIT_REVISION from master to Plus-X.Y
    - Update PLUSLIB_GIT_REVISION from master to Plus-X.Y
    - Update PLUSLIB_GIT_REVISION from master to Plus-X.Y
    - Update PLUSAPP_GIT_REVISION from master to Plus-X.Y
    - Update SetGitRepositoryTag in dependencies to reference the latest commit of third-party software:
      - External_OpenIGTLink
      - External_OpenIGTLinkIO
      - External_OvrvisionPro
      - External_Tesseract
      - External_aruco
      - External_ndicapi
      - Any other dependencies that refer to 'master' version instead of a specific git tag or hash
    - In the trunk:
      - Update stable version number in BuildInstructionsWindows.md and BuildInstructionsLinux.md

### PlusLib
  - Create a new branch from the trunk as Plus-X.Y
  - In the new branch:
    - Update minor version number to Y in CmakeLists.txt
  - In the trunk:
    - Update minor version number to Y+1 in CmakeLists.txt

### PlusApp
  - Create a new branch from the trunk as Plus-X.Y

### PlusLibData
  - Create a new branch from the trunk as Plus-X.Y

### Build scripts
  - Update PLUS_STABLE_VERSION in CommonVars.bat to version X.Y

## Test the new release

Double-check that all main features of Plus work before releasing stable build. See the "test plan" below. It would be nice to add more details (what config file was used, etc) as the test is performed. The test report would be used as a template for testing the next stable release (probably it would make sense to add to the PlusLib or PlusApp repository).

### Mandatory tests

- [ ] Green dashboard (no build or test errors):
  - Windows
    - [ ] PlusBuild
    - [ ] PlusApp
    - [ ] PlusLib
  - Linux
    - [ ] PlusBuild
    - [ ] PlusApp
    - [ ] PlusLib
  - Failing or unstable tests: ___
- Plus runs on Ultrasonix (Windows XP Embedded):
  - Slicer version: Slicer ___.___
  - Ultrasound exam software version: Sonix ___.___
  - Ultrasound probe: Ultrasonix ___
  - [ ] Live image is displayed in Slicer
  - [ ] Start/stop recording works in Slicer using PlusRemote
  - [ ] Scout scan and live volume reconstruction works in Slicer using PlusRemote
- [ ] Tracking using NDI Polaris
- [ ] Tracking using NDI Aurora
- [ ] Tracking using PhidgetSpatial
- [ ] Ultrasound imaging using Interson
- [ ] Ultrasound imaging using Telemed
- [ ] Image acquisition using Epiphan
- [ ] Image acquisition using webcam - Video for Windows
- [ ] Grayscale image acquisition using webcam - MMF
- [ ] Color image acquisition using webcam - MMF
- [ ] Image acquisition using ImagingControls
- [ ] Tracking using OpticalMarkerTracking
- [ ] Tracking using OptiTrack
- [ ] Replay of tracked video from saved data source
- [ ] US simulator using Slicer scene in DataStore
- [ ] OpenIGTLinkTracker
- [ ] OpenIGTLinkVideo
- [ ] ThorLabs spectrometer
- [ ] Test that user manual is available in the installed package (doc\PlusApp-UserManual.chm)

### Not included in testing

- Tracking using MicronTracker: not a priority anymore (Firewire interface is difficult to set up; OpticalMarkerTracking and OptiTrack devices can be used instead for most applications)
- RealSense: still experimental
- IntersonArraySDK: we don't have the hardware
- Agilent: we don't have the hardware
- BrachyTracking: not a priority anymore, we don't have all the hardware
- Capistrano: we don't have the hardware
- CHRobotics: not a priority anymore (PhidgetSpatial is easier to use)
- Haptics: we don't have the hardware
- ImageProcessor: still experimental
- IntuitiveDaVinci: we don't have the hardware
- MicrochipTracking: we don't have the hardware
- NDICertus: not a priority anymore (use Polaris instead, that's what most commercial devices use)
- NVidiaDVP: we don't have the hardware
- BK ultrasound OEM: we don't have the hardware
- BK ultrasound CameraLink: we don't have the hardware
- Optimet: we don't have the hardware
- OvrVisionPro: we don't have the hardware
- Philips3D: we don't have the hardware
- USDigital encoders: we don't have the hardware
- WinProbe: we don't have the hardware

## Finalize release

- Upload stable release installation packages to release download server
- Update this documentation to reflect any changes in the release process
