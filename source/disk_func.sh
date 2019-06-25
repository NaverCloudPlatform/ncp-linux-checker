

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
       PVDIS=$($PVS | $GREP UUID)
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
