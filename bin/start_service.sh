#!/bin/sh

bin=`dirname $0`
bin=`cd $bin; pwd`

. "$bin"/common.sh "$@"

date=`date +%Y%m%d`

function upload_files() {
    # gen local md5
    cd $MACHINE_HOME/$host
    find . -type f | xargs md5sum >.local_md5
    cd $bin && mv $MACHINE_HOME/$host/.local_md5 $bin/
    # upload file and gen remote md5
    $sshexec -f $MACHINE_HOME/$host \
        $work_user:$work_passwd@$host:~/deploy \
        "rm -rf $date && mv $host $date && cd $date && find . -type f | xargs md5sum" >.remote_md5
    # check if upload successful
    if diff .local_md5 .remote_md5; then
        echo "upload file done."
    else
        echo "fail"
        exit 1
    fi
}

function stop_services() {
    $sshexec $work_user:$work_passwd@$host:~/deploy/$date "sh stop.sh"
    if [ $? -eq 0 ]; then
        echo "Stop services success"
    else
        echo "error in stop services"
        exit 1
    fi
}

function update_files() {
    $sshexec -f $TOOLS_HOME/update_files.sh -d \
        $work_user:$work_passwd@$host:~/deploy/$date "sh update_files.sh"
    if [ $? -eq 0 ]; then
        echo "update files success"
    else
        echo "error update files"
        exit 1
    fi
}

function start_services() {
    #$sshexec $work_user:$work_passwd@$host:~/deploy/$date "env"
    $sshexec $work_user:$work_passwd@$host:~/deploy/$date "sh start.sh"
    if [ $? -eq 0 ]; then
        echo "Start services success"
    else
        echo "error in start services"
        exit 1
    fi
}

function main() {
    echo -e "\033[32m===========================================\033[0m"
    echo -e "\033[32m= Start services on $host ...\033[0m"
    echo -e "\033[32m===========================================\033[0m"

    upload_files
    stop_services
    update_files
    start_services

    echo -e "\033[32m===========================================\033[0m"
    echo -e "\033[32m= Complete $host.\033[0m"
    echo -e "\033[32m===========================================\033[0m"
}

main
