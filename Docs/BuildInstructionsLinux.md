Ubuntu 24.04 LTS
================

PlusBuild project contains a CMake project that builds the Plus library, applications, and all their dependencies.
These commands install all prerequisites and builds Plus using default settings:

**Hint:** You can accelerate the compilation process by using parallel jobs; simply pass `-j <number_of_processes>` to the `make` command.

```
sudo apt update && sudo apt install git git-lfs gcc-11 g++-11 build-essential cmake \
    qtbase5-dev qt5-qmake qtmultimedia5-dev qttools5-dev libglvnd-dev libqt5xmlpatterns5-dev \
    qtbase5-private-dev libqt5x11extras5-dev libxt-dev qtdeclarative5-dev libqt5webenginewidgets5 qml-module-qtquick\*

git clone https://github.com/PlusToolkit/PlusBuild.git
mkdir PlusBuild-bin
cd PlusBuild-bin

export CC=/usr/bin/gcc-11
export CXX=/usr/bin/g++-11
export CPP=$CXX
export LD=$CXX
export QT_SELECT=qt5

cmake ../PlusBuild -DCMAKE_BUILD_TYPE=Release

make CC=$CC CXX=$CXX CPP=$CPP LD=$LD 
```

Ubuntu 22.04 LTS
================

PlusBuild project contains a CMake project that builds the Plus library, applications, and all their dependencies.
These commands install all prerequisites and builds Plus using default settings:

```
sudo apt update && sudo apt install git build-essential cmake \
    qtbase5-dev qt5-qmake qtmultimedia5-dev qttools5-dev libglvnd-dev libqt5xmlpatterns5-dev \
    qtbase5-private-dev libqt5x11extras5-dev libxt-dev qtdeclarative5-dev libqt5webenginewidgets5 qml-module-qtquick\*

git clone https://github.com/PlusToolkit/PlusBuild.git
mkdir PlusBuild-bin
cd PlusBuild-bin
cmake ../PlusBuild

make
```

Ubuntu 20.04 LTS
================

PlusBuild project contains a CMake project that builds the Plus library, applications, and all their dependencies.
These commands install all prerequisites and builds Plus using default settings:

```
sudo apt update && sudo apt install git build-essential cmake \
  qt5-default qtmultimedia5-dev qttools5-dev libqt5xmlpatterns5-dev qtbase5-private-dev libqt5x11extras5-dev libxt-dev

git clone https://github.com/PlusToolkit/PlusBuild.git
mkdir PlusBuild-bin
cd PlusBuild-bin
cmake ../PlusBuild

make
```

Ubuntu 16.04 LTS/18.04 LTS
================

Most device manufacturers don't support this platform, there are no drivers available, so beware using certain devices as they will not work. All processing and simulation should work on this platform.

Prerequisites
-------------

- **gcc**: -std=c++11 is used, please make sure your compiler has FULL support, ie.: gcc >= 5.0. Should be installed by default.
  `sudo apt install gcc`
- cmake
  - With GUI:
    `sudo apt install cmake-qt-gui`
  - Without GUI, only command line interface:
    `sudo apt install cmake`
- git
  - With GUI:
    `sudo apt install git-cola`
  - Without GUI, only command line interface:
    `sudo apt install git`
- VTK dependencies
  ```
  sudo apt install build-essential
  sudo apt build-dep vtk
  ```
- Qt
  `sudo apt install qtbase5-dev qttools5-dev libqt5webkit5-dev libqt5x11extras5-dev libqt5xmlpatterns5-dev`

Build Process
-------------

- Clone PlusBuild git repository from **https://github.com/PlusToolkit/PlusBuild.git** into **\home\username\devel\PlusBuild**. This directory will be referred to as _PlusBuild_.
- Switch to branch:
  - **master**: this branch is selected by default, it is recommended for most developers (e.g., who plan to add features, modify the Plus library, or need recently added features)
  - **Plus-2.8**: stable version, recommended for users who do not plan to change anything in Plus and don't need recent features
- Configure the PlusBuild project with CMake. Recommended binary build directory location: _\home\username\devel\PlusBuild-bin_.  This directory will be referred to as _Plus-bin_.
- Specify a generator:
  - Unix Makefiles
  - Eclipse CDT - Unix Makefiles
- Enter git, and qt library locations if they are not detected automatically.
  - Qt entry should read as _/some/qt-install-dir/lib/cmake/Qt5_
- Disable all hardware devices, there are no Linux drivers for hardware (consider writing the hardware vendors to request Linux drivers!)
- Optional: set advanced build options
  - If you want to use a specific Plus revision then set it in PLUSLIB_GIT_REVISION and PLUSAPP_GIT_REVISION. Default is `master`, which means the latest version.
	- If you want to build a Slicer loadable module using Plus then turn on PLUSBUILD_USE_3DSlicer option and set the PLUSBUILD_SLICER_BIN_DIRECTORY to your 3D Slicer binary folder.
- Generate the PlusBuild project with CMake
- Build Plus:
  - Change directory to _PlusBuild-bin_
	- Type `make`

Troubleshooting
---------------

- "GLintptr has not been declared"
  - Solution: In the vtkxOpenGLRenderWindow.cxx uncomment "#define GLX_GLXEXT_LEGACY"
- "Dunno about this gcc" error from Modules/ThirdParty/VNL/src/vxl/vcl/vcl_compiler.h
  - Solution: see [this patch file](https://issues.itk.org/jira/browse/ITK-3361)
- "vtkPlusConfig.cxx" error
  - Solution: #include "unistd.h" at the top and report the error

Ubuntu 14.04 LTS
================
This version of Ubuntu is not officially supported
- The gcc compiler provided by default (4.8.4) does not fully support c++11 and is missing functionality used by PlusLib
- The default version of Qt provided with the distribution (5.2.1) lacks some functionality required by PlusApp.
