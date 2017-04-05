#!/bin/bash

# VERSION HISTORY
# 2017-01-31
# - Use the caffinate command where available to
#   prevent computer from sleeping during a backup

# 2016.10.19
# - Bugfix for directory prompting

# 2016.06.13
# - Autodetect possible backup / reload locations, prompt
#   user with choice

# 2016.03.04
# - Add Library/Mail, Fix Address Book, Safari Bookmarks
# - fixed bug with spaces in directory names

# 2016.03.03
# - initial version

# MAINTAINER
# mitch@mitchjacksontech.com

VERSION="2017.01.31"

echo ========================================
echo Backup Script for MacOS
echo   mitch@mitchjacksontech.com
echo VERSION: $VERSION
echo =================================================

SRC_DIR=$1;
DST_DIR=$2;
SHOW_OPTS=0;

SRC_DIR=${1%/} # opts with trailing slashes removed
DST_DIR=${2%/}

# List all dirs to be backed up if they exist
BACKUP_DIRS=( \
"Desktop"    \
"Documents"  \
"Downloads"  \
"Movies"     \
"Music"      \
"Pictures"   \
"DropBox"    \
"Library/Accounts" \
"Library/Calendars" \
"Library/Messages" \
"Library/Mail" \
"Library/Application Support/AddressBook" \
"Library/Containers/com.apple.Notes" );



# List all files to be backed up if they exist
# ( file will not copy if dst dir hasn't already been created
#   this can be fixed later if needed )
BACKUP_FILES=( \
"Library/StickiesDatabase" \
"Library/Safari/Bookmarks.plist" );

# List of dirs that must be created for backup ops
BACKUP_MKDIR=( "Library/Safari" );

echo SRC_DIR: $SRC_DIR
echo DST_DIR: $DST_DIR

# If no parameters passed to script, then prompt user for
# source and destination root directories
if [ ! "$1" ]; then

    # Prompt user to choose a user dir
    # anything that matches /Volumes/*/Users/*/
    echo "********************************************************************"
    echo "** Choose a user directory to back up"
    echo "***********************************************"
    select SRC_DIR in /Volumes/*/Users/*;
    do
        echo ">> ${SRC_DIR} selected <<"
        echo;
        break;
    done

    # Prompt user to choose a destination dir
    # Offer to back up to ~/Desktop, or attached hard drives
    echo "********************************************************************"
    echo "** Choose the backup destination"
    echo "***********************************************"
    declare -a dstopts
    dstopts+=("~/Desktop")
    for f in /Volumes/*; do
        echo ">>>> Found $f"
        dstopts+=("$f")
    done
    select DST_DIR in "${dstopts[@]}";
    do
        echo ">> ${DST_DIR} selected <<"
        echo
        break
    done

    # Propt user to name the destination directory
    echo "Name the backup directory: "
    read bname
    DST_DIR+="/${bname}"

    echo "********************************************************************"
    echo "** Confirm your selected options"
    echo "***********************************************"
    echo "Source Directory: ${SRC_DIR}"
    echo "Backup Directory: ${DST_DIR}"
    echo
    echo "[y/N]?: "
    read yorn
    if [ ! $yorn == "y" ]; then
        exit
    fi

    # Create the destination backup directory
    mkdir -p "${DST_DIR}"
fi

if [ ! -d "$SRC_DIR" ]; then
    echo
    echo SOURCE must be a valid directory;
    echo
    echo
    SHOW_OPTS=1;
fi
if [ ! -d "$DST_DIR" ]; then
    echo
    echo DESTINATION must be a valid directory;
    echo
    echo
    SHOW_OPTS=1;
fi
if [ $SHOW_OPTS == 1 ]; then
    echo Usage: MitchSuperBackup.sh [source] [destination];
    echo;
    exit;
fi


# On osx 10.8 and later, use caffeinate to stop the host from
# resting during the backup
command_exists () {
    type "$1" &> /dev/null ;
}
if command_exists caffeinate; then
    RSYNC_CMD="caffeinate -s rsync"
else
    RSYNC_CMD="rsync"
fi


# Create needed directories in dst
for D in "${BACKUP_MKDIR[@]}"
do
    :
    echo "Create Directory: $DST_DIR/$D"
    mkdir -p "$DST_DIR/$D"
done

# Backup directories
for D in "${BACKUP_DIRS[@]}"
do
    :
    #echo $SRC_DIR/$D
    if [ -d "$SRC_DIR/$D" ]; then
        echo "********************************************************************"
        echo "** Backup Ooperation: $SRC_DIR/$D"
        echo "***********************************************"
        mkdir -p "$DST_DIR/$D"
        $RSYNC_CMD -avh "$SRC_DIR/$D/" "$DST_DIR/$D/"
    fi
done

# Backup files
for F in "${BACKUP_FILES[@]}"
do
    :
    if [ -e "$SRC_DIR/$F" ]; then
        cp "$SRC_DIR/$F" "$DST_DIR/$F"
    fi
done
