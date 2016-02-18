#!/bin/bash

# will create a node using the "default" plugin

OSCPORT=18034

clear
sleep 2
oscsend localhost $OSCPORT /SATIE ss create default
oscsend localhost $OSCPORT /SATIE ss create synths
oscsend localhost $OSCPORT /SATIE/synths sss create pinko pinksin
echo "+ create sound instance pinko of type pinksin"
sleep 1
oscsend localhost $OSCPORT  /SATIE/synths/pinko ssfsf set gainDB -10 aziDeg 45
echo "  >> set pinko's volume to -30dB"
sleep 1
oscsend localhost $OSCPORT  /SATIE/synths/pinko s delete
sleep 1
echo "- delete sound instance pinko"
oscsend localhost $OSCPORT /SATIE/default sss create pinko pinksin
echo "+ create sound instance pinko of type pinksin"
oscsend localhost $OSCPORT  /SATIE/default/pinko ssf set gainDB -20
echo "  >> set pinko's volume to -30dB"
sleep 2
oscsend localhost $OSCPORT  /SATIE/default/pinko ssf set aziDeg -90
echo "  >> set pinko's azimuth to -90"
sleep 2
oscsend localhost $OSCPORT  /SATIE/default/pinko s delete
echo "- delete sound instance pinko"
sleep 1
oscsend localhost $OSCPORT /SATIE ss create strings
oscsend localhost $OSCPORT /SATIE/strings sss create pluck1 string
oscsend localhost $OSCPORT /SATIE/strings sss create pluck2 string 
echo "+ create sound instance pluck of type string"
sleep 1
oscsend localhost $OSCPORT  /SATIE/strings/pluck1 ssf set gainDB -10
oscsend localhost $OSCPORT  /SATIE/strings/pluck2 ssf set gainDB -5
oscsend localhost $OSCPORT  /SATIE/strings/pluck2 ssf set aziDeg 30
oscsend localhost $OSCPORT  /SATIE/strings/pluck1 ssf set note 65
oscsend localhost $OSCPORT  /SATIE/strings/pluck2 ssf set note 70

echo "  >> set string's volume to -30dB"
sleep 1
oscsend localhost $OSCPORT  /SATIE/strings ssf set t_trig 1
echo "  >> pluck the strings"

sleep 1
oscsend localhost $OSCPORT  /SATIE/strings/pluck1 ssf set aziDeg -90
echo "  >> set string1's azimuth to -90"
sleep 1
oscsend localhost $OSCPORT  /SATIE/srings ssf set t_trig 1
echo "  >> pluck the strings"
sleep 1
oscsend localhost $OSCPORT  /SATIE/strings/pluck2 ssfsf set aziDeg 90 t_trig 1 
echo "  >> pluck the string2 and set azimuth to 90 all at once"
sleep 1
oscsend localhost $OSCPORT  /SATIE/strings ssfsf set t_trig 1 
echo "  >> pluck the strings at once"
sleep 2
oscsend localhost $OSCPORT  /SATIE/strings s delete
echo "- delete group strings"
# group test
# oscsend localhost $OSCPORT /SATIE ss create strings
# audio file test
oscsend localhost $OSCPORT /SATIE ss create buffers
oscsend localhost $OSCPORT /SATIE/buffers sss create snd1 snd1 
oscsend localhost $OSCPORT /SATIE/buffers sss create snd2 snd2
oscsend localhost $OSCPORT /SATIE/buffers ssf set loop 1
echo "+ create buffers group, create 2 buffered sounds and loop them"
sleep 2
# jack input test
oscsend localhost $OSCPORT /SATIE ss create default
echo "+ create default group "
oscsend localhost $OSCPORT /SATIE/default sss create jackIn monoIn
echo " set mono in"
sleep 2
oscsend localhost $OSCPORT /SATIE/default/jackIn ssf set gainDB -10
echo " >> set gain to -10dB"
sleep 1
oscsend localhost $OSCPORT /SATIE/default/jackIn ssf set aziDeg -5
echo ">> set gain to -5dB"
sleep 1
oscsend localhost $OSCPORT /SATIE/default/jackIn ssf set aziDeg 90
echo " >> set audion input azimuth to 90"
# effects
# oscsend localhost $OSCPORT /SATIE ssss createSoundSource pluck string_all_aux strings
# oscsend localhost $OSCPORT /SATIE/strings/pluck ssf setInstance gainDB -20 note 62
# oscsend localhost $OSCPORT /SATIE/strings/pluck ssf setInstance t_trig 1
sleep 1
oscsend localhost $OSCPORT /SATIE ss create fx 
echo "create fx group"
oscsend localhost $OSCPORT /SATIE/fx sss create rev busreverb
slppe 1
oscsend localhost $OSCPORT /SATIE/fx/rev ssf set "in" 2
echo " ++ add a reverb to it"
oscsend localhost $OSCPORT /SATIE/fx/rev ssfsfsfsfsf set mix 0.7 room 0.8 damp 1 gainDB 0 aziDeg 10
echo " >> set reverb's params: in 2, mix 1 room size 0.9 damp 1 gain -1dB"
sleep 1 
oscsend localhost $OSCPORT /SATIE/strings/pluck ssfsf set gainDb -20 t_trig 1
echo "trigger the string with fx bus"
sleep 1
oscsend localhost $OSCPORT /SATIE ss create strings
oscsend localhost $OSCPORT /SATIE/strings sss create pluck string_third_aux
echo "+ create a plucked string with fx bus"
oscsend localhost $OSCPORT /SATIE/strings/pluck ssfsfsf set gainDB -10 note 62 aziDeg -60
echo " >> set its volume to -10dB and note to 62"
sleep 1
oscsend localhost $OSCPORT /SATIE/strings/pluck ssf set t_trig 1
echo " >> play it"

sleep 2
oscsend localhost $OSCPORT /SATIE/strings s delete
echo "delete strings group"
oscsend localhost $OSCPORT /SATIE s clear
echo "clear everyhting"
