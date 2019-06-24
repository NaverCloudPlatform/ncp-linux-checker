

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
