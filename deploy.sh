#!/usr/bin/env bash

DEFAULT_EXCLUDES="
 --exclude=.git
 --exclude=.gitignore
 --exclude=.hg
 --exclude=.hgignore
 --exclude=.hgcheck
 --exclude=.svn
 --exclude=*.pyc
 --exclude=.DS_Store
 --exclude=.idea
 --exclude=.deploy
 --exclude=log
 --exclude=debian
 --exclude=.ropeproject
"

EXCLUDES=''

REVERSE=''
PROJ=`pwd`

retry=0
until [[ -f $PROJ/.deploy ]]
do
    if [[ $retry -gt 100 ]]; then
        echo "Can\'t find \".deploy\" file $1"
        exit 1
    fi
    PROJ="$PROJ/.."
    retry=$(($retry+1))
done

cd $PROJ
PROJ=`pwd`

. $PROJ/.deploy

EXCLUDES="$EXCLUDES $DEFAULT_EXCLUDES"

while [ $1 ]
do
    if [[ `echo $1 | grep with=` ]]; then
        WITH=`echo $1 | gsed -re 's/--with=(.+)/\1/g'`
        EXCLUDES=`echo $EXCLUDES | gsed -re 's/[ ]+/\n/g' | grep -v $WITH`
        shift
        continue
    fi
    if [[ $1 == '--reverse' ]]; then
        REVERSE=true
        shift
        continue
    fi
    echo "Unknown option $1"
    exit 1
done

if [[ $REMOTE_USER == '' ]]; then
	REMOTE_USER=$USER
fi

if [[ $REVERSE ]]; then
    PROJ_NAME=`echo $PROJ | gsed -re 's/[a-zA-Z0-1\/]+\/([a-zA-Z0-9]+)/\1/'`
    echo $REMOTE_USER@$REMOTE:$REMOTE_PATH/$PROJ_NAME" => "$PROJ/..
    rsync -vr --update $EXCLUDES \
                $REMOTE_USER@$REMOTE:$REMOTE_PATH/$PROJ_NAME $PROJ/..
else
    echo $PROJ" => "$REMOTE:$REMOTE_PATH
    rsync -vr --update --del $EXCLUDES --copy-links \
    			$PROJ $REMOTE_USER@$REMOTE:$REMOTE_PATH
fi

exit 0
