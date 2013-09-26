#!/bin/sh

dir=`dirname $0`
dir=`cd $dir; pwd`

WORKROOT=$dir/../..
TOOLSROOT=$WORKROOT/tools

function usage() {
    echo "usage: `basename $0` -u default_user -p default_pass hostlistfile" >&2
}

if [ $# -lt 5 ]; then
    echo "ERROR: too few arguments" >&2
    usage >&2
    exit 1
fi

while getopts :u:p: OPTION; do
    case $OPTION in
    u)
        default_user="$OPTARG"
        ;;
    p)
        default_pass="$OPTARG"
        ;;
    \?)
        echo "ERROR: wrong option." >&2
        usage >&2
        exit 1
        ;;
    esac
done

shift `expr $OPTIND - 1`

hostlist=$1

for machine_name in `cat $hostlist`; do
    sh $dir/trust.sh -u $default_user -p $default_pass $machine_name
done
