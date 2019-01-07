This document will help you get started with SATIE by guiding you through its installation on Ubuntu 18.04 and macOS. It recommended that you use SATIE with the latest versions of SuperCollider and sc3-plugins. SATIE is intended to be used with `supernova`, SuperCollider's alternative multi-threaded audio server. For higher order ambisonics, SATIE makes use of the `HOAUGens` which are part of sc3-plugins since version 3.10. 

In summary, SATIE needs:
- SuperCollider 3.10+
- sc3-plugins 3.10+
- SATIE quark itself
- SC-HOA quark
- additional downloadable ressources for ambisonics 

The following will help you get SuperCollider and sc3-plugins installed on your system. Please consult these project's documentation for more in-depth information:

[SuperCollider on GitHub](https://github.com/supercollider/supercollider/tree/master)
[sc3-plugins on GitHub](https://github.com/supercollider/sc3-plugins/tree/master)

## macOS

### Installing SuperCollider

To install SuperCollider, head over to the releases page and download the macOS release binary:

<https://github.com/supercollider/supercollider/releases>

Extract and drag the 'SuperCollider` folder in your 'Applications` folder.

### Installing sc3-plugins

To install the sc3-plugins, head over to the releases page and download the macOS release binary:

<https://github.com/supercollider/sc3-plugins/releases>

**Note:** Be sure to download the version of sc3-plugins that matches your version of SuperCollider.

Extract and place the sc3-plugins forlder in your SuperCollider extensions folder. By default, this folder is located at:

```supercollider
~/Library/Application Support/SuperCollider/Extensions
```

## linux

### Installing SuperCollider

SuperCollider 3.10 isn't packaged for Ubuntu at the time of writing. Building it is therefore the only option.
Fortunately, building SuperCollider is a relatively simple process. The following instructions will guide you through the build
process on Ubuntu 18.04. If you are using a prior version of Ubuntu, follow the instructions provided in the 
[Linux README](https://github.com/supercollider/supercollider/blob/master/README_LINUX.md).

#### Install build dependencies

Before building SuperCollider, you must install its build dependencies. Fortunately, the required packages are all available to install using Ubuntu package manager. Install the following packages with this command:

```bash
sudo apt-get install build-essential libsndfile1-dev libasound2-dev libavahi-client-dev 
libicu-dev libreadline6-dev libfftw3-dev libxt-dev libudev-dev pkg-config git cmake 
qt5-default qt5-qmake qttools5-dev qttools5-dev-tools qtdeclarative5-dev qtpositioning5-dev 
libqt5sensors5-dev libqt5opengl5-dev qtwebengine5-dev libqt5svg5-dev libqt5websockets5-dev
```

#### Clone SuperCollider

You will need to clone the SuperCollider source code and fetch it's submodules. Create a folder in which to clone the SuperCollider source. Assuming the folder is `~/src`, run the following commands:

```bash
cd ~/src
git clone --branch master --recurse-submodules https://github.com/supercollider/supercollider.git
cd supercollider
git submodule update
```

#### Build and install 

You can now build and install SuperCollider on your system. First, create a build folder at the root of your cloned SuperCollider source folder. Then, configure, build, and install. 

```bash
cd ~/src/supercollider
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DNATIVE=ON -DSC_EL=OFF ..   # turn off emacs-based IDE
make
sudo make install
sudo ldconfig    # needed when building SuperCollider for the first time
```

### Installing sc3-plugins

Like SuperCollider, the sc3-plugins version 3.10 aren't currently packaged for linux, but can 
be built easily. Assuming you want to clone the source code into `~/src`, run the following commands:

```
cd ~/src
git clone --branch master --recurse-submodules https://github.com/supercollider/sc3-plugins.git
cd sc3-plugins
git submodule update
mkdir build && cd build
cmake -DSC_PATH=../../supercollider/ -DSUPERNOVA=ON -DCMAKE_BUILD_TYPE=Release -DNATIVE=ON ..
make
sudo make install
```

## Install SATIE and its dependencies

You can install the SATIE Quark from within the IDE by using the `Quarks.install` command. Write the following lines of code in a new document and evaluate them by moving the cursor on a line and hitting `Ctrl-Enter`. Evaluate the following lines one after the other:

```
Quarks.install("SATIE");
```

### Installing additional resources

Binaural rendering in SATIE is made possible through the SC-HOA Quark, the HOAUGens (from sc3-plugins), and the HRIR filters from the ambitools project. In order to make full use of SATIE, you will need to download HFIR filters and place them in a specific location on your system.

First, create the following location on your system:
```
mkdir ~/.local/share/HOA/kernels/ 
```

Next, download a copy of the ambitools repository from GitHub and extract its contents:

https://github.com/sekisushai/ambitools/archive/master.zip

Copy the folder called `/FIR` and place it inside the above `/kernels` folder.


## SATIE at the Society for arts and technology [SAT]

SATIE is developped by the [Metalab](http://sat.qc.ca/fr/recherche/metalab) team at the [Society for arts and technology](http://sat.qc.ca). Additional SATIE plugins and SuperCollider UGens have been developed by the Metalab in order to be used in the [Satosphère](http://sat.qc.ca/fr/satosphere) and with other audio systems at the SAT. Please see the [metalab-ugens repository](https://gitlab.com/sat-metalab/metalab-ugens) for more information.
