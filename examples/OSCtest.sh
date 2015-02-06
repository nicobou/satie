#!/bin/bash

oscsend localhost 57120 /spatosc/core sss create boo PinkSin
sleep 5
oscsend localhost 57120 /spatosc/core sssf setProperty boo volume 0.5
sleep 3
oscsend localhost 57120 /spatosc/core sssf setProperty boo vol 0.1
sleep 3
oscsend localhost 57120 /spatosc/core ss delete boo
