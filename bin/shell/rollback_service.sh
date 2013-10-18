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
# Rollback Softwares
#
#####################################################

export date=$work_date

function stop() {
    echo "[1/3] Stopping service ..." >>$log
    $sshexec $work_user:$work_passwd@$host:/home/$work_user/deploy/$date \
        "sh noah_stop.sh" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo "[1/3] Services stopped." >>$log
    else
        echo "<font color="#FF0000">Error in stopping services on $work_user@$host.</font>" >&2
        exit 1
    fi
}

function rollback_files() {
    echo "[2/3] Updating files ..." >>$log
    $sshexec -f $TOOLS_HOME/rollback_files.sh -d \
        $work_user:$work_passwd@$host:/home/$work_user/deploy/$date \
        "sh rollback_files.sh $work_user" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo "[2/3] Update files success." >>$log
    else
        echo "<font color="#FF0000">Error in updating files on $work_user@$host.</font>" >&2
        exit 1
    fi
}

function start() {
    echo "[3/3] Starting services ..." >>$log
    $sshexec $work_user:$work_passwd@$host:/home/$work_user/deploy/$date \
        "sh noah_start.sh" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo "[3/3] Start services success" >>$log
    else
        echo "<font color="#FF0000">Error in starting services on $work_user@$host.</font>" >&2
        exit 1
    fi
}

function start_service() {
    if [ ! -d "$INSTANCEDIR/$work_user@$host" ]; then
        echo "Config of $work_user@$host not found!" >&2
        exit 1
    fi
    echo "******************************************************" >>$log
    echo "   Rollback services on $work_user@$host ... " >>$log
    echo "******************************************************" >>$log

    stop
    rollback_files
    start

    echo >>$log
}

#####################################################
#
# Main
#
#####################################################

function main() {
    start_service
}

main
