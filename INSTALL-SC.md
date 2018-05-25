**Note**: SATIE is now updated to use SuperCollider version 3.9

**Goal**: you want SuperCollider version 3.9 and sc3-plugins working with supernova (the parallel SuperCollider server), so that SATIE will run many sound sources simultaneously.

Building for Ubuntu 16.04 and up
-------------------------

From a terminal, go into your source directory and type the following commands.

### Install dependencies

```
sudo apt-get install build-essential libqt4-dev libqtwebkit-dev \
    libjack-jackd2-dev libsndfile1-dev libasound2-dev libavahi-client-dev \
    libicu-dev libreadline6-dev libfftw3-dev libxt-dev libcwiid-dev \
    pkg-config cmake subversion git qt5-default qt5-qmake qttools5-dev qttools5-dev-tools qtdeclarative5-dev \
    libqt5webkit5-dev qtpositioning5-dev libqt5sensors5-dev libqt5opengl5-dev libudev-dev emacs
```

### Building SuperCollider
```
git clone https://github.com/supercollider/supercollider.git
cd supercollider
git checkout 3.9
git submodule init && git submodule update
mkdir build
cd build
cmake ..
make
sudo make install
```

### sc3-plugins
```
git clone https://gitlab.com/sat-metalab/forks/sc3-plugin-with-HOA
cd sc3-plugin-with-HOA
git checkout feat/sc-hoa
git submodule init && git submodule update
mkdir build
cd build
cmake -DSC_PATH=../../supercollider/ -DQUARKS=OFF -DSUPERNOVA=ON ..
make
sudo make install
```

Then type `scide` (the SuperCollider IDE) and check the console to see if everything installed well.

SATIE is a SuperCollider Quark and it depends on the following Quarks:

- SC-HOA

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

### Installing quarks
Quarks can be installed in a number of ways. Here are two ways to do it (in supercollider):

~~~~
// installation via the gui:
Quarks.gui

// installation via command:
Quarks.install("NodeSnapshot");
Quarks.install("MathLib");
Quarks.install("SC-HOA");
~~~~

You will also have to intall the SATIE quark. From the quark installation menu on the gui, click "install a folder" and select the SATIE folder.

or
~~~~
Quarks.install("https://gitlab.com/sat-metalab/SATIE")
~~~~
note:  once you have installed the quark(s) in supercollider, you will need to evaluate the following lines so that supercollider remembers.

~~~~
LanguageConfig.includePaths
LanguageConfig.store
~~~~
