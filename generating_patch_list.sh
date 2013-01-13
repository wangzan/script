#!/bin/bash
# $3 is the log dir


#function help_info()
#{
#    echo "1-TAG1"
#    echo "2-TAG2"
#    echo "3-log out dir"
#}
#
#
#
TAG1=
TAG2=

OUT=
function getopts_args()  
{  
    #echo -e "\n### getopts_act ###\n"
    while getopts h:t:o: ARGS
    do
    case $ARGS in
        h)
            echo "help !!!!!!!!!!!!!!!!"
            ;;
        t)
            #echo "get the tag1 and tag2 !!!"
            TAG1=$(echo "$OPTARG" | awk -F "\.\." '{print $1;}')
            TAG2=$(echo "$OPTARG" | awk -F "\.\." '{print $2;}')
            #echo "tag1 is $TAG1"
            #echo "tag2 is $TAG2"
            ;;
        o)
            OUT=$OPTARG/logs
            #echo "out path is $OUT"
            ;;
         *)
             echo "Unknow option: $ARGS"
            ;;
    esac
    done
}

getopts_args $@

function generating_patch_list()
{
    local LOG_NAME=$(echo "$REPO_PATH" | awk '{gsub("\/","_");print $0;}')

    local LOGDIR=$OUT/logs

    local PATCH_DIR=$OUT/patch

    local TIME=`date '+%Y-%m-%d %T'`

    local CHANGE=`git diff $TAG1 $TAG2`

    if [ "$CHANGE" ] ; then
        if [ ! -d $LOGDIR ] ; then
    	    mkdir -p $LOGDIR
        fi
        if [ ! -d $PATCH_DIR ] ; then
            mkdir -p $PATCH_DIR
        fi
        echo "[$TIME] Generating patch list start ... " > $LOGDIR/$LOG_NAME.log
        echo "[$TIME] changes in project : $REPO_PATH " >> $LOGDIR/$LOG_NAME.log
        git log $TAG1..$TAG2 --reverse --no-merges --date=short --pretty=format:"%ad|%H|%an|%cn|%s" --exit-code 1> $PATCH_DIR/$LOG_NAME.patch.list
        echo >> $PATCH_DIR/$LOG_NAME.patch.list
        echo "[$TIME] output the patch list in $PATCH_DIR/$LOG_NAME.patch.list " >> $LOGDIR/$LOG_NAME.log
        echo "[$TIME] formating patch in $LOGDIR/patch  ..." >> $LOGDIR/$LOG_NAME.log
        git format-patch -k $TAG1..$TAG2 -o $LOGDIR/patch/ 1>/dev/null
        echo "[$TIME] patch file formating ok!! " >> $LOGDIR/$LOG_NAME.log
        echo "[$TIME] please see the $LOG_NAME.patch.list " >> $LOGDIR/$LOG_NAME.log
        echo "[$TIME] End generating patch list !!!! " >> $LOGDIR/$LOG_NAME.log
        echo >> $LOGDIR/$LOG_NAME.log
    fi
}

generating_patch_list
# start add these patch



#echo "[$TIME] Start to add these patch to new branch " >> $LOGDIR/$LOG_NAME.log
#sed -n '$p' logs/patch/kernel.patch.list



#export FIND_DIFF=$(find_diff)
#repo forall -c "(generating_patch_list $1 $2 `pwd`)"
