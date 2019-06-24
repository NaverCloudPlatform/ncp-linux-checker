#!/bin/bash

##############################################################################
#
#
# FILE             : ncp.checker.sh
# Last Change Date : 05-17-2019
# Author(s)        :
# Email            :
# Web              :
#
# Usage            : ./ncp.checker.sh [option]
#                       -d      Target directory for explorer files
#                       -t      [logs] [disks] [network] [all]
#                       -h      This help message
#                       -V      Version Number of NCP Checker Scripts
#                       -l      light option
#
##############################################################################
#
# Purpose   : This script is a linux version
#
#           Used to collect information about a linux system build for
#           remote support purposes.
#           This script is applicable to centOS and ubuntu Linux
#
##############################################################################

MYVERSION="1.4"
LICENSE="GLPv2"
MYDATE="$(/bin/date +'%Y%m%d')" # Date and time now
MYDATE1="$(/bin/date +'%Y/%m/%d %H:%M:%S')" # Date and time now
MYNAME=$(basename $0)
WHOAMI=$(/usr/bin/whoami)       # The user running the script
HOSTID=$(/usr/bin/hostid)       # The Hostid of this server
MYHOSTNAME=$(/bin/uname -n)     # The hostname of this server
ARCH=$(/bin/uname -s)
MYSHORTNAME=$(echo $MYHOSTNAME | cut -f 1 -d'.')
SYSTEMPLATFORM=$(uname -m)
KERNELVERSION=$(uname -r)
TMPFILE="/tmp/$(basename $0).$$"    # Tempory File
TOPDIR="/opt"       # Top level output directory
LOGTOP="${TOPDIR}/ncp_vmcheck"
LOGDIR="${LOGTOP}/ncp_${MYSHORTNAME}_${MYDATE}"
TARFILE="${LOGDIR}.tar.gz"
PKGDIR="$TOPDIR/vmcheck_$MYVERSION"
CHECKTYPE=""                # Nothing selected
CWDIR=""                #
VERBOSE=1               # Set to see the scripts progress used only if connected  to a terminal session.
FULLSOFT=0              # Set to Verify Software installation this takes a very long time
LIGHT=0                 # light version , only system summary result printed , file name : SUMMARY.txt
KEEPFILES="0"           # Default to remove files created by this script
unset GZIP              # Ensure that GZIP is unset for later use.

 # Set the path for the script to run.
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:$PATH
export PATH



function fist_check {
    Echo "First system check"
    echo "  1. make sure this is a linux system"
    if [ "$ARCH" != "Linux" ] ; then
        echo "    - ERROR: This script is only for Linux systems"
        exit 1
    else
        echo "    - Linux"
    fi

    echo "  2. Ensure that we are the root user"
    if [ ${UID} -ne 0 ] ; then
        echo "    - ERROR: Sorry only the root user can run this script"
        exit 1
    else
        echo "    - root user"
    fi

    echo "  3. check disk usage"
    ROOTDEV=$(df -h / | grep dev | awk '{print $1}')
    USAGE=$(df -h | grep $ROOTDEV | awk '{print $5}' | awk -F "%" '{print $1}')

    if [ ${USAGE} -ge 90 ]; then
        echo "    - Disk usage is ${USAGE}%"
        echo "    - Please free disk space. Abort!"
        exit 1
    else
        echo "    - Disk usage is ${USAGE}%"
        echo "    - vmcheck script can be tested"
    fi
    echo
}


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


function ncp_instance_Info {

    Echo "Section - NCP Instance information "

   echo "" >> /tmp/SUMMARY.txt 2>&1
   echo "  ----------------------------------------------------------------------------" >> /tmp/SUMMARY.txt 2>&1
   echo "  INSTANCE PERFORMANCE INFORMATION" >> /tmp/SUMMARY.txt 2>&1
   echo "  ----------------------------------------------------------------------------" >> /tmp/SUMMARY.txt 2>&1

   $CURL -s -H Metadata:true http://metadata.ntruss.com/v1.0/serverInstance\
   | $SED -e 's/[{}]/''/g'\
   | $AWK -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | $GREP -vi userdata\
   | $SED 's/"//g' | $AWK -F ':' '{print $1 " : " $2}' | $SED 's/^/  /' >> /tmp/SUMMARY.txt 2>&1

   echo "  ----------------------------------------------------------------------------" >> /tmp/SUMMARY.txt 2>&1

}



function summary_create {
    Echo "Simple resource collection"

cat << EOF >> /tmp/SUMMARY.txt

  ----------------------------------------------------------------------------
  1. Uptime:
      It is the load average value at 1 minute, 5 minutes and 15 minutes,
      If this value is large, then there is probably a problem with CPU demand.

EOF
    echo "  1. Uptime"
    ${UPTIME}| $SED 's/^/   /' >> /tmp/SUMMARY.txt 2>&1

cat << EOF >> /tmp/SUMMARY.txt

  ----------------------------------------------------------------------------
  2 dmesg | tail :
      check system messages,  last 10 lines.

EOF
    echo "  2. dmesg"
    $DMESG | $TAIL | $SED '1d' | $COLUMN -t | $SED 's/^/   /'  >> /tmp/SUMMARY.txt 2>&1


cat << EOF >> /tmp/SUMMARY.txt

  ----------------------------------------------------------------------------
  3 swapon -s:
      Large swap memory can reduce application speed

EOF

    echo "  3. swapon -s"
    $SWAPON -s | $GREP -v "Filename" | $SED 's/^/   /' >> /tmp/SUMMARY.txt 2>&1


cat << EOF >> /tmp/SUMMARY.txt

  ----------------------------------------------------------------------------
  4. vmstat 1 5:
      virtual memory stat

EOF
    echo "  4. vmstat"
    $VMSTAT 2 5 | $SED '1d' | $COLUMN -t | $SED 's/^/   /'  >> /tmp/SUMMARY.txt 2>&1

cat << EOF >> /tmp/SUMMARY.txt

  ----------------------------------------------------------------------------
  5. mpstat -P ALL:
      CPU time measured by CPU

EOF
    echo "  5. mpstat"
    $MPSTAT -P ALL | $SED 's/^/   /' >> /tmp/SUMMARY.txt 2>&1

cat << EOF >> /tmp/SUMMARY.txt

  ----------------------------------------------------------------------------
  6. pidstat :
      Process that occupies CPU excessively

EOF
    echo "  6. pidstat"
    $PIDSTAT | $SED 's/^/   /' >> /tmp/SUMMARY.txt 2>&1

cat << EOF >> /tmp/SUMMARY.txt

  ----------------------------------------------------------------------------
  7. iostat -xm 1 5 :
      It is a good tool to understand how a block device (HDD, SSD, ...) works

EOF
    echo "  7. iostat"
    $IOSTAT -xm 1 5| $SED 's/^/   /' >> /tmp/SUMMARY.txt 2>&1

cat << EOF >> /tmp/SUMMARY.txt

  ----------------------------------------------------------------------------
  8. free -m:

EOF
    echo "  8. free"
    $FREE -m | $SED 's/^/   /' >> /tmp/SUMMARY.txt 2>&1

cat << EOF >> /tmp/SUMMARY.txt

  ----------------------------------------------------------------------------
  9. sar -n DEV 2 5:
      Measures network throughput (Rx, Tx KB / s)

EOF
    echo "  9. sar -n DEV"
    $SAR -n DEV 2 5 | $SED '1d' | $COLUMN -t | $SED 's/^/   /' >> /tmp/SUMMARY.txt 2>&1

cat << EOF >> /tmp/SUMMARY.txt

  ----------------------------------------------------------------------------
  10. sar -n TCP,ETCP 2 5:
      This value summarizes the TCP traffic

EOF
    echo "  10. sar -n TCP,ETCP"
    $SAR -n TCP,ETCP 2 5 | $SED '1d' | $COLUMN -t| $SED 's/^/   /' >> /tmp/SUMMARY.txt 2>&1

cat << EOF >> /tmp/SUMMARY.txt

  ----------------------------------------------------------------------------
  11. df -h:

EOF
    echo "  11. df -h"
    $DF -h | $SED 's/^/   /' >> /tmp/SUMMARY.txt 2>&1

cat << EOF >> /tmp/SUMMARY.txt

  ----------------------------------------------------------------------------
  12. Network:

EOF
    echo "  12. Network"
    $IFCONFIG -a | $SED 's/^/   /' >> /tmp/SUMMARY.txt 2>&1

}


##############################################################################
#
#      Function : network_info
#    Parameters :
#        Output :
#         Notes : Collect lots of network information
#
##############################################################################

function network_info
{
    Echo "Section - Networking "

    if [ ! -d ${LOGDIR}/network ]; then
       MakeDir ${LOGDIR}/network
    fi

    $IFCONFIG -a        > ${LOGDIR}/network/ifconfig_-a.txt    2>&1
    $NETSTAT -rn        > ${LOGDIR}/network/netstat_-rn.txt    2>&1
    $NETSTAT -lan       > ${LOGDIR}/network/netstat_-lan.txt   2>&1
    $NETSTAT -lav       > ${LOGDIR}/network/netstat_-lav.txt   2>&1
    $NETSTAT -tulpn     > ${LOGDIR}/network/netstat_-tulpn.txt 2>&1
    $NETSTAT -ape       > ${LOGDIR}/network/netstat_-ape.txt   2>&1
    $NETSTAT -uan       > ${LOGDIR}/network/netstat_-uan.txt   2>&1
    $NETSTAT -s         > ${LOGDIR}/network/netstat_-s.txt     2>&1
    $NETSTAT -in        > ${LOGDIR}/network/netstat_-in.txt    2>&1
    $ROUTE  -nv     > ${LOGDIR}/network/route_-nv.txt      2>&1
    $ARP  -a            > ${LOGDIR}/network/arp_-a.txt         2>&1

    if [ -x "$IP" ] ; then
        $IP  add    > ${LOGDIR}/network/ip_add.txt     2>&1
        $IP  route  > ${LOGDIR}/network/ip_route.txt   2>&1
        $IP  link   > ${LOGDIR}/network/ip_link.txt    2>&1
        $IP  rule   > ${LOGDIR}/network/ip_rule.txt    2>&1
    fi

    #
    # Collect bridging information
    #

    if [ -x "$IPTABLES" ] ; then

        #Echo "Section - iptables check"

        $IPTABLES -L                > ${LOGDIR}/network/iptables-L.txt 2>&1
        $IPTABLES -t filter -nvL    > ${LOGDIR}/network/iptables-t_filter-nvL.txt 2>&1
        $IPTABLES -t mangle -nvL    > ${LOGDIR}/network/iptables-t_mangle-nvL.txt 2>&1
        $IPTABLES -t nat -nvL       > ${LOGDIR}/network/iptables_-t_nat_-nvL.txt 2>&1

    else
        echo "no iptables in kernel"   > ${LOGDIR}/network/iptables-NO-IP-TABLES
    fi

    if [ -x "$ETHTOOL" ] ; then

        #Echo "Section - ethtool checks"

        for version in 4 6
        do
            INTERFACES=$( cat /proc/net/dev | $GREP "[0-9]:" | $AWK -F: '{print $1 }' )

            for i in $INTERFACES
            do
                    $ETHTOOL $i        >  ${LOGDIR}/network/ethtool_ipv${version}_${i}.txt    2>&1
                    $ETHTOOL -i $i     >> ${LOGDIR}/network/ethtool_ipv${version}_-i_${i}.txt 2>&1
                    $ETHTOOL -S $i     >> ${LOGDIR}/network/ethtool_ipv${version}_-S_${i}.txt 2>&1
            done
        done
    fi

    MAINNETDEV=$($ROUTE | $GREP default | $AWK '{print $8}')
    if [ "$MAINNETDEV" == "eth0" ]; then
        SUBNETDEV="eth1"
        SUBNETGW=$($ROUTE | $GREP $SUBNETDEV | $AWK '{print $2}' | $GREP -v 0.0.0.0| $SORT | $UNIQ)
    elif [ "$MAINNETDEV" == "bond0" ]; then
        SUBNETDEV="bond1"
        SUBNETGW=$($ROUTE | $GREP $SUBNETDEV | $AWK '{print $2}' | $GREP -v 0.0.0.0| $SORT | $UNIQ)
    else
        SUBNETDEV=""
        SUBNETGW=""
    fi


    MAINNETGW=$($ROUTE | $AWK '/default/ { print $3 }')
    echo "" >> ${LOGDIR}/network/network_alive_status.txt
    echo "===========================================================================================" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo "  1. Pinging default gateway  to check for LAN connectivity"
    echo "1. Pinging default gateway  to check for LAN connectivity" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo "" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    if [ "$MAINNETDEV" == "" ]; then
        echo "default is no gateway. Probably disconnected..." >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    else
        $PING $MAINNETGW -c 5 >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    fi

    echo "" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo "===========================================================================================" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo "  2. Pinging private subnet gateway to check for LAN connectivity"
    echo "2. Pinging private subnet gateway to check for LAN connectivity" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    if [ "$SUBNETGW" == "" ]; then
        echo "eth1 is no gateway. Probably disconnected..." >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    else
        $PING $SUBNETGW -c 5 >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    fi

    checkdns=$($CAT /etc/resolv.conf | $AWK '/nameserver/ {print $2}' | $AWK 'NR == 1 {print; exit}')
    echo "" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo "===========================================================================================" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo "  3. Pinging first DNS server in resolv.conf ($checkdns) to check name resolution"
    echo "3. Pinging first DNS server in resolv.conf ($checkdns) to check name resolution" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    $PING $checkdns -c 5 >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    if [ $? -eq 0 ]
    then
        echo "$checkdns pingable. Proceeding with domain check." >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    else
      echo "Could not establish internet connection to DNS. Something may be wrong here." >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    fi

    checkdomain="www.google.com"
    echo "" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo "===========================================================================================" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo "  4. Pinging $checkdomain to check for internet connection."
    echo "4. Pinging $checkdomain to check for internet connection." >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    $PING $checkdomain -c 5 >> ${LOGDIR}/network/network_alive_status.txt 2>&1

    if [ $? -eq 0 ]; then
        echo "$checkdomain pingable. Internet connection is most probably available." >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    else
        echo "Could not establish internet connection. Something may be wrong here." >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    fi

    checkdomain="www.naver.com"
    echo "" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo "===========================================================================================" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo "  5. Pinging $checkdomain to check for internet connection."
    echo "5. Pinging $checkdomain to check for internet connection." >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    $PING $checkdomain -c 5 >> ${LOGDIR}/network/network_alive_status.txt 2>&1

    if [ $? -eq 0 ]; then
        echo "$checkdomain pingable. Internet connection is most probably available." >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    else
        echo "Could not establish internet connection. Something may be wrong here." >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    fi

    echo "" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo "===========================================================================================" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo "  6. Traceroute infomation"
    echo "6. Traceroute infomation" >> ${LOGDIR}/network/network_alive_status.txt 2>&1

    echo "** Naver Corporation **" >> ${LOGDIR}/network/network_alive_status.txt  2>&1
    $TRACEROUTE -4 -T -n  www.naver.com >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo >> ${LOGDIR}/network/network_alive_status.txt 2>&1

    echo "** Google Corporation **" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    $TRACEROUTE -4 -T -n  www.google.com >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo >> ${LOGDIR}/network/network_alive_status.txt 2>&1

    echo "** Yahoo Japan Corporation **" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    $TRACEROUTE -4 -T -n  www.yahoo.co.jp >> ${LOGDIR}/network/network_alive_status.txt 2>&1

    echo "" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo "===========================================================================================" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo "  7. Checking for HTTP Connectivity"
    echo "7. Checking for HTTP Connectivity" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    case "$($CURL -s --max-time 2 -I $checkdomain | $SED 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
        [23]) echo "$checkdomain HTTP connectivity is up" >> ${LOGDIR}/network/network_alive_status.txt 2>&1 ;;
        5) echo "The web proxy won't let us through" >> ${LOGDIR}/network/network_alive_status.txt 2>&1 ;exit 1;;
        *)echo "Something is wrong with HTTP connections. Go check it." >> ${LOGDIR}/network/network_alive_status.txt 2>&1; exit 1;;
    esac

    echo "" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo "===========================================================================================" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo "  8. Server Port Scanning..."
    echo "8. Server Port Scanning......" >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    $NMAP localhost >> ${LOGDIR}/network/network_alive_status.txt 2>&1
    echo
}

function user {
   Echo "Section - Agreement"

   echo
   echo
   echo "**********************************************************************"
   echo
   echo "NCP Checker Version (version $MYVERSION)"
   echo
   echo "This command will collect diagnostic and configuration information from"
   echo "this CentOS Enterprise Linux system and installed applications."
   echo
   echo "The generated archive may contain data considered sensitive and its"
   echo "content should be reviewed by the originating organization before being"
   echo "passed to any third party."
   echo
   echo "**********************************************************************"
   read -p "Are you sure to continue? (Y/N)            : " AGG
   echo "**********************************************************************"
   echo
   echo "Input Key : $AGG"

     if [[ "$AGG"  = [Yy] ]];then
         echo
     else
         echo "Aborting."
         exit 1
     fi

   echo "**********************************************************************"
   echo "Personal information"
   echo "**********************************************************************"
   echo
   read -p "NCP Account id    : " ID
   read -p "Environment ( TEST / DEV / PROD )              : " ENVIRONMENT
   echo "**********************************************************************"
   echo


$CAT << EOF > /tmp/SUMMARY.txt

  -----------------------------------------------------------------------------

  NCP Checker Version (version $MYVERSION)

  This command will collect diagnostic and configuration information from
  this Linux system and installed applications.

  The generated archive may contain data considered sensitive and its
  content should be reviewed by the originating organization before being
  passed to any third party.

  -----------------------------------------------------------------------------
  Are you sure to continue? (Y/N)            : Y
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------

  You selected $REPLY when asked if the test was to proceed.

  This directory contains system configuration information.
  Information was gathered on $MYDATE1

  -----------------------------------------------------------------------------
  CONTACT INFORMATION
  -----------------------------------------------------------------------------

  NCP Account id     : $ID
  Environment        : $ENVIRONMENT

  ----------------------------------------------------------------------------
  SYSTEM INFORMATION
  ----------------------------------------------------------------------------

  Date               : $MYDATE1
  Hostname           : $MYHOSTNAME
  OS                 : $OS_CHK
  System platform    : $SYSTEMPLATFORM
  Kernel Version     : $KERNELVERSION

EOF

}


##############################################################################
#
#      Function : disk_info
#    Parameters :
#        Output :
#         Notes : Collect general information about the disks on this system
#
##############################################################################

function disk_info
{
    Echo "Section - Disk Section Checks"

    local Dirname

    if [ ! -d ${LOGDIR}/disk ]; then
       MakeDir ${LOGDIR}/disks
    fi

    # Check to see what is mounted

    $DF -k      > ${LOGDIR}/disks/df_-k.txt 2>&1
    $DF -h      > ${LOGDIR}/disks/df_-h.txt 2>&1
    $DF -ki     > ${LOGDIR}/disks/df_-ki.txt    2>&1
    $DF -aki    > ${LOGDIR}/disks/df_-aki.txt   2>&1
    $DF -akih   > ${LOGDIR}/disks/df_-akih.txt  2>&1

    if [ -x $SWAPON ] ; then
        $SWAPON -s > ${LOGDIR}/disks/swapon_-s.txt  2>&1
    fi

    $MOUNT -l       > ${LOGDIR}/disks/mount_-l.txt      2>&1

    $CAT /proc/mounts   > ${LOGDIR}/disks/cat_proc-mounts.txt       2>&1

    ##############################################################################
    # Disk Format Information
    ##############################################################################

    DISKLIST=$($FDISK -l  2>/dev/null | grep "^/dev" | sed 's/[0-9]//g' | awk '{ print $1 }' | sort -u)

    if [ -x $FDISK ] ; then
        $FDISK   -l > ${LOGDIR}/disks/fdisk_-l.txt  2>&1
    fi

    if [ -x $SFDISK ] ; then
        $SFDISK  -l > ${LOGDIR}/disks/sfdisk_-l.txt  2>&1
        $SFDISK  -s > ${LOGDIR}/disks/sfdisk_-s.txt 2>&1
    fi

    if [ -x $BLKID ] ; then
        $BLKID      > ${LOGDIR}/disks/blkid.txt 2>&1
    fi

    if [ -x $LSBLK ] ; then
        $LSBLK -f       > ${LOGDIR}/disks/lsblk_-f.txt 2>&1
        $LSBLK -a       > ${LOGDIR}/disks/lsblk_-a.txt 2>&1
        $LSBLK -p       > ${LOGDIR}/disks/lsblk_-p.txt 2>&1
        $LSBLK -t       > ${LOGDIR}/disks/lsblk_-t.txt 2>&1
        $LSBLK -S       > ${LOGDIR}/disks/lsblk_-S.txt 2>&1
        $LSBLK --list   > ${LOGDIR}/disks/lsblk_--list.txt 2>&1
    fi

    for DISK in $DISKLIST
    do

        Dirname=$(dirname $DISK)

        if [ "$Dirname" == "/dev/mapper" ] ; then

            if [ ! -L  $DISK ] ; then
                continue
            fi
        fi

       NEWDISK=$(/bin/echo $DISK |  sed 's/\//-/g'  | sed 's/^-//'g )

        if [ -x $SFDISK ] ; then
            $SFDISK  -l $DISK       > ${LOGDIR}/disks/sfdisk_-l_${NEWDISK}.txt 2>&1
        fi

        if [ -x $FDISK ] ; then
            $FDISK   -l $DISK   > ${LOGDIR}/disks/fdisk_-l_${NEWDISK}.txt 2>&1
        fi

    done

    # LVM information
    if [ -f $PVS ]; then
       PVDIS=$($PVS | $GREP UUID )
       #VGDIS=$($VGS | $GREP  UUID)
       #LVDIS=$($LVS | $GREP UUID)

       if [ "$PVDIS" != "" ]; then

           echo "pvdisplay" > ${LOGDIR}/disks/lvm.txt 2>&1
           $PVS >> ${LOGDIR}/disks/lvm.txt > /dev/null 2>&1

           echo "vgdisplay" >> ${LOGDIR}/disks/lvm.txt 2>&1
           $VGS >> ${LOGDIR}/disks/lvm.txt > /dev/null 2>&1

           echo "lvdisplay" >> ${LOGDIR}/disks/lvm.txt 2>&1
           $LVS >> ${LOGDIR}/disks/lvm.txt > /dev/null 2>&1
       fi
    fi

}


##############################################################################
#
#      Function : system_logs_info
#    Parameters :
#        Output :
#         Notes : Take a copy of the latest logs
#
##############################################################################

function system_logs_info
{
   Echo "Section - Systems Log "

   if [ ! -d ${LOGDIR}/logs ]; then
       MakeDir ${LOGDIR}/logs
   fi

   if [ -d /var/log ]; then
       for i in $($LS -l /var/log/ | $GREP -vE 'maillog|*.old|nsight_updater.log|ncloud-init.log|spooler|wtmp|ConsoleKit|prelink|ntpstats|lastlog' | $AWK '{print $9}')
       do
           $CP -Rp /var/log/$i  ${LOGDIR}/logs
       done
    fi

    $DMESG  > ${LOGDIR}/logs/dmesg.txt 2>&1

    if [ "$OS_CHK" == "CentOS" ]; then
       $LAST   > ${LOGDIR}/logs/lastlog 2>&1
    fi
}


##############################################################################
#
#      Function : performance_info
#    Parameters :
#        Output :
#         Notes : some general information about performance
#
##############################################################################

function performance_info
{

   Echo "Section - Performance/System "

   if [ ! -d "${LOGDIR}/system/performance" ]; then
      MakeDir ${LOGDIR}/system/performance
   fi

   echo "  1. ps information"
   $PS auxw            > ${LOGDIR}/system/ps_auxw.txt 2>&1
   $PS -lef            > ${LOGDIR}/system/ps_-elf.txt 2>&1
   $HOSTNAME           > ${LOGDIR}/system/hostname.txt 2>&1

   if [ -e /proc/stat ] ; then
       $CAT /proc/stat         > ${LOGDIR}/system/stat.txt 2>&1
   fi

   if [ -x $DATE ] ; then
       $DATE           > ${LOGDIR}/system/date.txt 2>&1
   fi

   if [ -x $FREE ] ; then
       $FREE           > ${LOGDIR}/system/free.txt 2>&1
   fi


   echo "  2. ps tree information"
   if [ -x $PSTREE ] ; then
       $PSTREE         > ${LOGDIR}/system/pstree.txt 2>&1
   fi

   $UPTIME             > ${LOGDIR}/system/uptime.txt 2>&1
   ulimit -a           > ${LOGDIR}/system/ulimit_-a.txt 2>&1



   echo "  3. lsof information"
   if [ "$LSOF" != "" ] ; then
       $LSOF >  ${LOGDIR}/system/lsof.txt  2>&1
   fi

   echo "  4. loadavg information"
   if [ -e /proc/loadavg ] ; then
       $CAT /proc/loadavg      > ${LOGDIR}/system/performance/loadavg.txt 2>&1
   fi

   # performance gathering

   echo "  5. vmstat information"
   if [ -x $VMSTAT ] ; then
       $VMSTAT -s      > ${LOGDIR}/system/performance/vmstat_-s.txt 2>&1
   fi

   echo "  6. mpstat information"
   if [ -x $MPSTAT ] ; then
       $MPSTAT -P ALL  > ${LOGDIR}/system/performance/mpstat-PALL.txt 2>&1
   fi

   echo "  7. pidstat information"
   if [ -x $PIDSTAT ] ; then
       $PIDSTAT  > ${LOGDIR}/system/performance/pidstat.txt 2>&1
   fi

   echo "  8. iostat information"
   if [ -x $IOSTAT ] ; then
       $IOSTAT -xm 1 5 > ${LOGDIR}/system/performance/iostat.txt 2>&1
   fi

   if [ "$OS_CHK" == "Ubuntu" ]; then
       echo "  9. sar information"
       if [ -x $SAR ] ; then
           echo "==================================================================================================" > ${LOGDIR}/system/performance/sa.txt 2>&1
           echo "sar -n DEV 2 5" >> ${LOGDIR}/system/performance/sa.txt 2>&1
           $SAR -n DEV 2 5 >> ${LOGDIR}/system/performance/sa.txt 2>&1
           echo >> ${LOGDIR}/system/performance/sa.txt 2>&1

           echo "==================================================================================================" >> ${LOGDIR}/system/performance/sa.txt 2>&1
           echo "sar -r 2 5" >> ${LOGDIR}/system/performance/sa.txt 2>&1
           $SAR -r 2 5 >> ${LOGDIR}/system/performance/sa.txt 2>&1
           echo >> ${LOGDIR}/system/performance/sa.txt 2>&1

           echo "==================================================================================================" >> ${LOGDIR}/system/performance/sa.txt 2>&1
           echo "sar -B 2 5" >> ${LOGDIR}/system/performance/sa.txt 2>&1
           $SAR -B 2 5 >> ${LOGDIR}/system/performance/sa.txt 2>&1
           echo >> ${LOGDIR}/system/performance/sa.txt 2>&1

           echo "==================================================================================================" >> ${LOGDIR}/system/performance/sa.txt 2>&1
           echo "sar -b 2 5" >> ${LOGDIR}/system/performance/sa.txt 2>&1
           $SAR -b 2 5 >> ${LOGDIR}/system/performance/sa.txt 2>&1
           echo >> ${LOGDIR}/system/performance/sa.txt 2>&1

           echo "==================================================================================================" >> ${LOGDIR}/system/performance/sa.txt 2>&1
           echo "sar -d 2 5" >> ${LOGDIR}/system/performance/sa.txt 2>&1
           $SAR -d 2 5 >> ${LOGDIR}/system/performance/sa.txt 2>&1
           echo >> ${LOGDIR}/system/performance/sa.txt 2>&1

           echo "==================================================================================================" >> ${LOGDIR}/system/performance/sa.txt 2>&1
           echo "sar -w 2 5" >> ${LOGDIR}/system/performance/sa.txt 2>&1
           $SAR -w 2 5 >> ${LOGDIR}/system/performance/sa.txt 2>&1
           echo >> ${LOGDIR}/system/performance/sa.txt 2>&1

           echo "==================================================================================================" >> ${LOGDIR}/system/performance/sa.txt 2>&1
           echo "sar -W 2 5" >> ${LOGDIR}/system/performance/sa.txt 2>&1
           $SAR -W 2 5 >> ${LOGDIR}/system/performance/sa.txt 2>&1
           echo  >> ${LOGDIR}/system/performance/sa.txt 2>&1
       fi
   fi
   echo

}


##############################################################################
#
#      Function : time_info
#    Parameters :
#        Output :
#         Notes : General time information
#
##############################################################################

function time_info
{
    Echo "Section - NTP"

    TIMEDIR=${LOGDIR}/etc/time

    MakeDir ${TIMEDIR}
    $DATE       > ${TIMEDIR}/date

    if [ -f /etc/ntp.conf ] ; then
        $CP -p /etc/ntp.conf  ${TIMEDIR}/ntp.conf
    fi


    if [ -x $NTPQ  ] ; then
        $NTPQ -p > ${TIMEDIR}/ntpq_-p.txt 2>&1
    fi

    if [ "$NTPQ" != "" ] ; then
        $NTPDATE -d 10.250.255.21 > ${TIMEDIR}/ntpdate.txt 2>&1
    fi

}
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
