#!/bin/sh

bin=`dirname "$0"`
bin=`cd $bin; pwd`

. "$bin"/common.sh

rm -rf $WORKDIR $bin/*.pyc $bin/.tmp*
