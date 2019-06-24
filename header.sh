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

