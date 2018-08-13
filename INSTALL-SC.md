This document will guide you through building SuperCollider and sc3-plugins from source, as well as installing SATIE and its necessary resources, on Ubuntu 16.04 and up.

**Note:**  SATIE makes use of UGens called the *HOAUGens* found in the sc3-plugins collection. These UGens were added to the sc3-plugins repository at commit [9326e1229a64ca82f76124a7a1a038095be22996](https://github.com/supercollider/sc3-plugins/tree/9326e1229a64ca82f76124a7a1a038095be22996).

## Building SuperCollider 3.9 from git

Open a terminal and create a source directory inside which you will clone SuperCollider:
```
cd ~/	# move to the root of your user's home 
mkdir -p source && cd source
```

### Install dependencies

```
sudo apt-get install build-essential pkg-config cmake ccache git \
    libjack-jackd2-dev libsndfile1-dev libasound2-dev libavahi-client-dev \
    libicu-dev libreadline6-dev libfftw3-dev libxt-dev libudev-dev \
    qt5-default qt5-qmake qttools5-dev qttools5-dev-tools qtdeclarative5-dev \
    libqt5webkit5-dev qtpositioning5-dev libqt5sensors5-dev libqt5opengl5-dev
```

### Clone and build SuperCollider

Run the following commands from the root of your source directory:
```
git clone --recursive https://github.com/supercollider/supercollider.git
cd supercollider
git checkout 3.9
git submodule update --init
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DNATIVE=ON -DSC_EL=OFF ..    # turn off emacs-based IDE
make
sudo make install
sudo ldconfig    # needed when building SuperCollider for the first time
```

## Build sc3-plugins from git

Run the following commands from the root of your source directory:
```
git clone --recursive https://github.com/supercollider/sc3-plugins.git
cd sc3-plugins
git submodule update --init
mkdir build
cd build
cmake -DSC_PATH=../../supercollider/ -DSUPERNOVA=ON -DCMAKE_BUILD_TYPE=Release -DNATIVE=ON ..
make
sudo make install
```

## Install SATIE and its dependencies

In a terminal, open the SuperCollider IDE by using the following command:
```
scide
```

You can install the SATIE Quark from within the IDE by using the `Quarks.install` command. Write the following lines of code in a new document and evaluate them by moving the cursor on a line and hitting `Ctrl-Enter`. Evaluate the following lines one after the other:
```
Quarks.install("SATIE");
Quarks.uninstall("UnitTesting");
LanguageConfig.addExcludePath(Platform.userAppSupportDir ++ "/downloaded-quarks/UnitTesting").store;
```

**Note:**  Running the last two lines is required due to a conflict between the UnitTesting Quark and SuperCollider's new built-in UnitTest classes. The UnitTesting Quark's path needs to be excluded in order for SuperCollider's class library to successfully compile. If UnitTesting is causing `duplicate Class found` errors when starting SC, or when recompiling the class library, you will need to manually delete it from your system. In the IDE's menu, click `File->Open user support directory` then navigate to the `downloaded-quarks` folder and delete the folder called `UnitTesting`.

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
