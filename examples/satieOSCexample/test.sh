#!/bin/bash

#  note: this is a satie4unity message protcol tester. In order to use, the protol must be active
#  to activete:
# in super collider:  ("sc-basic-renderer/examples/satie4UnityExample/main.scd").load; 


clear
sleep .2
echo  enable / disable the following for specific testing:
echo '#'BASIC_TEST=1
echo '#'PLUCK_TEST=1
echo '#'GROUP_TEST=1
echo '#'PROCESSING_TEST=1

BASIC_TEST=1
PLUCK_TEST=1
GROUP_TEST=1
PROCESSING_TEST=1

OSCPORT=18032
echo OSCPORT=18032

echo
# will create a node using the "default" plugin

oscsend localhost $OSCPORT /satie/scene s clear

if [ $BASIC_TEST ] ; then


echo TESTING BASIC SATIE4UNITY COMMANDS
sleep .3
oscsend localhost $OSCPORT /satie/scene sss createSource mySound plugin://default
echo CREATE SOURCE NODE mySound
sleep 1
echo send Update message  0 0 0 0  22050  10  : azi ele  gainDB del lpf distance
oscsend localhost $OSCPORT /satie/source/update sffffff mySound 0 0 0 0  22050  10 # azi ele  gainDB del lpf distance
sleep 1



echo PAN HARD LEFT  '('via update message')'
oscsend localhost $OSCPORT /satie/source/update sffffff mySound -90 -12 0 0  22050  10 # azi ele  gainDB del lpf distance
sleep 1

oscsend localhost $OSCPORT /satie/source/update sffffff mySound 90 0 3 0 22050 10 # azi ele  gainDB del lpf distance
echo PAN HARD RIGHT, GAIN = 3db
sleep 1

oscsend localhost $OSCPORT /satie/source/update sffffff mySound 0 0 0 0 22050 10 # azi ele  gainDB del lpf distance
echo PAN CENTER, GAIN = 0db
sleep 1

oscsend localhost $OSCPORT /satie/source/update sffffff mySound -45 0 -16 0 1000 10 # azi ele  gainDB del lpf distance
echo PAN LEFT. GAIN = -16db LPF = 1000
sleep 1

oscsend localhost $OSCPORT /satie/source/update sffffff mySound 0 0 -6 0 22050 10 # azi ele  gainDB del lpf distance
echo PAN CENTER, GAIN = -6, LPF = 22050
sleep 1

oscsend localhost $OSCPORT /satie/source/update sffffff mySound 45 0 -24 0 22050 10 # azi ele  gainDB del lpf distance
echo  PAN RIGHT, GAIN = -24db
sleep 1

oscsend localhost $OSCPORT /satie/source/set  ssf mySound spread 0
echo  SPREAD WIDE
sleep 1

oscsend localhost $OSCPORT /satie/source/set  ssf mySound  spread 2
echo  SPREAD NARROW
sleep 1

oscsend localhost $OSCPORT /satie/source/set  ssf mySound  spread 1
echo  SPREAD NORMAL
sleep 1

oscsend localhost $OSCPORT /satie/source/state  sf mySound  0
echo  STATE = 0
sleep 1

oscsend localhost $OSCPORT /satie/source/state  sf mySound   1
echo  STATE = 1
sleep 1

oscsend localhost $OSCPORT /satie/source/set ssf mySound lfoHz 3
echo  param:  lfoHz = 3
sleep 1

oscsend localhost $OSCPORT /satie/source/set ssf mySound lfoHz 20
echo  param:  lfoHz = 20
sleep 1

oscsend localhost $OSCPORT /satie/source/set ssf mySound lfoHz 2
echo  param:  lfoHz = 2
sleep 2

oscsend localhost $OSCPORT /satie/scene ss deleteNode mySound
echo  DELETE NODE SHEEFA
echo done
fi

if [ $PLUCK_TEST ] ; then

echo TESTING PLUCK
oscsend localhost $OSCPORT /satie/scene sss createSource mySound plugin://zkarpluck1
sleep 1

oscsend localhost $OSCPORT /satie/source/set ssf mySound gainDB -12

oscsend localhost $OSCPORT /satie/source/setvec ssff mySound note  76 .5 1
echo  SET NOTE VALUES: 76 .5 1 :  midiPitch  amp vel
oscsend localhost $OSCPORT /satie/source/set ssf mySound t_trig 1
echo  TRIGGER:  t_trig 1
sleep 1


oscsend localhost $OSCPORT /satie/source/set ssf mySound c1 2
oscsend localhost $OSCPORT /satie/source/set ssf mySound c3 10
echo  params:  c1 = 2,  c3 = 1
oscsend localhost $OSCPORT /satie/source/setvec ssff mySound note  72 .5 1
echo  SET NOTE VALUES: 72 .5 1 :  midiPitch  amp vel
oscsend localhost $OSCPORT /satie/source/set ssf mySound t_trig 1
sleep 1

oscsend localhost $OSCPORT /satie/source/set ssf mySound c3 1
oscsend localhost $OSCPORT /satie/source/set ssf mySound c1 .2
echo  param:  c1 = 0.2, c3 = 1
oscsend localhost $OSCPORT /satie/source/set ssf mySound fb 90
echo  param:  fb = 90
oscsend localhost $OSCPORT /satie/source/setvec ssff mySound note  78 .9 .8
echo  SET NOTE VALUES: 78 .9 .8 :  midiPitch  amp vel
oscsend localhost $OSCPORT /satie/source/set ssf mySound t_trig 1
sleep 4


oscsend localhost $OSCPORT /satie/scene ss deleteNode mySound
echo deleting node
fi



if [ $GROUP_TEST ] ; then

oscsend localhost $OSCPORT /satie/scene s clear
echo TESTING GROUP
echo creating group node and three source nodes

oscsend localhost $OSCPORT /satie/scene ss createGroup pluckGroup
oscsend localhost $OSCPORT /satie/scene ssss createSource source1 "plugin://zkarpluck1" pluckGroup
oscsend localhost $OSCPORT /satie/scene ssss createSource source2 "plugin://zkarpluck1" pluckGroup
oscsend localhost $OSCPORT /satie/scene ssss createSource source3 "plugin://zkarpluck1" pluckGroup
sleep .5
oscsend localhost $OSCPORT /satie/group/set ssf pluckGroup gainDB -18
echo setting group gainDB to -10
sleep .5


oscsend localhost $OSCPORT /satie/source/setvec ssff source1 note 65 1 1
oscsend localhost $OSCPORT /satie/source/set ssf source1 t_trig 1
echo triggering source1
sleep 1

oscsend localhost $OSCPORT /satie/source/setvec ssff source2 note 69 1 1
oscsend localhost $OSCPORT /satie/source/set ssf source2 t_trig 1
echo triggering source2
sleep 1

oscsend localhost $OSCPORT /satie/source/setvec ssff source3 note 72 1
oscsend localhost $OSCPORT /satie/source/set ssf source3 t_trig 1
echo triggering source3
sleep 2

oscsend localhost $OSCPORT /satie/group/set ssfsfsf pluckGroup c3 1 c1 .2 gainDB -24
echo  setpluckGroup param:  c1 = 0.2, c3 = 1, gainDB -24
sleep .2

oscsend localhost $OSCPORT /satie/group/set ssf pluckGroup t_trig 1
echo triggering sources 1,2,3
sleep 4


oscsend localhost $OSCPORT /satie/scene s clear

echo done

fi


if [ $PROCESSING_TEST ] ; then

oscsend localhost $OSCPORT /satie/scene s clear
echo TESTING PROCESSING_NODE
oscsend localhost $OSCPORT /satie/scene sf debugFlag 1
sleep 1

oscsend localhost $OSCPORT /satie/scene sss createProcess pNode1 "process://sheefa"
oscsend localhost $OSCPORT /satie/process/update sffffff pNode1 0 0 -10 0 22050  10 # azi ele  gainDB del lpf distance
oscsend localhost $OSCPORT /satie/process/set ssf pNode1 player 1
echo create and launch process
sleep 4
oscsend localhost $OSCPORT /satie/process/property ssf pNode1 cloneCount 1
echo setting clone count property to 1
sleep 3
oscsend localhost $OSCPORT /satie/process/property ssf pNode1 cloneCount 50
echo setting clone count property to 50
sleep 2
oscsend localhost $OSCPORT /satie/scene s clear

echo done

fi





















