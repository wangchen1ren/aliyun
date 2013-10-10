#!/bin/sh

bin=`dirname "$0"`
bin=`cd $bin; pwd`

. "$bin"/common.sh

sh $bin/clean.sh
python deploy.py
