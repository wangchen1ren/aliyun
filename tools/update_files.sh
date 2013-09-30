#!/bin/sh

dir=`dirname $0`
dir=`cd $dir; pwd`

basedir=$dir
softdir=/home/work/software

for f in `find . -type f`; do
    dirname=`dirname $f`
    if [ "$dirname" = "." ]; then
        continue
    else
        if [ -f $softdir/$f ]; then
            cp $softdir/$f $f.bak
        fi
        cp $f $softdir/$f
    fi
done