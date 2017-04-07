
# args:   optiontal flags:
#       -f  listeningFormat {sato,labo}   (default == stereo)
#       -b  effects bus count   (default == 4)
# no args defaults to stereo format


DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SUPERCOLLIDER_DIR=${DIR_PATH}/../..

if [ -z  $MY_IP ] ; then
$MY_IP=localhost
fi

echo
echo
echo "booting SATIE on " $MY_IP":18032"
echo
echo


# echo DIRPATH=$DIR_PATH


LAUNCH_FILE=prototype/bootSatie.scd


# note: if this is set to -gt 0 the /etc/hosts part is not recognized ( may be a bug )

if [ $# -eq  1 ] && [ $1 == "-h" ] ;    then
echo $0 : "optional flags: -f or -listenerFormat  {sato, labo, stereo, octo, mono, 5one} (default == stereo)"
exit
fi


AUXBUSCOUNT=4
LISTENING_FORMAT="stereo"

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
-f|--LISTENERFORMAT)
LISTENING_FORMAT="$2"
shift # past argument
;;
--default)
DEFAULT=YES
;;
*)
# unknown option
;;
esac
shift # past argument or value
done
echo LISTENER FORMAT     = "${LISTENING_FORMAT}"



echo $SUPERCOLLIDER_DIR/supercollider/build/Install/SuperCollider/SuperCollider.app/Contents/MacOS/sclang $SUPERCOLLIDER_DIR/sc-basic-renderer/$LAUNCH_FILE $LISTENING_FORMAT

$SUPERCOLLIDER_DIR/supercollider/build/Install/SuperCollider/SuperCollider.app/Contents/MacOS/sclang $SUPERCOLLIDER_DIR/sc-basic-renderer/$LAUNCH_FILE $LISTENING_FORMAT

exit

