#!/bin/sh

bin=`dirname "$0"`
bin=`cd $bin; pwd`

. "$bin"/shell/common.sh

rm -rf $WORKDIR $DOWNLOAD_HOME $bin/py/*.pyc $bin/.tmp*
