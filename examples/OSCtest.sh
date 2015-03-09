#!/bin/bash

# will create a node using the "default" plugin
clear
oscsend localhost 18032 /spatosc/core ss createSource sheefa
echo CREATE SOURCE NODE SHEEFA
sleep 1
oscsend localhost 18032 /spatosc/core sss connect sheefa myListener
echo CONNECT TO LISTENER
sleep 2
oscsend localhost 18032 "/spatosc/core/connection/sheefa->myListener/update" fffff -1 0 0 1 22050  # azi ele  gain del lpf
echo PAN LEFT
sleep 2
oscsend localhost 18032 "/spatosc/core/connection/sheefa->myListener/update" fffff 1 0 1 0 22050
echo PAN RIGHT
sleep 2
oscsend localhost 18032 "/spatosc/core/connection/sheefa->myListener/update" fffff 0 0 2 0 1000
echo GAIN = 2 LPF = 1000
sleep 2
oscsend localhost 18032 "/spatosc/core/connection/sheefa->myListener/update" fffff 0 0 -12 0 22050
echo GAIN = -12
sleep 2
oscsend localhost 18032 "/spatosc/core/connection/sheefa->myListener/update" fffff 0 0 1 0 22050
echo GAIN = 1
sleep 1
oscsend localhost 18032 "/spatosc/core/connection/sheefa->myListener/spread" f 0
echo SPREAD WIDE
sleep 1
oscsend localhost 18032 "/spatosc/core/connection/sheefa->myListener/spread" f 20
echo SPREAD NARROW
sleep 1
oscsend localhost 18032 "/spatosc/core/connection/sheefa->myListener/spread" f 1
echo SPREAD NORMAL
sleep 1
oscsend localhost 18032 /spatosc/core/source/sheefa/state f 0
echo STATE = 0
sleep 1
oscsend localhost 18032 /spatosc/core/source/sheefa/state f 1
echo STATE = 1
sleep 1
oscsend localhost 18032 /spatosc/core/source/sheefa/event sff noteOn 60 1  
echo NOTE ON = 1 60  : seconds midiPitch
sleep 1
oscsend localhost 18032 /spatosc/core/source/sheefa/event sff noteOn 76 .5
echo NOTE ON = 5 76  : seconds midiPitch
sleep 2
oscsend localhost 18032 /spatosc/core/source/sheefa/uri s plugin://pink
echo SET URI to  plugin://pink
sleep 3
oscsend localhost 18032 /spatosc/core/source/sheefa/prop sf sfreq 1000
echo PROP:  sfreq = 1000
sleep 1
oscsend localhost 18032 /spatosc/core/source/sheefa/prop sf sfreq 500
echo PROP:  sfreq = 500
sleep 1
oscsend localhost 18032 /spatosc/core/source/sheefa/uri s plugin://dust
echo SET URI to  plugin://dust
sleep 1
oscsend localhost 18032 /spatosc/core/source/sheefa/prop sf density1 20
echo PROP:  density1 = 20
sleep 3
oscsend localhost 18032 /spatosc/core/source/sheefa/prop sf density2 400
echo PROP:  density2 = 400
sleep 3
oscsend localhost 18032 /spatosc/core ss deleteNode sheefa
echo DELETE NODE SHEEFA
sleep 0
