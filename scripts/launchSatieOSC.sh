
# args:    PROJECT_NAME <opt> -f  listeningFormat {sato,labo}   otherwise defaults to stereo
# no args defaults to Satie4Unity example with stereo format


DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SUPERCOLLIDER_DIR=${DIR_PATH}/../..

if [ -z  $MY_IP ] ; then
$MY_IP=localhost
fi

echo
echo
echo "launching spatOSC audio renderer  (SATIE) on " $MY_IP":18032"
echo
echo


# echo DIRPATH=$DIR_PATH

#ls $SUPERCOLLIDER_DIR

#ls $SUPERCOLLIDER_DIR/sc-basic-renderer/examples/satie4UnityExample

#default loads example
LAUNCH_FILE=examples/satieOSCexample/main.scd


#number of input args
#if [ $# -eq  0 ]; then
#echo NO ARG, LOADING examples:  supercollider dir  $SUPERCOLLIDER_DIR
#LAUNCH_FILE=examples/satie4UnityExample/main.scd
#fi

if [ $# -eq  1 ] && [ $1 == "-h" ] ;    then
    echo $0 : usage: -f renderingFormat {sato, labo, defaults to stereo},  projectFilename
    exit
fi


if [ $# -eq  1 ] && [ $1 != "-f" ]  ;  then #must be a project name
    LAUNCH_FILE=projects/$1/main.scd
fi

if [ $# -eq  2 ] && [ $1 == "-f" ]  ;  then #must be a listening format
    LISTENING_FORMAT=$2
fi

if [ $# -eq  2 ] && [ $1 != "-f" ]  ;  then #not a listening format, and not a project name
    LISTENING_FORMAT=$2
    echo $0 : bad args: expecting: -f format  ,  exiting
    exit 1
fi


if [ $# -eq  3 ] && [ $2 == "-f" ]  ;  then #must be a project name
LAUNCH_FILE=projects/$1/main.scd
LISTENING_FORMAT=$3
fi


echo $SUPERCOLLIDER_DIR/supercollider/build/Install/SuperCollider/SuperCollider.app/Contents/MacOS/sclang $SUPERCOLLIDER_DIR/sc-basic-renderer/$LAUNCH_FILE $LISTENING_FORMAT

$SUPERCOLLIDER_DIR/supercollider/build/Install/SuperCollider/SuperCollider.app/Contents/MacOS/sclang $SUPERCOLLIDER_DIR/sc-basic-renderer/$LAUNCH_FILE $LISTENING_FORMAT

exit

