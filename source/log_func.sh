

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
