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
    while getopts ht:o: ARGS
    do
    case $ARGS in
        h)
            echo "Usage:"
            echo "      -t : tags from..to you want to get patch"
            echo "      -o : set the log output path"
            echo "      -h : get the help content"
            exit
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
            exit
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
        echo "[$(date '+%Y-%m-%d %T')] Generating patch list start ... " > $LOGDIR/$LOG_NAME.log
        echo "[$(date '+%Y-%m-%d %T')] changes in project : $REPO_PATH " >> $LOGDIR/$LOG_NAME.log
        git log $TAG1..$TAG2 --reverse --no-merges --date=short --pretty=format:"%ad|%H|%an|%cn|%s" --exit-code 1> $PATCH_DIR/$LOG_NAME.patch.list
        echo >> $PATCH_DIR/$LOG_NAME.patch.list
        echo "[$(date '+%Y-%m-%d %T')] output the patch list in $PATCH_DIR/$LOG_NAME.patch.list " >> $LOGDIR/$LOG_NAME.log
        echo "[$(date '+%Y-%m-%d %T')] formating patch in $PATCH_DIR/patch/$LOG_NAME  ..." >> $LOGDIR/$LOG_NAME.log
        if [ ! -d $PATCH_DIR/patch/$LOG_NAME ] ; then
            mkdir -p $PATCH_DIR/patch/$LOG_NAME
        fi
        git format-patch -k $TAG1..$TAG2 -o $PATCH_DIR/patch/$LOG_NAME >/dev/null 2>&1
        echo "[$(date '+%Y-%m-%d %T')] patch file formating ok!! " >> $LOGDIR/$LOG_NAME.log
        echo "[$(date '+%Y-%m-%d %T')] please see the $LOG_NAME.patch.list " >> $LOGDIR/$LOG_NAME.log
        echo "[$(date '+%Y-%m-%d %T')] End generating patch list !!!! " >> $LOGDIR/$LOG_NAME.log
        echo >> $LOGDIR/$LOG_NAME.log
    fi
}

generating_patch_list
#export FIND_DIFF=$(find_diff)
#repo forall -c "(generating_patch_list $1 $2 `pwd`)"
