#!/bin/bash


oscsend localhost 18032 /spatosc/core sss createSource boo pink
sleep 5
oscsend localhost 18032 /spatosc/core sssf setProperty boo azi -0.7
oscsend localhost 18032 /spatosc/core sssf setProperty boo volume 0.5
sleep 3
oscsend localhost 18032 /spatosc/core sss createSource dust dust
oscsend localhost 18032 /spatosc/core sssf setProperty boo vol 0.1
sleep 1
oscsend localhost 18032 /spatosc/core sssf setProperty dust azi 0.9
sleep 2
oscsend localhost 18032 /spatosc/core sssf setProperty dust density1 20
oscsend localhost 18032 /spatosc/core sssf setProperty dust density2 400
sleep 3
oscsend localhost 18032 /spatosc/core ss deleteNode boo
sleep 1
oscsend localhost 18032 /spatosc/core ss deleteNode dust
