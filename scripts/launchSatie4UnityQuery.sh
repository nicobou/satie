
# Queries user for project and listening format before launching


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


read -p "Enter project name { or <cr> for default example}  : " PROJECT_NAME
read -p "Enter listening format {sato, labo, octo, quad, or <cr> for stereo} : " QUERY_LISTENING_FORMAT


// user specified project file
if [  -z $PROJECT_NAME ] ; then
    #default loads example with stereo listener
    LAUNCH_FILE=examples/satie4UnityExample/main.scd
else
    LAUNCH_FILE=projects/$PROJECT_NAME/main.scd
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



echo $SUPERCOLLIDER_DIR/supercollider/build/Install/SuperCollider/SuperCollider.app/Contents/MacOS/sclang $SUPERCOLLIDER_DIR/sc-basic-renderer/$LAUNCH_FILE $LISTENING_FORMAT

$SUPERCOLLIDER_DIR/supercollider/build/Install/SuperCollider/SuperCollider.app/Contents/MacOS/sclang $SUPERCOLLIDER_DIR/sc-basic-renderer/$LAUNCH_FILE $LISTENING_FORMAT

exit

