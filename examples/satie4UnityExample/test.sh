#!/bin/bash


BASIC_TEST=1
#PLUCK_TEST=1
#GROUP_TEST=1
#PROCESSING_TEST=1

OSCPORT=18032


# will create a node using the "default" plugin
clear

if [ $BASIC_TEST ] ; then

clear;
echo TESTING BASIC SATIE4UNITY COMMANDS
sleep 2

echo CREATE SOURCE NODE mySound
oscsend localhost $OSCPORT /spatosc/core sss createSource mySound plugin://default
sleep 2

#echo CREATE LISTENER NODE mySound
#LISTENER ALWAYS EXISTS, NO NEED TO CREATE
#oscsend localhost $OSCPORT /spatosc/core ss createListener ear
#sleep 2

echo CONNECT TO LISTENER ear
oscsend localhost $OSCPORT /spatosc/core sss connect mySound ear
sleep 1

echo PAN LEFT
oscsend localhost $OSCPORT "/spatosc/core/connection/mySound->ear/update" ffffff -1.57 0 -12 0 22050 0.5 # azi ele  gainDB del lpf
sleep 1

oscsend localhost $OSCPORT "/spatosc/core/connection/mySound->ear/update" ffffff 1.57 0 3 0 22050 0.5 # azi ele  gainDB del lpf
echo PAN RIGHT, GAIN = 3db
sleep 1
oscsend localhost $OSCPORT "/spatosc/core/connection/mySound->ear/update" ffffff 0 0 0 0 22050 0.5 # azi ele  gainDB del lpf
echo PAN CENTER, GAIN = 0db
sleep 1
oscsend localhost $OSCPORT "/spatosc/core/connection/mySound->ear/update" ffffff -.78 0 -16 0 1000 0.5 # azi ele  gainDB del lpf
echo PAN LEFT. GAIN = -16db LPF = 1000
sleep 1
oscsend localhost $OSCPORT "/spatosc/core/connection/mySound->ear/update" ffffff 0 0 -6 0 22050 0.5 # azi ele  gainDB del lpf
echo PAN CENTER, GAIN = -6, LPF = 22050
sleep 1
oscsend localhost $OSCPORT "/spatosc/core/connection/mySound->ear/update" ffffff .78 0 -24 0 22050 0.1 # azi ele  gainDB del lpf
echo  PAN RIGHT, GAIN = -24db
sleep 1
oscsend localhost $OSCPORT "/spatosc/core/connection/mySound->ear/spread" f 0
echo  SPREAD WIDE
sleep 1
oscsend localhost $OSCPORT "/spatosc/core/connection/mySound->ear/spread" f 20
echo  SPREAD NARROW
sleep 1
oscsend localhost $OSCPORT "/spatosc/core/connection/mySound->ear/spread" f 1
echo  SPREAD NORMAL
sleep 1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/state f 0
echo  STATE = 0
sleep 1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/state f 1
echo  STATE = 1
sleep 1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/uri s plugin://zkarpluck1
echo  'SET URI to  plugin://zkarpluck1'
sleep 1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/event sff note  60 1
echo  SET NOTE VALUES: 60 1  : midiPitch  amp
oscsend localhost $OSCPORT /spatosc/core/source/mySound/event sf t_trig 1
echo  TRIGGER NOTE
sleep 1
oscsend localhost $OSCPORT "/spatosc/core/connection/mySound->ear/update" ffffff 0 0 3 0 22050 0.1 # azi ele  gainDB del lpf
echo PAN CENTER, GAIN = 3db
sleep 1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/event sff note 76 .5
echo  SET NOTE VALUES: 76 .5  :  midiPitch  amp
oscsend localhost $OSCPORT /spatosc/core/source/mySound/event sf t_trig 1
echo  TRIGGER NOTE
sleep 1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/uri s plugin://pink
echo  'SET URI to  plugin://pink'
sleep 1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/prop sf sfreq 1000
echo  PROP:  sfreq = 1000
sleep 1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/prop sf sfreq 500
echo  PROP:  sfreq = 500
sleep 1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/uri s plugin://dust
echo  SET URI to  plugin://dust
sleep 1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/prop sf density1 20
echo  PROP:  density1 = 20
sleep 1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/prop sf density2 400
echo  PROP:  density2 = 400
sleep 1
oscsend localhost $OSCPORT /spatosc/core ss deleteNode mySound
echo  DELETE NODE SHEEFA
echo done
fi

if [ $PLUCK_TEST ] ; then

echo TESTING PLUCK
sleep 2


oscsend localhost $OSCPORT /spatosc/core sss createSource mySound plugin://zkarpluck1
sleep 1
oscsend localhost $OSCPORT /spatosc/core sss connect mySound ear
sleep 1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/uri s plugin://zkarpluck1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/event sf t_trig 1
sleep 2
oscsend localhost $OSCPORT /spatosc/core/source/mySound/prop sf c3 1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/event sff note 65 1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/event sf t_trig 1
sleep 2
oscsend localhost $OSCPORT /spatosc/core/source/mySound/prop sf c3 80
oscsend localhost $OSCPORT /spatosc/core/source/mySound/event sff note 75 1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/event sf t_trig 1
sleep 2
oscsend localhost $OSCPORT /spatosc/core/source/mySound/prop sf amp 0.1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/event sf t_trig 1
sleep 2
oscsend localhost $OSCPORT /spatosc/core/source/mySound/event sff note 55 1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/prop sf amp 1
oscsend localhost $OSCPORT /spatosc/core/source/mySound/event sf t_trig 1
sleep 4
oscsend localhost $OSCPORT /spatosc/core s clear
echo done

fi



if [ $GROUP_TEST ] ; then

clear
echo TESTING GROUP
sleep 2

oscsend localhost $OSCPORT /spatosc/core ss createGroup pluckGroup
oscsend localhost $OSCPORT /spatosc/core ssss createSource source1 "plugin://zkarpluck1" pluckGroup
oscsend localhost $OSCPORT /spatosc/core sss connect source1 ear
oscsend localhost $OSCPORT /spatosc/core/source/source1/event sff note 65 1

oscsend localhost $OSCPORT /spatosc/core ssss createSource source2 "plugin://zkarpluck1" pluckGroup
oscsend localhost $OSCPORT /spatosc/core sss connect source2 ear
oscsend localhost $OSCPORT /spatosc/core/source/source2/event sff note 69 1


oscsend localhost $OSCPORT /spatosc/core ssss createSource source3 "plugin://zkarpluck1" pluckGroup
oscsend localhost $OSCPORT /spatosc/core sss connect source3 ear
oscsend localhost $OSCPORT /spatosc/core/source/source3/event sff note 72 1





#oscsend localhost $OSCPORT /spatosc/core/source/source1/prop sf c3 1
#oscsend localhost $OSCPORT /spatosc/core/source/source1/event sff note 65 1
sleep .5
oscsend localhost $OSCPORT /spatosc/core/group/pluckGroup/event sf t_trig 1
sleep 1
oscsend localhost $OSCPORT /spatosc/core/group/pluckGroup/event sf t_trig 1
sleep 1



oscsend localhost $OSCPORT /spatosc/core s clear

echo done

fi


if [ $PROCESSING_TEST ] ; then

clear
echo TESTING PROCESSING_NODE
oscsend localhost $OSCPORT /spatosc/core s clear
sleep 2

oscsend localhost $OSCPORT /spatosc/core sss createSource pNode1 "process://sheefa"
oscsend localhost $OSCPORT /spatosc/core sss connect pNode1 ear
oscsend localhost $OSCPORT /spatosc/core/source/pNode1/event sffff setup 10 20 10 1    #cloneCount randAzi randElev randDist
sleep 1
oscsend localhost $OSCPORT "/spatosc/core/connection/pNode1->ear/update" fffff -1.57 0 -12 0 22050  # azi ele  gainDB del lpf
echo PAN LEFT
sleep .5
oscsend localhost $OSCPORT "/spatosc/core/connection/pNode1->ear/spread" f 10  # spread value
sleep .5
oscsend localhost $OSCPORT /spatosc/core/source/pNode1/event ssf setParam cloneCount 33    #set a value in the process
echo SET PROCESS PROPERTY
sleep .5
oscsend localhost $OSCPORT /spatosc/core/source/pNode1/prop sf hpfq 4000
sleep .5
echo SET SYNTH NAME
oscsend localhost $OSCPORT /spatosc/core/source/pNode1/event sss setParam synthName zkarpluck1
sleep .5
echo TRIGGER
oscsend localhost $OSCPORT /spatosc/core/source/pNode1/event s trigger




echo done

fi





















