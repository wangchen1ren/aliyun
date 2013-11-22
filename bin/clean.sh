#!/bin/sh

bin=`dirname "$0"`
bin=`cd $bin; pwd`

. "$bin"/shell/env.sh "$@"

rm -rf $WORKDIR $bin/py/*.pyc $bin/.tmp*
