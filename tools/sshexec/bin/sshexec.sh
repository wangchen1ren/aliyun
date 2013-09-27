#!/usr/bin/env bash

sh_name=`basename $0`
work_dir=`dirname $0`
work_dir=`cd "$work_dir";pwd`
export PATH=$PATH:$work_dir

function usage() {
    echo "usage: `basename $0` <-f file ...> <-hdg> user:pass@hostname:path command|target" >&2
    echo "    -f file    the files need to exec the command, will be scp to remote's path" >&2
    echo "    -g         scp from remote path to target" >&2
    echo "    -d         delete files after exec command" >&2
    echo "    -h         Show help" >&2
}

delete="false"
isMkdir="false"
hasFile="false"
isGet="false"

while getopts :dhgf: OPTION; do
    case $OPTION in 
    f)
        files="$OPTARG $files"
        hasFile="true"
        ;;
    d)
        delete="true"
        ;;
    g)
        isGet="true"
        ;;
    h)
        usage
        exit 0
        ;;
    \?)
        echo "ERROR: wrong option." >&2
        usage >&2
        exit 1
        ;;
    esac
done

# shift argument
shift `expr $OPTIND - 1`

if [ $# -lt 2 ]; then
    echo "ERROR: both user:pass@hostname:workpath and command|target are needed" >&2
    usage >&2
    exit 1
elif [ $# -gt 2 ]; then
    echo "ERROR: wrong arguments" >&2
    usage >&2
    exit 1
fi

sshexec_uri=$1
command=$2

#echo "files:$files"
#echo "sshexec_uri=$sshexec_uri"
#echo "command=$command"

# check sshexec_uri's format
if ! echo "$sshexec_uri" | grep -E "^.+:.+@.+:.+$" &>/dev/null; then
    echo "ERROR: wrong argument format: must be user:pass@hostname:workpath" >&2
    usage >&2
    exit 1
fi

for file in $files; do
    if [ ! -e $file ]; then
        echo "ERROR: cannot find the $file" >&2
        usage >&2
        exit 1
    fi
done

# parse
user=${sshexec_uri%"@"*}
pass=${user#*":"}
user=${user%%":"*}

hostname=${sshexec_uri##*"@"}
workpath=${hostname##*":"}
hostname=${hostname%":"*}

# if get remote files
if [ "$isGet" = "true" ]; then
    sshpass -p "$pass" scp -r -o StrictHostKeyChecking=no "$user@$hostname:$workpath" $command
    exit $?
fi

# send files
if ! sshpass -p "$pass" ssh "$user@$hostname" -o StrictHostKeyChecking=no "test -d $workpath"
then
    if ! sshpass -p "$pass" ssh "$user@$hostname" -o StrictHostKeyChecking=no "mkdir -p $workpath"
    then
        exit 1
    fi
    isMkdir="true"
fi

if [ $hasFile = "true" ]; then
    sshpass -p "$pass" scp -r -o StrictHostKeyChecking=no $files "$user@$hostname:$workpath"
fi

# exec command
sshpass -p "$pass" ssh "$user@$hostname" -o StrictHostKeyChecking=no "cd $workpath && $command"
exitcode=$?

# if delete files
if [ $delete = "true" ]; then
    if [ $isMkdir = "true" ]; then
        deletePath=`echo $workpath | sed s/\.$//`
        sshpass -p "$pass" ssh "$user@$hostname" -o StrictHostKeyChecking=no "rm -rf $deletePath"
    elif [ $hasFile = "true" ]; then
        flist=""
        for f in $files; do
            f_basename=`basename $f`
            flist="$flist $f_basename"
        done
        files=$flist
        sshpass -p "$pass" ssh "$user@$hostname" -o StrictHostKeyChecking=no "cd $workpath && rm -rf $files"
    fi
fi

# remove temp core.xxx files
rm -f ./core.*
exit $exitcode
