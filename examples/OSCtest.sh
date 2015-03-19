#!/bin/bash

# will create a node using the "default" plugin
clear
oscsend localhost 18032 /spatosc/core ss createSource mySound
echo CREATE SOURCE NODE mySound
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/uri s plugin://default
echo SET DEFAULT PLUGIN
sleep 1
oscsend localhost 18032 /spatosc/core sss connect mySound ear
echo CONNECT TO LISTENER ear
sleep 1
oscsend localhost 18032 "/spatosc/core/connection/mySound->ear/update" fffff -3 0 10 0 22050  # azi ele  gain del lpf
echo PAN LEFT
sleep 2
oscsend localhost 18032 "/spatosc/core/connection/mySound->ear/update" fffff 0 0 10 0 22050  # azi ele  gain del lpf
echo PAN CENTER
sleep 2
oscsend localhost 18032 "/spatosc/core/connection/mySound->ear/update" fffff 3 0 10 0 22050  # azi ele  gain del lpf
echo PAN RIGHT
sleep 2
oscsend localhost 18032 "/spatosc/core/connection/mySound->ear/update" fffff 0 0 2 0 1000  # azi ele  gain del lpf
echo GAIN = 2 LPF = 1000
sleep 2
oscsend localhost 18032 "/spatosc/core/connection/mySound->ear/update" fffff 0 0 -12 0 22050  # azi ele  gain del lpf
echo GAIN = -12
sleep 2
oscsend localhost 18032 "/spatosc/core/connection/mySound->ear/update" fffff 0 0 1 0 22050  # azi ele  gain del lpf
echo GAIN = 1
sleep 1
oscsend localhost 18032 "/spatosc/core/connection/mySound->ear/spread" f 0
echo SPREAD WIDE
sleep 1
oscsend localhost 18032 "/spatosc/core/connection/mySound->ear/spread" f 20
echo SPREAD NARROW
sleep 1
oscsend localhost 18032 "/spatosc/core/connection/mySound->ear/spread" f 1
echo SPREAD NORMAL
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/state f 0
echo STATE = 0
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/state f 1
echo STATE = 1
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/event sff note  60 1
echo SET NOTE VALUES: 60 1  : midiPitch  amp
sleep .5
oscsend localhost 18032 /spatosc/core/source/mySound/event sf t_gate 1
echo TRIGGER NOTE
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/event sff note 76 .5
echo SET NOTE VALUES: 76 .5  :  midiPitch  amp
sleep .5
oscsend localhost 18032 /spatosc/core/source/mySound/event sf t_gate 1
echo TRIGGER NOTE
sleep 2
oscsend localhost 18032 /spatosc/core/source/mySound/uri s plugin://pink
echo 'SET URI to  plugin://pink'
sleep 3
oscsend localhost 18032 /spatosc/core/source/mySound/prop sf sfreq 1000
echo PROP:  sfreq = 1000
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/prop sf sfreq 500
echo PROP:  sfreq = 500
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/uri s plugin://dust
echo SET URI to  plugin://dust
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/prop sf density1 20
echo PROP:  density1 = 20
sleep 3
oscsend localhost 18032 /spatosc/core/source/mySound/prop sf density2 400
echo PROP:  density2 = 400
sleep 3
oscsend localhost 18032 /spatosc/core ss deleteNode mySound
echo DELETE NODE SHEEFA
sleep 1



oscsend localhost 18032 /spatosc/core ss createSource mySound
sleep 1
oscsend localhost 18032 /spatosc/core sss connect mySound ear
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/uri s plugin://zkarpluck1
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/event sf t_gate 1
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/prop sf c3 1
oscsend localhost 18032 /spatosc/core/source/mySound/event sff note 65 1
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/event sf t_gate 1
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/prop sf c3 80
oscsend localhost 18032 /spatosc/core/source/mySound/event sff note 75 1
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/prop sf amp 0.1
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/event sf t_gate 1
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/event sff note 55 1
oscsend localhost 18032 /spatosc/core/source/mySound/prop sf amp 1
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/event sf t_gate 1
sleep 1
oscsend localhost 18032 /spatosc/core s clear


oscsend localhost 18032 /spatosc/core ss createSource mySound
sleep 1
oscsend localhost 18032 /spatosc/core sss connect mySound ear
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/uri s plugin://zkarpluck0
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/event sff note 75 1
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/event sf t_gate 1
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/prop sf lpFq 2000
sleep
oscsend localhost 18032 /spatosc/core/source/mySound/event sf t_gate 1
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/prop sf outputDB 6
sleep 1
oscsend localhost 18032 /spatosc/core/source/mySound/event sf t_gate 1
sleep 1


oscsend localhost 18032 /spatosc/core/source/"sourceC:spatOSCsource_0"/prop sf lfoHz 20





