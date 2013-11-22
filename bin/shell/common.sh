#!/bin/sh

dir=`dirname "$0"`
dir=`cd $dir; pwd`

. "$dir"/env.sh "$@"

# Deal with arguments
export host=""
export root_passwd="root"
export work_user="work"
export work_passwd="work"
while [ "X$1" != "X" ]; do
    case "$1" in
        -h )
        export host="$2"
        shift; shift;
        continue
        ;;
        -r )
        export root_passwd="$2"
        shift; shift;
        continue
        ;;
        -u )
        export work_user="$2"
        shift; shift;
        continue
        ;;
        -p )
        export work_passwd="$2"
        shift; shift;
        continue
        ;;
        -d )
        export work_date="$2"
        shift; shift;
        continue
        ;;
        * )
        break
        ;;
    esac
done

