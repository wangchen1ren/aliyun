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
# Config and Start Softwares
#
#####################################################

export date=`date +%Y%m%d`

function upload_files() {
    echo "[1/4] Uploading files ..."
    # gen local md5
    cd $INSTANCEDIR/$work_user@$host
    find . -type f | xargs md5sum | sort >../.tmp_local_md5 2>/dev/null
    cd $bin && mv $INSTANCEDIR/.tmp_local_md5 $bin/
    # upload file and gen remote md5
    cmd="rm -rf $date && mv $work_user@$host $date"
    cmd="$cmd && cd $date && find . -type f | xargs md5sum | sort"
    $sshexec -f $INSTANCEDIR/$work_user@$host \
        $work_user:$work_passwd@$host:/home/$work_user/deploy \
        "$cmd" >$bin/.tmp_remote_md5 2>>$log
    # check if upload successful
    echo "[1/4] Checking md5sum ..."
    if diff $bin/.tmp_local_md5 $bin/.tmp_remote_md5 >>$log 2>&1; then
        echo "[1/4] Upload file done."
    else
        echo -e "\033[31mError in uploading files to $work_user@$host.\033[0m" >&2
        exit 1
    fi
}

function stop() {
    echo "[2/4] Stopping current service ..."
    $sshexec $work_user:$work_passwd@$host:/home/$work_user/deploy/$date \
        "sh noah_stop.sh" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo "[2/4] Services stopped."
    else
        echo -e "\033[31mError in stopping services on $work_user@$host.\033[0m" >&2
        exit 1
    fi
}

function update_files() {
    echo "[3/4] Updating files ..."
    $sshexec -f $TOOLS_HOME/update_files.sh -d \
        $work_user:$work_passwd@$host:/home/$work_user/deploy/$date \
        "sh update_files.sh $work_user" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo "[3/4] Update files success."
    else
        echo -e "\033[31mError in updating files on $work_user@$host.\033[0m" >&2
        exit 1
    fi
}

function start() {
    echo "[4/4] Starting services ..."
    $sshexec $work_user:$work_passwd@$host:/home/$work_user/deploy/$date \
        "sh noah_start.sh" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo "[4/4] Start services success"
    else
        echo -e "\033[31mError in starting services on $work_user@$host.\033[0m" >&2
        exit 1
    fi
}

function start_service() {
    if [ ! -d "$INSTANCEDIR/$work_user@$host" ]; then
        echo "Config of $work_user@$host not found!" >&2
        exit 1
    fi
    echo "******************************************************"
    echo "   Start services on $work_user@$host ... "
    echo "******************************************************"

    upload_files
    stop
    update_files
    start

    echo
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
