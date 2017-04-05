#!/bin/bash
#
# VERSION HISTORY
#
# 2017-02-13
# Show ONLY directories for restore
#
# 2017-02-06
# Initial Version
#
# MAINTAINER
# mitch@mitchjacksontech.com
#

VERSION="2017.01.31"

SRC_DIR=$1;
DST_DIR=$2;

echo ========================================
echo Mitch Super Mac Backup Script
echo VERSION: $VERSION
echo =================================================
echo
echo ///////////////////////////////////////////////
echo WARNING WARNING WARNING WARNING WARNING WARNING
echo ///////////////////////////////////////////////
echo Please run this script only while logged in on
echo the target machine as the user owning the files
echo


# If no parameters passed to script, then prompt user for
# source and destination root directories
if [ ! "$1" ]; then

    # Prompt user to choose a user dir
    # all our backup drives are named a variant of
    # Passport.  List all folders in any drives
    # whose name starts with a P
    echo "********************************************************************"
    echo "** Choose a user directory to restore"
    echo "***********************************************"
    select SRC_DIR in /Volumes/P*/*/;
    do
        echo ">> ${SRC_DIR} selected <<"
        echo;
        break;
    done
    DST_DIR=~/


fi

echo "********************************************************************"
echo "** Confirm your wise choices"
echo "***********************************************"
echo
echo "Backup From: ${SRC_DIR}"
echo "Backup To:   ${DST_DIR}"
echo
read -rsp $'Press any key to continue...\n' -n1 key


# On osx 10.8 and later, use caffeinate to stop the host from
# resting during the backup
command_exists () {
    type "$1" &> /dev/null ;
}
if command_exists caffeinate; then
    RSYNC_CMD="caffeinate -i rsync"
else
    RSYNC_CMD="rsync"
fi

$RSYNC_CMD -avh "$SRC_DIR" "$DST_DIR"
