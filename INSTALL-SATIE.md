## Getting Started with SATIE on Linux and macOS

This document will help get you started with SATIE by guiding you through its installation on _Ubuntu 18.04_ and _macOS_. It's recommended that you use SATIE with the latest stable versions of SuperCollider and sc3-plugins. For higher-order ambisonics, SATIE makes use of the _HOAUGens_ (available in sc3-plugins 3.10+). SATIE is designed to make use of SuperCollider's alternative multithreaded audio server, _supernova_.

In order to use SATIE, you will need:
* SuperCollider 3.10+
* sc3-plugins 3.10+
* SATIE quark
* additional downloadable resources for ambisonics

In-depth documentation and platform specific installation instructions for SuperCollider and sc3-plugins can be found in their respective Github repositories:
* [SuperCollider on GitHub](https://github.com/supercollider/supercollider/tree/master)
* [sc3-plugins on GitHub](https://github.com/supercollider/sc3-plugins/tree/master)



## macOS

#### Installing SuperCollider

To install SuperCollider, head over to the releases page and download the macOS release binary:

https://github.com/supercollider/supercollider/releases

Extract and drag `SuperCollider` into your `Applications` folder.

#### Installing sc3-plugins

To install the sc3-plugins, head over to the releases page and download the macOS release binary:

https://github.com/supercollider/sc3-plugins/releases

> **Note:** Be sure to download the version of sc3-plugins that matches your version of SuperCollider

Extract and place the sc3-plugins folder in your SuperCollider extensions folder. By default, this folder is located at:

```
~/Library/Application Support/SuperCollider/Extensions
```



## Linux

#### Installing SuperCollider

SuperCollider 3.10 isn't packaged for Ubuntu at the time of writing. Building it from source is therefore required.
The following instructions will guide you through the build process on Ubuntu 18.04.
If you are using a prior version of Ubuntu, follow the instructions provided in SuperCollider's 
[Linux README](https://github.com/supercollider/supercollider/blob/master/README_LINUX.md).

##### Install build dependencies

Before building SuperCollider, you must install its build dependencies. The required packages are available to install using Ubuntu's package manager.

Use this command to install the packages:

```
sudo apt-get install build-essential libsndfile1-dev libasound2-dev libavahi-client-dev \
libicu-dev libreadline6-dev libfftw3-dev libxt-dev libudev-dev pkg-config git cmake \
qt5-default qt5-qmake qttools5-dev qttools5-dev-tools qtdeclarative5-dev qtpositioning5-dev \
libqt5sensors5-dev libqt5opengl5-dev qtwebengine5-dev libqt5svg5-dev libqt5websockets5-dev
```

##### Clone SuperCollider

You will need to clone the SuperCollider Github repository and fetch the project's submodules.

Assuming you want to clone the repository into a folder called `~/src`, run the following commands:

```
cd ~/src
git clone --branch master --recurse-submodules https://github.com/supercollider/supercollider.git
cd supercollider
git submodule update --init
```

##### Build and install 

Create a build folder, then configure, make, and install:

```
cd ~/src/supercollider
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DNATIVE=ON -DSC_EL=OFF ..   # turn off emacs-based IDE
make
sudo make install
sudo ldconfig    # needed when building SuperCollider for the first time
```



#### Installing sc3-plugins

Like SuperCollider, sc3-plugins 3.10 isn't currently packaged for Linux.
You will need to clone the sc3-plugins Github repository and fetch the project's submodules.

Assuming you want to clone the repository into a folder called `~/src`, run the following commands:

```
cd ~/src
git clone --branch master --recurse-submodules https://github.com/supercollider/sc3-plugins.git
cd sc3-plugins
git submodule update --init
```

Create a build folder, then configure, build, and install:

```
mkdir build && cd build
cmake -DSC_PATH=../../supercollider/ -DSUPERNOVA=ON -DCMAKE_BUILD_TYPE=Release -DNATIVE=ON ..
make
sudo make install
```



## Install SATIE

The SATIE quark can be installed directly from within the SuperCollider IDE (scide).

In a new document, write the following line of code and evaluate it by hitting `Ctrl-Enter`:

```
Quarks.install("SATIE");
```

> **Note:** SATIE depends on another quark, called _SC-HOA_, for its higher-order ambisonics capabilities. This quark will be installed automatically when installing SATIE.

You must restart the SuperCollider interpreter, or recompile the class library, in order to make SATIE available for use after installation.



### Additional ambisonic resources

Binaural rendering in SATIE is made possible through the _SC-HOA_ quark, the _HOAUGens_, and HRIR filters taken from the [ambitools](https://github.com/sekisushai/ambitools) project.
You will need to download these HRIR filters and place them in a specific location on your system.

Create the specified directory for your operating system:

* Linux `~/.local/share/HOA/kernels/`
* macOS `~/Library/Application Support/HOA/kernels/`
* Windows `C:\Users\_your-username_\AppData\Local\HOA\kernels\`

Then, download a compressed copy of the ambitools repository:

https://github.com/sekisushai/ambitools/archive/master.zip

Extract the contents of the zip file somewhere on your system. The only thing you'll need is the folder called `/FIR`.
Place a copy of this folder in the above mentioned `/kernels` directory.
Once this is done, you can delete the zipped ambitools repository you just downloaded.

