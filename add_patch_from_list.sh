#!/bin/bash

LOGS=

function getopts_args()  
{  
    while getopts h:l: ARGS
    do
    case $ARGS in
        h)
            echo "help !!!!!!!!!!!!!!!!"
            ;;
        l)
            LOGS=$OPTARG/logs
            #echo "out path is $LOGS"
            ;;
         *)
             echo "Unknow option: $ARGS"
            ;;
    esac
    done
}

getopts_args $@


function add_patch_from_list()
{
    local PATCH_LIST_FILE=$LOGS/patch/$(echo "$REPO_PATH" | awk '{gsub("\/","_");print $0;}').patch.list
    local PATCHED_LIST_FILE=$LOGS/patch/$(echo "$REPO_PATH" | awk '{gsub("\/","_");print $0;}').patched.list
    local PATCH_LOG=$LOGS/repo_patch.log
    local PATCHED=

    if [ -e $PATCH_LIST_FILE ] ; then
        echo -e "\n============  $(date '+%Y-%m-%d %T') ============" >> $PATCH_LOG
        echo -e "\npatch project name is $REPO_PATH \n" >> $PATCH_LOG
        while read LINE ; do
            SHA=`echo "$LINE" | awk -F "|" '{print $2;}'`
            if [ ! -e $PATCHED_LIST_FILE ] ; then
                echo -e "\n[patch backup files]\n" >> $PATCHED_LIST_FILE
            fi

            while read LINE_PATCHED ; do
                SHA_PATCHED=`echo "$LINE_PATCHED" | awk -F "|" '{print $2;}'`
                if [ "$SHA" != "$SHA_PATCHED" ] ; then
                    PATCHED="FALSE"
                else
                    PATCHED="TRUE"
                fi
            done < $PATCHED_LIST_FILE

            if [ "$PATCHED" = "FALSE" ] ; then
                echo -e "patching $SHA ... " >> $PATCH_LOG
                echo -e "$LINE" >> $PATCHED_LIST_FILE
                # git cherry-pick one by one
                git cherry-pick $SHA
                if [ $? != 0 ] ; then
                    echo -e "\n[error] happend in project $REPO_PATH \n" >> $PATCH_LOG
                    git cherry-pick --abort >> $PATCH_LOG 2>&1
                    echo -e "\nplease patch [ $SHA ] manuelly!!!" >> $PATCH_LOG
                    echo -e "Using: git cherry-pick $SHA in $REPO_PATH \n" >> $PATCH_LOG
                    return
                fi
            fi

        done < $PATCH_LIST_FILE
    fi
}

add_patch_from_list
