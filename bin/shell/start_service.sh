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
    echo -e "\033[32m[1/4] Uploading files ...\033[0m" >>$log
    echo "Upload file list to $work_user@$host:" >>$log
    find $INSTANCEDIR/$work_user@$host -type f >>$log
    echo "" >>$log
    # gen local md5
    cd $INSTANCEDIR/$work_user@$host
    find . -type f | xargs md5sum | sort >../.tmp_local_md5 2>/dev/null
    cd $bin && mv $INSTANCEDIR/.tmp_local_md5 $bin/
    # upload file and gen remote md5
    cmd="rm -rf $date && mv $work_user@$host $date"
    cmd="$cmd && cd $date && find . -type f | xargs md5sum | sort"
    echo "[1/4] uploading $INSTANCEDIR/$work_user@$host" \
        "to $work_user@$host:/home/$work_user/deploy" >>$log
    $sshexec -f $INSTANCEDIR/$work_user@$host \
        $work_user:$work_passwd@$host:/home/$work_user/deploy \
        "$cmd" >$bin/.tmp_remote_md5 2>>$log
    # check if upload successful
    echo "[1/4] Checking files md5sum ..." >>$log
    if diff $bin/.tmp_local_md5 $bin/.tmp_remote_md5 >>$log 2>&1; then
        echo "\033[32m[1/4] Upload file complete.\033[0m" >>$log
    else
        echo -e "\033[31mError in uploading files to $work_user@$host.\033[0m" >&2
        exit 1
    fi
}

function stop() {
    echo "[2/4] Stopping current service ..." >>$log
    $sshexec $work_user:$work_passwd@$host:/home/$work_user/deploy/$date \
        "sh noah_stop.sh" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo "[2/4] Services stopped." >>$log
    else
        echo -e "\033[31mError in stopping services on $work_user@$host.\033[0m" >&2
        exit 1
    fi
}

function update_files() {
    echo "[3/4] Updating files ..." >>$log
    $sshexec -f $TOOLS_HOME/update_files.sh -d \
        $work_user:$work_passwd@$host:/home/$work_user/deploy/$date \
        "sh update_files.sh $work_user" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo "[3/4] Update files success." >>$log
    else
        echo -e "\033[31mError in updating files on $work_user@$host.\033[0m" >&2
        exit 1
    fi
}

function start() {
    echo "[4/4] Starting services ..." >>$log
    $sshexec $work_user:$work_passwd@$host:/home/$work_user/deploy/$date \
        "sh noah_start.sh" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo "[4/4] Start services success" >>$log
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
    echo "******************************************************" >>$log
    echo "   Start services on $work_user@$host ... " >>$log
    echo "******************************************************" >>$log

    upload_files
    stop
    update_files
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
