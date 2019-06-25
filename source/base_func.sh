

##############################################################################
#
#      Function : MakeDir
#    Parameters :
#        Output :
#         Notes :
#
##############################################################################

function MakeDir
{
    myDir="$1"

    if [ ! -d $myDir ] ; then
        $MKDIR -p $myDir
        if [ $? -ne 0 ] ; then
            echo "ERROR: Creating directory $LOGDIR"
            exit 1
        fi
    else
        $CHMOD 750 $myDir
    fi
}


##############################################################################
#
#      Function : Echo
#    Parameters : String to display what function is about to run
#        Output : Print what section we are about to collect data for
#         Notes : N/A
#
##############################################################################

function Echo ()
{

    if [ -t 0 ] ; then

        if [ ${VERBOSE} -ne 0 ] ; then
            echo "[*] $*"
            echo "============================================="
            sleep 1
        fi

        if [ ${VERBOSE} -gt 1 ] ; then
            echo "Press Return to Continue.........."
            read A
        fi
    fi
}


##############################################################################
#
#      Function : mywhich
#
#    Parameters : name of program
#
#        Output : path of executable
#
#         Notes : Return back the location of the executable
#         I need this as not all linux distros have the files
#         in the same location.
#
##############################################################################

function mywhich ()
{

    local command="$1"

    if [  "$command" =  "" ] ; then
        return
    fi

    local mypath=$(which $command 2>/dev/null)

    if [  "$mypath" =  "" ];then
        echo "Command $command not found" > /dev/null
        echo "NOT_FOUND"

    elif [ ! -x "$mypath" ] ; then
        echo "Command $command not executable" > /dev/null
        echo "NOT_FOUND"
    else
        echo "$mypath"
    fi

}


##############################################################################
#
#      Function : RemoveDir
#    Parameters : None
#        Output : None
#         Notes : Remove directories
#
##############################################################################

function RemoveDir
{

    local myDIR=$1

    if [ -d "$myDIR" ] ; then
            if [[ "${myDIR}" != "/" && \
            "${myDIR}" != "/var" && \
            "${myDIR}" != "/usr"  && \
            "${myDIR}" != "/home" ]] ; then

            if [ ${VERBOSE} -gt 0 ] ; then
                    Echo "Removing Old Directory : ${myDIR}"
            fi

            $RM -rf ${myDIR}
        fi
    fi

}


##############################################################################
#
#      Function : findCmds
#
#    Parameters : None
#
#        Output : None
#
#         Notes :       Goes and find each of the commands I want to use and
#           stores the information into the various variables which
#           is the uppercase version of the command itself.
#
#           I need this as not all linux distros have the files
#           in the same location.
#
##############################################################################

function findCmds
{

    if [ ${VERBOSE} -gt 0 ] ; then
        echo "[*] Section - Finding Commands"
        echo "============================================="
    fi

   #standard commands

            AWK=$(mywhich awk       )
       BASENAME=$(mywhich basename  )
            CAT=$(mywhich cat       )
      CHKCONFIG=$(mywhich chkconfig )
             CP=$(mywhich cp        )
            CUT=$(mywhich cut       )
          CHMOD=$(mywhich chmod     )
           DATE=$(mywhich date      )
             DF=$(mywhich df        )
            SED=$(mywhich sed       )
         COLUMN=$(mywhich column    )
          DMESG=$(mywhich dmesg     )
           ECHO=$(mywhich echo      )
           FILE=$(mywhich file      )
           FIND=$(mywhich find      )
           FREE=$(mywhich free      )
           GREP=$(mywhich grep      )
          EGREP=$(mywhich egrep     )
             LS=$(mywhich ls        )
    LSB_RELEASE=$(mywhich lsb_release )
             LN=$(mywhich ln        )
          MKDIR=$(mywhich mkdir     )
           LAST=$(mywhich last      )
         LOCALE=$(mywhich locale    )
         PSTREE=$(mywhich pstree    )
             PS=$(mywhich ps        )
             RM=$(mywhich rm        )
          SLEEP=$(mywhich sleep     )
      SYSTEMCTL=$(mywhich systemctl )
          MOUNT=$(mywhich mount     )
         MD5SUM=$(mywhich md5sum    )
             MV=$(mywhich mv        )
            SAR=$(mywhich sar       )
           SORT=$(mywhich sort      )
           TAIL=$(mywhich tail      )
          UNAME=$(mywhich uname     )
         UPTIME=$(mywhich uptime    )
            WHO=$(mywhich who       )
            ZIP=$(mywhich zip       )
           GZIP=$(mywhich gzip      )
           GAWK=$(mywhich gawk      )
            SED=$(mywhich sed       )
         GUNZIP=$(mywhich gunzip    )
           UNIQ=$(mywhich uniq      )
             WC=$(mywhich wc        )
           HEAD=$(mywhich head      )

   # Packages
      APTCONFIG=$(mywhich apt-config   )
            RPM=$(mywhich rpm          )
            APTGET=$(mywhich apt-get        )
         ZYPPER=$(mywhich zypper       )
           DPKG=$(mywhich dpkg         )
     DPKG_QUERY=$(mywhich dpkg-query   )
            YUM=$(mywhich yum          )
         PACMAN=$(mywhich pacman       )
         PIDSTAT=$(mywhich pidstat     )
         MPSTAT=$(mywhich mpstat       )
           FREE=$(mywhich free         )
            SAR=$(mywhich sar          )
           CURL=$(mywhich curl         )
            AWK=$(mywhich awk          )
           UNIQ=$(mywhich uniq         )
           NMAP=$(mywhich nmap         )

   # Kernel Info
         SYSCTL=$(mywhich sysctl       )

    # H/W Info
      DMIDECODE=$(mywhich dmidecode    )
          FDISK=$(mywhich fdisk        )
          BLKID=$(mywhich blkid        )
       HOSTNAME=$(mywhich hostname     )
         HWINFO=$(mywhich hwinfo       )
          LSBLK=$(mywhich lsblk        )
          LSUSB=$(mywhich lsusb        )
          LSDEV=$(mywhich lsdev        )
          MDADM=$(mywhich mdadm        )
       PROCINFO=$(mywhich procinfo     )
       SMARTCTL=$(mywhich smartctl     )
         SFDISK=$(mywhich sfdisk       )
           NTPQ=$(mywhich ntpq         )
        NTPDATE=$(mywhich ntpdate      )
         SWAPON=$(mywhich swapon       )
            PVS=$(mywhich pvdisplay    )
            VGS=$(mywhich vgdisplay    )
            LVS=$(mywhich vgdisplay    )

    # Network
       IFCONFIG=$(mywhich ifconfig     )
        NETSTAT=$(mywhich netstat      )
          ROUTE=$(mywhich route        )
             IP=$(mywhich ip           )
       IPTABLES=$(mywhich iptables     )
        ETHTOOL=$(mywhich ethtool      )
            ARP=$(mywhich arp          )
           PING=$(mywhich ping         )
     TRACEROUTE=$(mywhich traceroute   )

    # Tuning
         IOSTAT=$(mywhich iostat       )
         VMSTAT=$(mywhich vmstat       )
       MODPROBE=$(mywhich modprobe     )

    # Other
       RUNLEVEL=$(mywhich runlevel     )
           LSOF=$(mywhich lsof         )
            TAR=$(mywhich tar          )

}

##############################################################################
#
#      Function : taritup_info
#    Parameters :
#        Output :
#         Notes : tar up all the files that are going to be sent to support
#
##############################################################################

function taritup_info
{
    Echo "Section - tar"

    if [ "$CWDIR" != "" ] ; then
        cd $CWDIR
    else
        cd $LOGDIR
    fi

    $TAR czf ${TARFILE} . > /dev/null 2>&1

    if [ $? -ne 0 ] ; then

        if [ -x $LOGGER ] ; then
            $LOGGER -s "[ERROR]: creating the linux-explorer $TARFILE"
        else
            echo "[ERROR]: creating the linux-explorer $TARFILE"
        fi

        exit 1
    fi

     if [ -t 0 ] ; then

        Sum=$(echo ${TARFILE} | $AWK -F "/" '{print $4}' )
        echo " 1. The Support File is : ${TARFILE}"
    fi
}



##############################################################################
#
#      Function : mantis_up
#    Parameters :
#        Output :
#         Notes : Upload tar file to Mantis
#
##############################################################################

function mantis_up {

   ncplogs=$(base64 -w 0 $TARFILE)
   tmp_file=$(mktemp)

    $CAT > $tmp_file <<EOF
    {
       "summary": ".",
       "description": ".",
       "category": {
           "id": 2,
           "name": "linux"
       },
       "project": {
           "id": 1,
           "name": "VM Performance Analysis"
       },
       "custom_fields": [
           {
               "field": {
                   "id":1,
                   "name":"NCPAccountID"
                },
               "value":"$ID"
           },
           {
               "field": {
                   "id":5,
                   "name":"HostName"
               },
               "value":"$MYHOSTNAME"
            }
       ],
       "files": [
             {
                 "name": "$Sum",
                 "content": "${ncplogs}"
             }
        ]
    }
EOF

#    TID=$($CURL --location --request POST "http://106.10.59.135/api/rest/issues/" \
#                --header "Authorization: po8rXayfA-1_N8Sd5wBlYypiWg45RVhi" \
#                --header "Content-Type: application/json" \
#                --data @$tmp_file | $AWK 'match($0,/\"id\":([0-9]+)/,a){print a[1]}')

    TID=$($CURL -s --location --request POST "http://106.10.59.135/api/rest/issues/" \
        --header "Authorization: po8rXayfA-1_N8Sd5wBlYypiWg45RVhi" \
        --header "Content-Type: application/json" --data @$tmp_file \
        | $SED 's/\\\\\//\//g' | $SED 's/[{}]//g' | $AWK -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' \
        | $SED 's/\"\:\"/\|/g' | $SED 's/[\,]/ /g' | $SED 's/\"//g' | $GREP 'issue|id' | $AWK -F ":" '{print $2}')

	echo " 2. The Ticket ID is : $TID"
	echo
    $RM -f $tmp_file > /dev/null 2>&1
}

##############################################################################
#
#      Function : copy_etc
#    Parameters :
#        Output :
#         Notes : Make a copy of the /etc directory so that we have all files
#
##############################################################################

function copy_etc
{
    Echo "Section - Copy etc"

    if [ ! -d ${LOGDIR}/etc ]; then
        MakeDir ${LOGDIR}/etc
    fi

    $CP -Rp /etc/* ${LOGDIR}/etc

    if [ -f ${LOGDIR}/etc/shadow ] ; then
        $RM -f ${LOGDIR}/etc/shadow
    fi

    if [ -f ${LOGDIR}/etc/shadow- ] ; then
        $RM -f ${LOGDIR}/etc/shadow-
    fi

    if [ -f ${LOGDIR}/etc/passwd ] ; then
        $RM -f ${LOGDIR}/etc/passwd
    fi

    if [ -f ${LOGDIR}/etc/passwd- ] ; then
        $RM -f ${LOGDIR}/etc/passwd-
    fi
}


# move the SUMMARY.txt file to $LOGDIR
function summary_move
{
    if [ -f /tmp/SUMMARY.txt ]; then
        $MV -f  /tmp/SUMMARY.txt ${LOGDIR}/SUMMARY.txt
    fi
 }


##############################################################################
#
#      Function : myselection
#    Parameters :
#        Output :
#         Notes :
#
##############################################################################

function myselection
{

    case $1 in

    disks)     Echo "You have selected \"disks\" "
               # filename : disk_func.sh
               disk_info
               ;;

    logs)      Echo "You have selected \"logs\" "
               # filename : log_func.sh
               system_logs_info
               ;;

    network)   Echo "You have selected \"network\" "
               # filename : net_func.sh
               network_function
               ;;

    all|*)     Echo "You have selected \"ALL\" "
               # filename : disk_func.sh
               disk_info

               # filename : log_func.sh
               system_logs_info

               # filename : net_func.sh
               network_info

               # filename : performance_func.sh
               performance_info

               # filename : time_func.sh
               time_info
               ;;
    esac
}

##############################################################################
#
#      Function : Usage
#
#         Notes : N/A
#
##############################################################################

function ShowUsage
{

        #-------------------------------------------------------------------
        #   Show help message
        #-------------------------------------------------------------------

    echo
    echo "$MYNAME Version $MYVERSION - $COPYRIGHT "
    echo
    echo "  usage:   ./$MYNAME [option] "
    echo
    echo "      -d      Target directory for explorer files"
    echo "      -k      Remove all the files tared up "
    echo "      -t      [logs] [disks] [network] [all]"
    echo "      -v      Verbose output"
    echo "      -h      This help message"
    echo "      -V      Version Number of NAVER CLOUD PLATFORM Scripts"
    echo "      -l      light option"
    echo
    exit 1
}

function OsCheck
{

    # OS : Ubuntu / CentOS
    if [ -f /etc/os-release ]; then
       OS_CHK=$($CAT /etc/os-release | $GREP NAME | $HEAD -n 1 | $AWK -F "\"" '{print $2}' | $AWK '{print $1}')
    elif [ -f /etc/centos-release ]; then
       OS_CHK=$($CAT /etc/centos-release | $AWK '{print $1}')
    else
       OS_CHK="Unknown OS"
    fi
}

function PkgCheck {

    Echo "Section - System Package Check"

    if [ "$OS_CHK" == "Ubuntu" ]; then
        if [ "$TRACEROUTE" == "NOT_FOUND" ]; then
            $APTGET install traceroute -y > /dev/null 2>&1
            echo "  1. traceroute installation complete"
            TRACEROUTE=$(mywhich traceroute)
        else
            echo "  1. traceroute found"

        fi

        if [ "$NMAP" == "NOT_FOUND" ]; then
            $APTGET install nmap -y > /dev/null 2>&1
            echo "  2. nmap installation complete"
            NMAP=$(mywhich nmap)
        else
            echo "  2. nmap found"
        fi

        if [ "$SAR" == "NOT_FOUND" ]; then
            $APTGET install sysstat -y > /dev/null 2>&1
            echo "  3. sysstat installation complete"
            SAR=$(mywhich sar)
            PIDSTAT=$(mywhich pidstat)
            MPSTAT=$(mywhich mpstat)
        else
            echo "  3. sysstat found"
        fi

    elif [ "$OS_CHK" == "CentOS" ]; then
       if [ "$TRACEROUTE" == "NOT_FOUND" ]; then
           $YUM install traceroute -y > /dev/null 2>&1
           echo "  1. traceroute installation complete"
           TRACEROUTE=$(mywhich traceroute)
       else
           echo "  1. traceroute found"

       fi

       if [ "$NMAP" == "NOT_FOUND" ]; then
            $YUM install -y nmap > /dev/null 2>&1
            echo "  2. nmap installation complete"
            NMAP=$(mywhich nmap)
        else
            echo "  2. nmap found"
        fi

        if [ "$SAR" == "NOT_FOUND" ]; then
            $YUM install sysstat -y > /dev/null 2>&1
            echo "  3. sysstat installation complete"
            SAR=$(mywhich sar)
            PIDSTAT=$(mywhich pidstat)
            MPSTAT=$(mywhich mpstat)
        else
            echo "  3. sysstat found"
         fi
    else
        echo "  1. I have found all the packages for checking the status of the network"
    fi
    echo
}
