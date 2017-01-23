**Goal**: you want SuperCollider version 3.8 and sc3-plugins working with supernova (the parallel SuperCollider server), so that SATIE will run many sound sources simultaneously.

Building for Ubuntu 16.04
-------------------------

From a terminal, go into your source directory and type the following commands.

### Install dependencies

```
sudo apt-get install build-essential libqt4-dev libqtwebkit-dev \
    libjack-jackd2-dev libsndfile1-dev libasound2-dev libavahi-client-dev \
    libicu-dev libreadline6-dev libfftw3-dev libxt-dev libcwiid-dev \
    pkg-config cmake subversion git qt5-default qt5-qmake qttools5-dev qttools5-dev-tools qtdeclarative5-dev \
    libqt5webkit5-dev qtpositioning5-dev libqt5sensors5-dev libudev-dev
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


Note for OSX
------------

You must copy the all the SC3 supernova plugins into your built superCollider.app/Content/Resources/Plugins folder, so they will be seen. Note you need to make sure you have an Audio MIDI setup in which there are inputs and outputs defined.

