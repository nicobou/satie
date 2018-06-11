**Note**: SATIE is now updated to use SuperCollider version 3.9

**Goal**: you want SuperCollider version 3.9 and sc3-plugins working with supernova (the parallel SuperCollider server), so that SATIE will run many sound sources simultaneously.

Building for Ubuntu 16.04 and up
-------------------------

Open a terminal and create a source directory inside which you will clone *SuperCollider* and *sc3-plugins*:
```
cd ~/	# move to the root of your user's home 
mkdir -p source && cd source
```

### Install dependencies

```
sudo apt-get install build-essential libqt4-dev libqtwebkit-dev \
    libjack-jackd2-dev libsndfile1-dev libasound2-dev libavahi-client-dev \
    libicu-dev libreadline6-dev libfftw3-dev libxt-dev libcwiid-dev \
    pkg-config cmake subversion git qt5-default qt5-qmake qttools5-dev qttools5-dev-tools qtdeclarative5-dev \
    libqt5webkit5-dev qtpositioning5-dev libqt5sensors5-dev libqt5opengl5-dev libudev-dev
```

### Building SuperCollider
Run the following commands from the root of your source directory:
```
git clone https://github.com/supercollider/supercollider.git
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

### Install required SuperCollider Quarks
Before building the sc3-plugins in the next step, you will need to install a few SuperCollider Quarks and their dependancies.
In a terminal, open the SuperCollider IDE by using the following command:
```
scide
```
Once the IDE is open, you can install Quarks by typing the `Quarks.install` command and evaluating it. You can run commands by moving the cursor to a line and hitting Ctrl-Enter (Cmd-Enter on macOS). The required Quarks for SATIE are: *MathLib*, *NodeSnapshot*, and *SC-HOA*. 
Evaluate the following lines one at a time:
```
Quarks.install("NodeSnapshot");
Quarks.install("MathLib");
Quarks.install("SC-HOA");
LanguageConfig.addExcludePath(Platform.userAppSupportDir ++ "/downloaded-quarks/UnitTesting").store;

```
Running the last line is required due to a conflict between the UnitTesting Quark and SuperCollider's new built-in UnitTesting classes. The UnitTesting Quark's path needs to be excluded in order for SuperCollider's class library to successfully compile.
If UnitTesting is causing `duplicate Class found` errors when starting SC or recompiling the class library, you will need to manually delete it from your system. In the IDE's menu, click *File->Open user support directory* then navigate to the `downloaded-quarks` folder and delete the folder called `UnitTesting`.

### Building sc3-plugins
Run the following commands from the root of your source directory:
```
git clone https://gitlab.com/sat-metalab/forks/sc3-plugin-with-HOA
cd sc3-plugin-with-HOA
git checkout feat/sc-hoa
git submodule update --init
mkdir build
cd build
cmake -DSC_PATH=../../supercollider/ -DSUPERNOVA=ON -DCMAKE_BUILD_TYPE=Release -DNATIVE=ON ..
make
sudo make install
```

Building for OSX
-------------------------

####  plugin locations for OSX
The supercollider plugins should be located in:

`/Library/Application Support/SuperCollider/Extensions/plugins`
or
`~/Library/Application Support/SuperCollider/Extensions/plugins`

Adding dependencies
-------------------------
### Binaural kernels for SC_HOA
Binaural rendering is made possible through the ambitools HRIR Filters. Here follows how to download and make available the HRIR files.

~~~~
mkdir -p ~/.local/share/satie/
cd ~/.local/share/satie/
git clone https://github.com/sekisushai/ambitools.git
~~~~

Then, the HRIR files for ku100 are located in `~/.local/share/satie/ambitools/FIR/hrir/hrir_ku100_lebedev50/`, which is the default configuration path for SATIE.

### Installing SATIE
In order to install SATIE, open the SuperCollider IDE and run the following:
```
Quarks.install("https://gitlab.com/sat-metalab/SATIE")
```
Once the Quark has been sucessfully fetched from git, run the following so that SATIE's path will be included during SuperCollider's class library compilation:
```
LanguageConfig.addIncludePath(Platform.userAppSupportDir ++ "/downloaded-quarks/SATIE").store
```
