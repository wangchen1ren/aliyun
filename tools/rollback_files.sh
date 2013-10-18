#!/bin/sh

dir=`dirname $0`
dir=`cd $dir; pwd`

user=$1

basedir=$dir
softdir=/home/$user/software
BAK_SUFFIX='.backup'

#
for f in `find . -type f`; do
    dirname=`dirname $f`
    if [ "$dirname" = "." ]; then
        continue
    fi

    name=`basename $f`
    if [ "`basename $f $BAK_SUFFIX`" = "$name" ]; then
        if [ ! -f "${f}${BAK_SUFFIX}" ]; then
            # new file
            if [ -f "$softdir/$f" ]; then
                rm -f "$softdir/$f"
            fi
        else
            # put .bak file back
            cp ${f}${BAK_SUFFIX} $softdir/$f
        fi
    fi
done
