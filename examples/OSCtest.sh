#!/bin/bash

oscsend localhost 57120 /spatosc/core sss create boo pink
sleep 5
oscsend localhost 57120 /spatosc/core sssf setProperty boo azi -0.7
oscsend localhost 57120 /spatosc/core sssf setProperty boo volume 0.5
sleep 3
oscsend localhost 57120 /spatosc/core sss create dust dust
oscsend localhost 57120 /spatosc/core sssf setProperty boo vol 0.1
sleep 1
oscsend localhost 57120 /spatosc/core sssf setProperty dust azi 0.9
sleep 2
oscsend localhost 57120 /spatosc/core sssf setProperty dust density1 20
oscsend localhost 57120 /spatosc/core sssf setProperty dust density2 400
sleep 3
oscsend localhost 57120 /spatosc/core ss delete boo
sleep 1
oscsend localhost 57120 /spatosc/core ss delete dust
