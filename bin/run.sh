#!/bin/sh

bin=`dirname "$0"`
bin=`cd $bin; pwd`

. "$bin"/common.sh

python deploy.py
