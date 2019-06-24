

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
