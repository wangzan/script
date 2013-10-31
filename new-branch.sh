#!/bin/bash
# author     : wangzan
# date       : 2013-10-25
# description:
#				$1 is manifest file name (no postfix xml)
#				$2 is the opt , e.g. new update fetch
# history    :
#				1. [wangzan]	init base code
#				2. [wangzan]	add "new update fetch" function
#				3. [wangzan]    fix bug : can't not check branch whether exist in remote correctly.
# example    :
#			new-branch.sh release-x130w-3060-cbb new

#export REPO_TRACE=1
export BRANCH_NAME=$1
MANIFEST=$BRANCH_NAME.xml
LOG_FILE=`pwd`/new-$(date '+%Y%m%d%H%M%S').log
LOG_FILE2=`pwd`/update-$(date '+%Y%m%d%H%M%S').log
LOG_FILE3=`pwd`/fetch-$(date '+%Y%m%d%H%M%S').log


function do_commit()
{
# Generate new manifest xml file.
	if [ -e ./manifests ]; then
		rm ./manifests -rf
	fi
	git clone gitserver:manifests.git -b release
	sed 's/revision="\+[0-9a-z]\{40\}\+"//g' $ORI_MANIFEST > $NEW_MANIFEST
}

function do_new()
{
	echo "New Log :"
	repo init -u gitserver:manifests.git -b release 2>&1
	echo "======== repo sync ========"
	repo sync -d -j4 -m $MANIFEST 2>&1
#	echo "======== repo abandon ========"
#	repo abandon $BRANCH_NAME 2>&1
#	echo "======== repo start ========"
#	repo start $BRANCH_NAME --all 2>&1

	echo "======== start to push branch  ========"
	repo forall -c 'echo $REPO_PROJECT; git push gerrit:$REPO_PROJECT HEAD:$BRANCH_NAME;' 2>&1

	sync
	# check
	echo "===================================="
	echo "Check Log :"
	
	if [ -z "`repo forall -c 'if [ -z "\`git branch -r | grep -w phicomm\/$BRANCH_NAME\$\`" ]; then echo $REPO_PROJECT ; fi '`" ] ; then
		echo "success!!!"
	else
		echo "Failed projects is : "
		repo forall -c 'if [ -z "`git branch -r | grep -w phicomm\/$BRANCH_NAME\$`" ]; then echo $REPO_PROJECT ; fi ' 2>&1
		echo "================================="
		echo "======== Now Retring ... ========"
		echo "================================="
		repo sync -n -j4 2>&1
		sync
		repo forall -c 'if [ -z "`git branch -r | grep -w phicomm\/$BRANCH_NAME\$`" ]; then git push gerrit:$REPO_PROJECT HEAD:$BRANCH_NAME ; fi ' 2>&1
		sync
		if [ -z "`repo forall -c 'if [ -z "\`git branch -r | grep -w phicomm\/$BRANCH_NAME\$\`" ]; then echo $REPO_PROJECT ; fi '`" ] ; then
			echo "success!!!"
		else
			echo "Failed projects is : "
			repo forall -c 'if [ -z "`git branch -r | grep -w phicomm\/$BRANCH_NAME\$`" ]; then echo $REPO_PROJECT ; fi ' 2>&1
			echo "failed!!!"
		fi

	fi
}

function do_update()
{
	echo "Update Log :"
	repo forall -c 'if [ -z "`git branch -r | grep -w phicomm\/$BRANCH_NAME\$`" ]; then git push gerrit:$REPO_PROJECT HEAD:$BRANCH_NAME ; fi ' 2>&1
	sync
	# check
	echo "===================================="
	echo "Check Log :"
	
	if [ -z "`repo forall -c 'if [ -z "\`git branch -r | grep -w phicomm\/$BRANCH_NAME\$\`" ]; then echo $REPO_PROJECT ; fi '`" ] ; then
		echo "success!!!"
	else
		echo "Failed projects is : "
		repo forall -c 'if [ -z "`git branch -r | grep -w phicomm\/$BRANCH_NAME\$`" ]; then echo $REPO_PROJECT ; fi ' 2>&1
		echo "================================="
		echo "======== Now Retring ... ========"
		echo "================================="
		repo sync -n -j4 2>&1
		sync
		repo forall -c 'if [ -z "`git branch -r | grep -w phicomm\/$BRANCH_NAME\$`" ]; then git push gerrit:$REPO_PROJECT HEAD:$BRANCH_NAME ; fi ' 2>&1
		sync
		if [ -z "`repo forall -c 'if [ -z "\`git branch -r | grep -w phicomm\/$BRANCH_NAME\$\`" ]; then echo $REPO_PROJECT ; fi '`" ] ; then
			echo "success!!!"
		else
			echo "Failed projects is : "
			repo forall -c 'if [ -z "`git branch -r | grep -w phicomm\/$BRANCH_NAME\$`" ]; then echo $REPO_PROJECT ; fi ' 2>&1
			echo "failed!!!"
		fi
	fi


}

function do_fetch()
{
	echo "Fetch Log :"
	repo sync -n -j4 2>&1
	sync

	# check
	echo "===================================="
	echo "Check Log :"
	
	if [ -z "`repo forall -c 'if [ -z "\`git branch -r | grep -w phicomm\/$BRANCH_NAME\$\`" ]; then echo $REPO_PROJECT ; fi '`" ] ; then
		echo "success!!!"
	else
		echo "Failed projects is : "
		repo forall -c 'if [ -z "`git branch -r | grep -w phicomm\/$BRANCH_NAME\$`" ]; then echo $REPO_PROJECT ; fi ' 2>&1
		echo "failed!!!"
	fi

}

if [ $2 == "new" ]; then
	do_new | tee $LOG_FILE
fi
if [ $2 == "update" ]; then
	do_update | tee $LOG_FILE2
fi
if [ $2 == "fetch" ]; then
	do_fetch | tee $LOG_FILE3
fi

