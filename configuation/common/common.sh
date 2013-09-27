#!/bin/sh

# Note:
#
#


common=`dirname $0`
common=`cd $common; pwd`

if [ "$dir" = "" ]; then
    echo "Error common"
    exit 1
fi

SOFT_ROOT="/home/work/software"

WORK_ROOT=$dir/..
SOFT=`basename $dir`
BIN_ROOT="$SOFT_ROOT/$SOFT"
