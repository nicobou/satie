
# Queries user for project and listening format before launching


DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"



DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

OS=`uname -s`

SATIE_DIR=${DIR_PATH}/..



#  if  $SUPERCOLLIDER poins to a  sclang executable, it will be called, otherwise will launch using default path to sclang


if [ "$OS" = "Darwin" ]; then
if [ -z  $SUPERCOLLIDER ]  ; then
SUPERCOLLIDER_APP=${DIR_PATH}/Applications/SuperCollider.app/Contents/MacOS/sclang
echo bootSatie.sh:  guessing that supercollider is at:  $SUPERCOLLIDER_APP

else
SUPERCOLLIDER_APP=$SUPERCOLLIDER/Contents/MacOS/sclang
fi
fi


if [ "$OS" = "Linux" ]; then
if [ -z  $SUPERCOLLIDER ]  ; then
SUPERCOLLIDER_APP=/use/local/bin/sclang
echo bootSatie.sh:  guessing that supercollider is at:  $SUPERCOLLIDER_APP

else
SUPERCOLLIDER_APP=$SUPERCOLLIDER
fi
fi



LAUNCH_FILE=prototype/bootSatie.scd



if [ -z  $MY_IP ] ; then
$MY_IP=localhost
fi

echo
echo
echo "launching spatOSC audio renderer  (SATIE) on " $MY_IP":18032"
echo
echo

LISTENING_FORMAT=$1

if [ -z $LISTENING_FORMAT ] ; then

read -p "Enter listening format {sato, labo, octo, quad, 5one, or <cr> for currentConfig} : " QUERY_LISTENING_FORMAT

fi



case $QUERY_LISTENING_FORMAT in
sato)
    LISTENING_FORMAT=sato
    ;;
labo)
    LISTENING_FORMAT=labo
    ;;
octo)
    LISTENING_FORMAT=octo
;;
quad)
    LISTENING_FORMAT=quad
;;
5one)
LISTENING_FORMAT=5one
;;
"" )
    echo setting to stereo
#  do not set LISTENING_FORMAT,  satie4Unity will check environment var for listening format
;;
*)
echo format not recoginized, setting to stereo
LISTENING_FORMAT=stereo
;;
esac

echo "LAUNCH_FILE : $LAUNCH_FILE"
echo "LISTENING_FORMAT : $LISTENING_FORMAT"



echo $SUPERCOLLIDER_APP $SATIE_DIR/$LAUNCH_FILE $LISTENING_FORMAT

$SUPERCOLLIDER_APP $SATIE_DIR/$LAUNCH_FILE $LISTENING_FORMAT


exit

