

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
