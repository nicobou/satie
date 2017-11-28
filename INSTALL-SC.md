**Goal**: you want SuperCollider version 3.8 and sc3-plugins working with supernova (the parallel SuperCollider server), so that SATIE will run many sound sources simultaneously.

Building for Ubuntu 16.04 and up
-------------------------

From a terminal, go into your source directory and type the following commands.

### Install dependencies

```
sudo apt-get install build-essential libqt4-dev libqtwebkit-dev \
    libjack-jackd2-dev libsndfile1-dev libasound2-dev libavahi-client-dev \
    libicu-dev libreadline6-dev libfftw3-dev libxt-dev libcwiid-dev \
    pkg-config cmake subversion git qt5-default qt5-qmake qttools5-dev qttools5-dev-tools qtdeclarative5-dev \
    libqt5webkit5-dev qtpositioning5-dev libqt5sensors5-dev libqt5opengl5-dev libudev-dev
```

### Building SuperCollider
```
git clone https://github.com/supercollider/supercollider.git
cd supercollider
git checkout Version-3.8.0
git submodule init && git submodule update
mkdir build
cd build
cmake ..
make
sudo make install
```

### sc3-plugins
```
git clone https://github.com/supercollider/sc3-plugins.git
cd sc3-plugins
git checkout Version-3.8.0
git submodule init && git submodule update
mkdir build
cd build
cmake -DSC_PATH=../../supercollider/ -DQUARKS=OFF -DSUPERNOVA=ON ..
make
sudo make install
```

Then type `scide` (the SuperCollider IDE) and check the console to see if everything installed well.

SATIE is a SuperCollider Quark and it depends on the following Quarks:

- UnitTesting
- AmbIEM
- Ctk
- Atk


####  plugin locations for OSX
The supercollider plugins should be located in:

`/Library/Application Support/SuperCollider/Extensions/plugins`
or

`~/Library/Application Support/SuperCollider/Extensions/plugins`

## Binaural Rendering
Satie provides two binaural rendering options. Using HRTF filtering, the chosen renderer will convert the multi-channel spatialized output signal of each sound source to a stereo binaural signal. Both options depend on non-kernal resources that need to be installed for use. The installation and configuration details for each option are shown below:
#### ambi1
First order ambisonics method, using the ATK [Ambisonic Tool Kit] (http://www.ambisonictoolkit.net/)  package that is a standard sc3-plugin. To use this, the `Ctk` (Composers Tool Kit) quark must be installed. Follow directions in the following section.
#### ambi3
Third order ambisonics method, using the [AmbIEM package](http://sonenvir.at/downloads/sc3/ambiem/). To use this, the `AmbIEM` quark must be installed. Follow directions in the following section.
### Installing quarks
Quarks can be installed in a number of ways. Here are two ways to do it (in supercollider):

~~~~
// installation via the gui:
Quarks.gui

// installation via command:
Quarks.install("AmbIEM");
Quarks.install("Ctk");
~~~~

note:  once you have installed the quark(s) in supercollider, you will need to evaluate the following lines so that supercollider remembers.

~~~~
LanguageConfig.includePaths
LanguageConfig.store
~~~~

### HRTF data resources
Each option depends on a corresponding set of HRTF data. Satie provides submodules with copies of these databases, which will be installed automatically when using the `git clone --recursive` flag. For more information on the subject:

[ATK] (http://www.ambisonictoolkit.net/documentation/supercollider)

[AmbIEM] (http://alumni.media.mit.edu/~kdm/hrtfdoc/hrtfdoc.html)
