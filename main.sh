###########################################################################
# First run function
# find ALL my commands for this script
echo
Echo "Starting gathering process."

# filename : first.sh
fist_check

# filename : base_func.sh
findCmds

# Check OS type
OsCheck
Echo "Check OS type : $OS_CHK"

# System Package Check
PkgCheck
###########################################################################

###########################################################################
# Remove any temporary files we create
trap '$RM -f $TMPFILE >/dev/null 2>&1; exit' 0 1 2 3 15

# remove the previous files ( including the tar files ) in $LOGDIR
# filename : base_func.sh
RemoveDir ${LOGTOP}

# make the directory I'm going to store all the files
if [ ! -d $LOGDIR ] ; then
    MakeDir $LOGDIR
fi
###########################################################################


###########################################################################
# Aggreement
# filename : user_func.sh
user

# ncp vm system check summary
# filename : ncp_func.sh
ncp_instance_Info
###########################################################################

while getopts ":d:t:v:s:hVl" OPT
do
    case "$OPT" in
        d)  if [ $OPTARG = "/" ] ; then
                echo "ERROR: root directory selected as target! "
                echo "Exiting."
                exit 1

            elif [ $OPTARG != "" ] ; then
                TOPDIR=${OPTARG}
                echo "DEBUG: TOPDIR <$TOPDIR>"
                CWDIR=$(pwd)
            fi
            ;;

        t)  CHECKTYPE="$OPTARG"
            ;;

        v)  VERBOSE="1"
            ;;

        h)  ShowUsage
            ;;

        l)  LIGHT="1"
            ;;

        V)
            echo
            echo "NAVER CLOUD PLATFORM Scripts Version : $MYVERSION"
            echo
            exit 0
            ;;
    esac
done

if [ "$LIGHT" -ne 0 ] ; then
    # filename : ncp_func.sh
    summary_create

    # filename : base_func.sh
    summary_move
    taritup_info

    # filename : mantis_func.sh
    mantis_up
else
    # filename : base_func.sh
    summary_move
    myselection "$CHECKTYPE"
    copy_etc
    taritup_info

    # filename : mantis_func.sh
    mantis_up
fi

# Remove all the files tared up in $LOGDIR ( except tar file )
RemoveDir ${LOGDIR}

Echo "Completed gathering process."
echo

exit 0
