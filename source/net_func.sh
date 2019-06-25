

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
