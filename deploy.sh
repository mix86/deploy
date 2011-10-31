#!/usr/bin/env bash

# deploy settings
REMOTE=""
REMOTE_PATH=""
REMOTE_USER=""
EXCLUDES=""
UPDATE_REMOTE=false
DELETE_EXCLUDED=true

# default excludes
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
 --exclude=*.sublime-workspace
"
REVERSE=false
DRY_RUN=""
PROJECT=`pwd`
SED="sed -Ee"

retry=0
until [[ -f $PROJECT/.deploy ]]
do
    if [[ $retry -gt 32 ]]; then
        echo "Can't find \".deploy\" file" >&2
        exit 1
    fi
    PROJECT="$PROJECT/.."
    retry=$(($retry+1))
done

cd $PROJECT
PROJECT=`pwd`

. $PROJECT/.deploy

EXCLUDES="$EXCLUDES $DEFAULT_EXCLUDES"

while [ $1 ]
do
    case $1 in
        "--dry" )
            echo "This is dry run. No real sync executed."
            DRY_RUN="-n"
            ;;
        "--reverse" )
            REVERSE=true
            ;;
        "--with"*)
            WITH=`echo $1 | $SED 's/--with=(.+)/\1/g'`
            EXCLUDES=`echo $EXCLUDES | tr " " "\n" | grep -v $WITH`
            ;;
        * )
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
    shift
done

if [[ -z $REMOTE_USER ]]; then
	REMOTE_USER=$USER
fi

OPT_UPDATE=""
if $UPDATE_REMOTE ; then
    OPT_UPDATE="--update"
fi
DEL_EX=""
if $DELETE_EXCLUDED ; then
    DEL_EX="--delete-excluded"
fi

if $REVERSE ; then
    PROJECT_NAME=`echo $PROJECT | $SED 's/[a-zA-Z0-1\/]+\/([a-zA-Z0-9]+)/\1/'`
    echo $REMOTE_USER@$REMOTE:$REMOTE_PATH/$PROJECT_NAME" => "$PROJECT/..
    rsync -rv $DRY_RUN $OPT_UPDATE --executability $EXCLUDES \
        $REMOTE_USER@$REMOTE:$REMOTE_PATH/$PROJECT_NAME $PROJECT/..
else
    echo $PROJECT" => "$REMOTE:$REMOTE_PATH
    rsync -rvL $DRY_RUN $OPT_UPDATE $DEL_EX --delete --force --executability \
        $EXCLUDES $PROJECT $REMOTE_USER@$REMOTE:$REMOTE_PATH
fi

exit 0
