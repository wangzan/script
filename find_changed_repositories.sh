#!/bin/bash
# $1 is the log dir

TAG1=$1
TAG2=$2

OUT=$3/logs
LOG_NAME=$(echo "$REPO_PATH" | awk '{gsub("\/","_");print $0;}')

LOGDIR=$OUT/logs

PATCH_DIR=$OUT/patch

TIME=$(date '+%Y-%m-%d %T')

function generating_patch_list()
{
    local CHANGE=`git diff $TAG1 $TAG2`

    if [ "$CHANGE" ] ; then
        if [ ! -d $LOGDIR ] ; then
    	mkdir -p $LOGDIR
        fi
        if [ ! -d $PATCH_DIR ] ; then
            mkdir -p $PATCH_DIR
        fi
        echo "[$TIME] Generating patch list start ... " >> $LOGDIR/$LOG_NAME.log
        echo "[$TIME] changes in project : $REPO_PATH " >> $LOGDIR/$LOG_NAME.log
        git log $TAG1..$TAG2 --no-merges --pretty=format:"%H|%an|%cn|%s" > $PATCH_DIR/$LOG_NAME.patch.list
        echo "[$TIME] output the patch list in $PATCH_DIR/$LOG_NAME.patch.list " >> $LOGDIR/$LOG_NAME.log
        #echo "[$TIME] formating patch in $LOGDIR/patch  ..." >> $LOGDIR/$LOG_NAME.log
        #git format-patch -k $TAG1..$TAG2 -o $LOGDIR/patch/ 1>/dev/null
        #echo "[$TIME] patch file formating ok!! " >> $LOGDIR/$LOG_NAME.log
        echo "[$TIME] please see the $LOG_NAME.patch.list " >> $LOGDIR/$LOG_NAME.log
        echo "[$TIME] End generating patch list !!!! " >> $LOGDIR/$LOG_NAME.log
    fi
}
export PATH=$PATH:generating_patch_list
# start add these patch

#echo "[$TIME] Start to add these patch to new branch " >> $LOGDIR/$LOG_NAME.log
#sed -n '$p' logs/patch/kernel.patch.list



#export FIND_DIFF=$(find_diff)
repo forall -c $FIND_DIFF > $PWD/$OUT_CHANGE_LOG
