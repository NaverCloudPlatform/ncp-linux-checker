
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
