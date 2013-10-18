#!/bin/sh

dir=`dirname $0`
dir=`cd $dir; pwd`

user=$1

basedir=$dir
softdir=/home/$user/software

BAK_SUFFIX='.backup'

for f in `find . -type f`; do
    dirname=`dirname $f`
    if [ "$dirname" = "." ]; then
        continue
    else
        if [ -f $softdir/$f ]; then
            cp $softdir/$f "${f}${BAK_SUFFIX}"
        fi
        sdir=`dirname $softdir/$f`
        if [ ! -d $sdir ]; then
            mkdir -p $sdir
        fi
        cp $f $softdir/$f
    fi
done
