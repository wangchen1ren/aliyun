#!/bin/sh

bin=`dirname "$0"`
bin=`cd $bin; pwd`

. "$bin"/shell/env.sh

CMD=$1
shift
if [ "X$CMD" = "X" ]; then
    CMD="all"
fi

function prepare() {
    python $bin/py/prepare.py "$@"
}

function test() {
    prepare "$@"
    python $bin/py/test.py "$@"
}

function all() {
    prepare "$@"
    python $bin/py/run.py "$@"
}

function monitor() {
    python $bin/py/monitor.py "$@"
}

case $CMD in
    c|-c|clean)     sh $bin/clean.sh ;;
    p|-p|prepare)   prepare "$@";;
    t|-t|test)      test "$@" ;;
    m|-m|monitor)   monitor "$@" ;;
    a|-a|all)       all "$@" ;;
esac

