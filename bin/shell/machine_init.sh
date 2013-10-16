#!/bin/sh

dir=`dirname "$0"`
dir=`cd $dir; pwd`

. "$dir"/common.sh "$@"

log=$LOGDIR/`basename $0 .sh`.log
echo >>$log
echo "====================================" >>$log
echo "`date`" >>$log
echo "====================================" >>$log

function error() {
    func=$1
    echo -e "\033[31mError in $func.\033[0m" >&2
    echo -e "\033[31mPlease see $log and check manually!\033[0m" >&2
    exit 1
}

#####################################################
#
# Initialize Base Configuration
#
#####################################################

export TOTAL_STEPS=4

# 1. update yum
function update_yum() {
    func="update_yum"
    echo -e "\033[32m[1/$TOTAL_STEPS] Update yum source ...\033[0m" >>$log
    $sshexec root:$root_passwd@$host:~ "test -f update_yum_source.done" >>$log 2>&1
    if [ $? -ne 0 ]; then
        $sshexec -f $TOOLS_HOME/update_yum_source.sh \
            root:$root_passwd@$host:~ \
            "bash update_yum_source.sh && touch update_yum_source.done" >>$log 2>&1
        if [ $? -ne 0 ]; then
            error "$func"
        fi
    fi
    echo -e "\033[32m[1/$TOTAL_STEPS] Complete update yum source.\033[0m" >>$log
}

# 2. update gcc
function update_gcc() {
    func="update_gcc"
    echo -e "\033[32m[2/$TOTAL_STEPS] Update gcc ...\033[0m" >>$log
    cmd="sed -i 's/^exclude/#exclude/' /etc/yum.conf"
    cmd="$cmd && yum -y install gcc gcc-c++"
    cmd="$cmd && sed -i 's/^#exclude/exclude/' /etc/yum.conf"
    $sshexec root:$root_passwd@$host:~ "$cmd" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\033[32m[2/$TOTAL_STEPS] Complete update gcc.\033[0m" >>$log
    else
        error "$func"
    fi
}

# 3. update libs
function update_libs() {
    func="update_libs"
    echo -e "\033[32m[3/$TOTAL_STEPS] Update dependent libraries ...\033[0m" >>$log
    # Note:
    #   system      : lsof iptables
    #   nginx       : prce zlib
    #   memcached   : libevent
    lib_list="lsof iptables pcre-devel zlib-devel libevent-devel"
    echo "Library list: $lib_list" >>$log
    cmd="yum -y install $lib_list"
    $sshexec root:$root_passwd@$host:~ "$cmd" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\033[32m[3/$TOTAL_STEPS] Complete update dependent libraries.\033[0m" >>$log
    else
        error "$func"
    fi

}

# 4. mapping port 80 to 8080
function prerouting() {
    func="prerouting"
    echo -e "\033[32m[4/$TOTAL_STEPS] Pre Routing ...\033[0m" >>$log
    $sshexec -f $TOOLS_HOME/prerouting.sh -d \
        root:$root_passwd@$host:~ "sh prerouting.sh" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\033[32m[4/$TOTAL_STEPS] Complete pre routing.\033[0m" >>$log
    else
        error "$func"
    fi
}

function init_base_config() {
    echo "******************************************************" >>$log
    echo "   Initialize Base Configuration on $host " >>$log
    echo "******************************************************" >>$log
    update_yum
    update_gcc
    update_libs
    prerouting
    echo >>$log
}

#####################################################
#
# Main
#
#####################################################

function main() {
    init_base_config
}

main
