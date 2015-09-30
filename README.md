see examples/example.scd, the following is about installing supercollider with supernova on ubuntu and OSX.

How to Install supercollider with supernova on linux
----------------------------------------------------

wget http://sourceforge.net/projects/supercollider/files/Source/3.6/SuperCollider-3.6.6-Source.tar.bz2
tar -xvjf SuperCollider-3.6.6-Source.tar.bz2
cd SuperCollider-Source/
sudo apt-get install build-essential libqt4-dev libqtwebkit-dev \
    libjack-jackd2-dev libsndfile1-dev libasound2-dev libavahi-client-dev \
    libicu-dev libreadline6-dev libfftw3-dev libxt-dev libcwiid-dev \
    pkg-config cmake subversion
mkdir build
cd build
cmake ..
make -j8
sudo make install

Install sc-plugins (with vbap)
------------------------------
git clone  https://github.com/supercollider/sc3-plugins.git
cd sc3-plugins/
git submodule init && git submodule update
mkdir build
cd build
cmake -DSC_PATH=../../SuperCollider-Source/ -DQUARKS=OFF -DSUPERNOVA=ON ..
make -j8 && sudo make install


Compiling SuperNova on OSX
---------------------------
Versions of supercollider < 3.7 don’t seem to compile
Refer to instructions in the README_OSX.md file  (use -DSUPERNOVA=ON, install Homebrew and deps. etc)
Making the SC3-Plugins was straightforward. But you must copy the all the SC3 supernova plugins into your built superCollider.app/Content/Resources/Plugins folder, so they will be seen. 
NOTE: make sure you have an Audio MIDI setup in which there are inputs and outputs defined
