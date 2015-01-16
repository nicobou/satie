This what you will find here:
How to install supercollider & sc-plugins (with VBAP).
How get VBAP controled by OSC. 

install supercollider
---------------------

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

install sc-plugins (with vbap)
------------------------------
git clone  https://github.com/supercollider/sc3-plugins.git
cd sc3-plugins/
git submodule init && git submodule update
mkdir build
cd build
cmake -DSC_PATH=../../SuperCollider-Source/ -DQUARKS=ON -DSUPERNOVA=ON ..
make -j8 && sudo make install


VBAP controled by OSC
---------------------
sclang VBAP_splash.scd

OSC messages (port 3030):
------------------------
/azi     -180 to 180, sound source azimuth
/dist    0 to 100, source distance
/spread  0 to 100. When 0, if the signal is panned 
         exactly to a speaker location the signal is 
         only on that speaker. At values higher than 
         0, the signal will always be on more than 
         one speaker. This can smooth the panning 
         effect by making localisation blur more 
         constant.



command line testing:
---------------------
sudp apt-get install liblo-tools
for i in `seq 180`; do oscsend localhost 3030 /azi i $i; done


zack test write