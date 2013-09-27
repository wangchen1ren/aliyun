#!/bin/sh

dir=`dirname $0`
dir=`cd $dir; pwd`

. $dir/../common/common.sh

CMD=$1
shift

case $CMD in
    start)
        sh $BIN_ROOT/bin/nginx start "$@"
        break
        ;;
    stop)
        sh $BIN_ROOT/bin/nginx stop "$@"
        break
    *)
        usage
        exit 1
        ;;
esac

