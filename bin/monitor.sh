#!/bin/sh

bin=`dirname "$0"`
bin=`cd $bin; pwd`

. "$bin"/shell/common.sh "$@"

python $bin/py/monitor.py $work_date "$@"
