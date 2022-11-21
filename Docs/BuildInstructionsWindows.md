The build process is regularly tested and officially supported for 32-bit and 64-bit builds on Visual Studio 2013 and 2015.

Prerequisites
=============

Install one of the following software packages. Note that other packages or versions may work, but they are not tested.

Required:

- **C++ compiler**
  - [VS2013 Community Edition Update 5: works](https://www.visualstudio.com/en-us/news/releasenotes/vs2013-community-vs)
  - [VS2015 Community Edition Update 3: works](https://docs.microsoft.com/en-us/visualstudio/releasenotes/vs2015-version-history)
  - VS2017 Community Edition: confirmed working with Qt 5.7 msvc2015 and msvc2015_64
- [**CMake** 3.10 or later](https://cmake.org/download)
- [**Git** (msysgit)](http://msysgit.github.io). Cygwin git is not recommended.
- **Qt framework** - download binaries for your specific configuration:
  - Building stable branch: Qt 4.8 and Qt 5.5, 5.7 are tested, download from http://www.qt.io/download/ or https://sourceforge.net/projects/qt64ng/files/qt/
  - Building master branch: Qt 5.5+ is supported. Download from [Qt website](http://www.qt.io/download). Make sure the Visual Studio version (e.g. 2013) and configuration (e.g. x64) you use is selected during installation.
- **Device SDKs**: The SDK of some devices are not publicly available. These SDKs has to be obtained from the device manufacturer.
  - Developers at Queen, UBC, Robarts, and other collaborators: Request access to the PLTools repository from <a href="https://github.com/PerkLab">PerkLab</a>, which contains the SDKs for BK, NDI, etc. and clone the repository in the same directory where PlusBuild folder is located. During the build process, required SDK files will be loaded automatically from the PLTools directory. Example: C:\Users\Joe\devel\PLTools and C:\Users\Joe\devel\PlusBuild.

Required for packaging and documentation generation:

- [**NSIS**](https://nsis.sourceforge.io/Download): required for building installation packages.
- [**Doxygen**](http://doxygen.nl/download.html): required for building documentation. Version 1.8.7 is currently used and detected automatically. Other versions may work as well.
- [**Graphviz**](https://graphviz.gitlab.io/download/): required for building documentation. Version 2.38 is currently used and detected automatically. Other versions may work as well, if not them update PlusLib/src/CMakeLists.txt to add support for other versions.
- [**Microsoft HTML Help 1.4**](http://go.microsoft.com/fwlink/p/?linkid=154968): required for building documentation in .chm Windows Help file format. Documentation is available [here](https://msdn.microsoft.com/en-us/library/windows/desktop/ms670169(v=vs.85).aspx).

Recommended tools:

- [TortoiseGit](https://tortoisegit.org/download/): provides convenient graphical user interface to manage git repositories.
- Visual Studio extensions:
  - AStyle formatter - Quickly format a file to PLUS standards. PLUS format: https://github.com/PlusToolkit/PlusLib/blob/master/.astylerc
  - [Visual Assist X](http://www.wholetomato.com/): Add extra functionality to Visual Studio. Not free.
  - [DoxygenComments](https://visualstudiogallery.msdn.microsoft.com/11a30c1c-593b-4399-a702-f23a56dd8548): Syntax highlighting of doxygen comments.
    - **WARNING:** It may not work with other extensions that changes syntax highlighting (Visual Assist, etc).
    - If syntax highlighting doesn't show up when you open a .dox file, try [this solution](http://stackoverflow.com/questions/21499143/how-to-get-syntax-highlighting-for-alternate-file-extension-for-visual-studio-20): Go to Tools / Options / Text Editor / File Extension and type your alternative extension and then associate it with your editor (e.g. Microsoft Visual C++)"

Build Process
=============

- Clone PlusBuild git repository from **https://github.com/PlusToolkit/PlusBuild.git** into **C:\D\PlusBuild**. A different target directory may be chosen, but keep it short, up to about 10 characters. This directory will be referred to as _PlusBuild_.
- Switch to branch:
  - **master**: this branch is selected by default, it is recommended for most developers (e.g., who plan to add features, modify the Plus library, or need recently added features)
  - **Plus-2.8**: stable version, recommended for users who do not plan to change anything in Plus and don't need recent features
- Configure the PlusBuild project with CMake
  - Recommended binary build directory location (this directory will be referred to as _Plus-bin_): **C:\D\PlusB-bin**. A different target directory may be chosen, but keep it short, up to about 10 characters.
  - Specify the generator
  - Enter git executable location if not detected automatically (an error message will be displayed)
  - Enter Qt library location if not detected automatically (an error message will be displayed)
    - Qt5 (only Qt5 is supported for nightly): specify **Qt5_DIR:PATH=_QtInstallDir_/lib/cmake/Qt5** (where Qt5Config.cmake file is located)
    - Qt4: specify **QT_QMAKE_EXECUTABLE:FILEPATH=_QtInstallDir_/bin/qmake.exe** (where qmake.exe is located)
  - Enable the hardware devices that you need to use (some examples listed here):
    - PLUS_USE_Ascension3DG: Ascension trakSTAR, driveBAY and medSAFE -- disable for 64-bit build
    - PLUS_USE_BRACHY_TRACKER: Accuseed DS, CIVCO, Burdette Medical Systems brachytherapy steppers
    - PLUS_USE_CERTUS: NDI Certus optical tracker, requires SDK from NDI -- disable for 64-bit build
    - PLUS_USE_ICCAPTURING_VIDEO: ImagingControl USB framegrabber, requires license key from ImagingControl
    - PLUS_USE_MICRONTRACKER: Claron MicronTracker -- disable for 64-bit build
    - PLUS_USE_POLARIS: NDI Polaris and NDI Aurora optical tracker -- disable for 64-bit build
    - PLUS_USE_BKPROFOCUS_VIDEO: BK ultrasound system connection through the OEM interface, requires SDK from BK (also enable PLUS_USE_BKPROFOCUS_CAMERALINK to connect through CameraLink interface)
  - Optional: set advanced build options
    - If you want to use a specific Plus revision then set it in PLUSLIB_GIT_REVISION and PLUSAPP_GIT_REVISION. Default is `master`, which means the latest version.
    - If you want to build a Slicer loadable module using Plus then turn on PLUSBUILD_USE_3DSlicer option and set the PLUSBUILD_SLICER_BIN_DIRECTORY to your 3D Slicer binary folder.
    - If you want to build the documentation enable PLUSBUILD_DOCUMENTATION. See the generating documentation section for more details.
  - Click Configure
- Click Generate to generate the PlusBuild project.
- Click Open Project to open PlusBuild in Visual Studio.
- Choose build configuration (Debug/Release)
- Select in menu: Build / Build Solution

Run Plus applications
=====================

- Running applications (without the debugger):
  - Open a command line prompt
  - Go to the  _Plus-bin_/bin/Release (or _Plus-bin_/bin/Debug) directory
  - Type the name of the executable you want to run and press enter. The program shall start.
- Debugging applications:
   - Open _Plus-bin_\PlusApp-bin\PlusApp.sln
   - Select the project corresponding to the application as startup project
   - Start debugging to run the application in debug mode

Updating and re-building Plus
=============================

Follow these steps if you have already built Plus and you need to get recent updates from the repository.

- To re-build all the solutions in _debug_ mode: open the _Plus-bin_/PlusBuild.sln solution in Visual Studio and build all in debug mode
- For convenience, these batch files can be used for Release mode builds:
  - Run the following command in the _Plus-bin_ directory: `PlusBuildAndTest.bat -C`. It updates the PlusBuild directory and all the Plus and external projects, then it builds and tests the modified projects).
  - To skip the update step and just build and test the current version, run `PlusBuildAndTest.bat` (without any parameters).

Generating documentation
========================

- Make sure additional documentation generation prerequisites are installed (see above).
- To build the PlusLib and PlusApp documentation you have to enable the advanced variable PLUSBUILD_DOCUMENTATION during the CMake configuration, reconfigure, regenerate, and build the PlusBuild project.
- Documentation projects have to be built separately (they are not part of ALL_BUILD) by right-clicking on the solution and selecting Build:
  - API documentation: PlusLib/Documentation
  - User manual: PlusApp/Documentation
- Generated documentation files are available at bin\Doc and User manual is also included in installation packages.

Troubleshooting
===============

- If you get errors saying: "A tool returned an error code from performing update step (git fetch)." for ITK or VTK then delete the _Plus-bin_/ITK or _Plus-bin_/VTK directoryand restart the build. Git sometimes fails to fetch to source files depending on the network connection.
- CMake Error at src/ImageAcquisition/CMakeLists.txt:236 (FILE): file COPY cannot find "/release/TIS_UDSHL08_vc9.dylib"
  - Root cause: attempting to build Plus with hardware support on MacOS. None of the hardware drivers are available on MacOS.
  - Solution: disable all hardware support when building Plus. Note that MacOS support is limited - see more details  in the Prerequisites section.
- Check for working C compiler using: Visual Studio 9 2008 Win64 -- broken
  - Root cause: Plus should be built using a 32 bit compiler, since the hardware devices do not support 32-bit applications
  - Solution: Go "File-&gt;Delete Cache", click Configure, then specify the version of Visual Studio 9 2008 without "Win64"
  - Alternative: If you really did mean to have a 64 bit PLUS build, double check that the Win64 C++ compilers were checked during the Visual Studio 2008 install. They are not by default.
- Error during building:<br />
  > Generating moc_PlusCaptureControlWidget.cpp
  > No command
  > 1&gt;AUTOGEN : error : process for C:/Users/User-User/devel/PlusExp-bin/PlusApp-bin/PlusCommonWidgets/moc_PlusCaptureControlWidget.cpp failed:
  > \[C:\Users\User-User\devel\PlusExp-bin\PlusApp-bin\PlusCommonWidgets\PlusCommonWidgets_automoc.vcxproj\]
     - Root cause: build directory path is too long
     - Solution: build Plus in a shorter directory, for example: <i>C:\D\PlusExp-build</i>
