#!/usr/bin/env bash

# ==========================================
# Watch a source directory and copy files to
# destination directory with the provided
# ownership and privelages. Should be run
# as sudo to enable managing destination
# ownership and priveleges.
# 
# Requires inotifywait to be installed
#
# Arguments 
#   -s, --source
#       Source path
#   -d, --destination
#       Destination path
#   -u, --user
#       User for destination path
#   -g, --group
#       Group for destination path
#
# ==========================================

# Check if inotifywait is available
if [[ $(command -v inotifywait) == '' ]]; then
    echo "inotifywait not installed"
    exit 1
fi

SRC_DIR=''
DEST_DIR=''
CHOWN_USR=''
CHOWN_GRP=''

while [[ $# -gt 0 ]]; do
    case "$1" in
        -s | --source )
            SRC_DIR=$2
            ;;
        -d | --destination )
            DEST_DIR=$2
            ;;
        -u | --user )
            CHOWN_USR=$2
            ;;
        -g | --group )
            CHOWN_GRP=$2
            ;;
    esac
    shift
done

rm -rf $DEST_DIR
mkdir -p $DEST_DIR
cp -rf $SRC_DIR/* $DEST_DIR
chown -R $CHOWN_USR:$CHOWN_GRP $DEST_DIR

MOVE_FROM=''

while read event; do
    path=$( echo $event | awk '{ print $1 }' )
    path=$( echo $path | sed -e "s/$SRC_DIR\///" )
    action=$( echo $event | awk '{ print $2 }' )
    isdir=$( echo $action | awk -F"," '{ print $2 }' )    
    action=$( echo $action | awk -F"," '{ print $1 }')
    filename=$( echo $event | awk '{ print $3 }')

    if [[ $isdir == '' || -z $isdir ]]; then
        isdir=false
    else
        isdir=true
    fi

    echo "----------------"
    echo "Action: $action"
    echo "Path: $path"
    echo "Filename: $filename"
    echo "Isdir: $isdir"
    echo "MOVE_FROM: $MOVE_FROM"

    case $action in

        "MOVED_FROM" )
            if [[ $MOVE_FROM != '' ]]; then
                rm -rf $DEST_DIR/$MOVE_FROM
                echo "DANGER DANGER"
                MOVE_FROM=''
            fi

            MOVE_FROM=$path$filename
            ;;

        "MOVED_TO" )

            if [[ $MOVE_FROM != '' ]]; then
                mv -f $DEST_DIR/$MOVE_FROM $DEST_DIR/$path$filename
            fi 
            ;;

        "MODIFY" | "CREATE" | "ATTRIB" )
            if [[ $MOVE_FROM != '' ]]; then
                rm -rf $DEST_DIR/$MOVE_FROM
                MOVE_FROM=''
            fi

            cp -Rf $SRC_DIR/$path$filename $DEST_DIR/$path$filename
            chown $CHOWN_USR:$CHOWN_GRP $DEST_DIR/$path$filename
            ;;
    esac

done < <( inotifywait -m -r -e create -e modify -e move -e delete -e attrib $SRC_DIR )