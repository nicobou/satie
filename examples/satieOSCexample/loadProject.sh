#!/bin/bash

# takes an optional argument:   saterServer_IP_ADDR  (defaults to localhost)



IPADDR=$1


if [ -z $IPADDR ] ; then

read -p "Enter SATIE SERVER IP { or <cr> for localhost}  : " IPADDR

fi


if [  -z $IPADDR ] ; then
#default loads example with stereo listener
IPADDR=localhost
fi



PROJECTFILE="satieOSCexample.scd"

OSCPORT=18032

DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

FILENAME=${DIR_PATH}/$PROJECTFILE

echo $FILENAME

echo oscsend $IPADDR $OSCPORT /satie/load s ${FILENAME}

oscsend $IPADDR $OSCPORT /satie/load s ${FILENAME}

exit




















