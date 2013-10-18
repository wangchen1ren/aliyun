#!/bin/sh

dir=`dirname $0`
dir=`cd $dir; pwd`

. "$dir"/common.sh "$@"

log=$LOGDIR/`basename $0 .sh`.log
echo >>$log
echo "====================================" >>$log
echo "`date`" >>$log
echo "====================================" >>$log

#####################################################
#
# Check Machine
#
#####################################################

function check_node() {
    echo -e "\033[32m[1/1] Check Node $work_user@$host ...\033[0m" >>$log
    cmd="sh noah_monitor.sh"
    $sshexec -f $INSTANCEDIR/$work_user@$host/noah_monitor.sh -d \
            $work_user:$work_passwd@$host:~ "$cmd" >>$log 2>&1
    if [ $? -ne 0 ]; then
        echo -e "<font color="#FF0000">Node $work_user@$host.\033[0m error" >&2
        exit 1
    fi
    echo >>$log
}

#####################################################
#
# Main
#
#####################################################

function main() {
    check_node
}

main
