

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
