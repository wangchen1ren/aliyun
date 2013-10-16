#!/bin/sh

dir=`dirname "$0"`
dir=`cd $dir; pwd`

. "$dir"/common.sh "$@"

log=$LOGDIR/`basename $0 .sh`.log
echo >>$log
echo "====================================" >>$log
echo "`date`" >>$log
echo "====================================" >>$log


#####################################################
#
# Create Work User Account
#
#####################################################

function create_work_user() {
    echo "******************************************************" >>$log
    echo "   Creating user $work_user@$host " >>$log
    echo "******************************************************" >>$log
 
    echo -e "\033[32m[1/1] Create work user $work_user@$host ...\033[0m" >>$log
    cmd="adduser $work_user"
    cmd="$cmd && echo "$work_passwd" | passwd --stdin --force $work_user"
    $sshexec root:$root_passwd@$host:~ "$cmd" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\033[32m[1/1] Complete Create work user $work_user@$host.\033[0m" >>$log
    elif tail -n 1 $log | grep "adduser: user $work_user exists" >/dev/null 2>&1; then
        echo -e "\033[32m[1/1] Work user $work_user@$host already exists.\033[0m" >>$log
    else
        echo -e "\033[31mError in creating $work_user@$host.\033[0m" >&2
        echo -e "\033[31mPlease see $log and check manually!\033[0m" >&2
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
    create_work_user
}

main
