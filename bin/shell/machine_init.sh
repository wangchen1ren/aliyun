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
    echo "<font color="#FF0000">Error in $func.</font>" >&2
    echo "<font color="#FF0000">Please see $log and check manually!</font>" >&2
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
    echo "<font color="#33CC00">[1/$TOTAL_STEPS] Update yum source ...</font>" >>$log
    $sshexec root:$root_passwd@$host:~ "test -f update_yum_source.done" >>$log 2>&1
    if [ $? -ne 0 ]; then
        $sshexec -f $TOOLS_HOME/update_yum_source.sh \
            root:$root_passwd@$host:~ \
            "bash update_yum_source.sh && touch update_yum_source.done" >>$log 2>&1
        if [ $? -ne 0 ]; then
            error "$func"
        fi
    fi
    echo "<font color="#33CC00">[1/$TOTAL_STEPS] Complete update yum source.</font>" >>$log
}

# 2. update gcc
function update_gcc() {
    func="update_gcc"
    echo "<font color="#33CC00">[2/$TOTAL_STEPS] Update gcc ...</font>" >>$log
    cmd="sed -i 's/^exclude/#exclude/' /etc/yum.conf"
    cmd="$cmd && yum -y install gcc gcc-c++"
    cmd="$cmd && sed -i 's/^#exclude/exclude/' /etc/yum.conf"
    $sshexec root:$root_passwd@$host:~ "$cmd" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo "<font color="#33CC00">[2/$TOTAL_STEPS] Complete update gcc.</font>" >>$log
    else
        error "$func"
    fi
}

# 3. update libs
function update_libs() {
    func="update_libs"
    echo "<font color="#33CC00">[3/$TOTAL_STEPS] Update dependent libraries ...</font>" >>$log
    #echo "<font color="#33CC00">[3/$TOTAL_STEPS] Update dependent libraries ...</font>" >>$log
    # Note:
    #   system      : lsof iptables
    #   nginx       : prce zlib
    #   memcached   : libevent
    lib_list="lsof iptables zip unzip pcre-devel zlib-devel libevent-devel"
    echo "Library list: $lib_list" >>$log
    cmd="yum -y install $lib_list"
    $sshexec root:$root_passwd@$host:~ "$cmd" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo "<font color="#33CC00">[3/$TOTAL_STEPS] Complete update dependent libraries.</font>" >>$log
    else
        error "$func"
    fi

}

# 4. mapping port 80 to 8080
function prerouting() {
    func="prerouting"
    echo "<font color="#33CC00">[4/$TOTAL_STEPS] Pre Routing ...</font>" >>$log
    $sshexec -f $TOOLS_HOME/prerouting.sh -d \
        root:$root_passwd@$host:~ "sh prerouting.sh" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo "<font color="#33CC00">[4/$TOTAL_STEPS] Complete pre routing.</font>" >>$log
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
