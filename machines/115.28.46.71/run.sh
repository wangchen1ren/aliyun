#!/bin/sh

dir=`dirname $0`
dir=`cd $dir; pwd`

WORK_ROOT=$dir


CMD=$1
shift

case $CMD in
    start)
        if [ -e $WORK_ROOT/start.sh ]; then
            sh $dir/start.sh
            exit $?
        fi
        ;;
    stop)
        if [ -e $WORK_ROOT/stop.sh ]; then
            sh $dir/stop.sh
            exit $?
        fi
        ;;
    *)
        usage
        exit 1
        ;;
esac
