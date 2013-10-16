#!/bin/sh

bin=`dirname "$0"`
bin=`cd $bin; pwd`

. "$bin"/shell/common.sh

python $bin/py/download.py "$@"
python $bin/py/deploy.py "$@"
