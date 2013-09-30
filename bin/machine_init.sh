#!/bin/sh

bin=`dirname "$0"`
bin=`cd $bin; pwd`

. "$bin"/common.sh "$@"

WORKDIR=$ROOT_HOME/workdir
if [ ! -d $WORKDIR ]; then
    mkdir $WORKDIR
fi

function error() {
    func=$1
    echo -e "\033[31mError in $func.\033[0m" >&2
    echo -e "\033[31mPlease see $WORKDIR/$func.log and check manually!\033[0m" >&2
    exit 1
}

#####################################################
#
# Initialize Base Configuration and User Account
#
#####################################################

# 1. update yum
function update_yum() {
    func="update_yum"
    echo -e "\033[32m[1/5] Update yum source ...\033[0m"
    $sshexec root:$root_passwd@$host:~ "test -f update_yum_source.done"
    if [ $? -ne 0 ]; then
        $sshexec -f $TOOLS_HOME/update_yum_source.sh \
            root:$root_passwd@$host:~ \
            "bash update_yum_source.sh && touch update_yum_source.done" \
            >$WORKDIR/$func.log 2>&1
        if [ $? -ne 0 ]; then
            error "$func"
        fi
    fi
    echo -e "\033[32m[1/5] Update yum source done.\033[0m"
}

# 2. update gcc
function update_gcc() {
    func="update_gcc"
    echo -e "\033[32m[2/5] Update gcc ...\033[0m"
    cmd="sed -i 's/^exclude/#exclude/' /etc/yum.conf"
    cmd="$cmd && yum -y install gcc gcc-c++"
    cmd="$cmd && sed -i 's/^#exclude/exclude/' /etc/yum.conf"
    $sshexec root:$root_passwd@$host:~ "$cmd" >$WORKDIR/$func.log 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\033[32m[2/5] Update gcc done.\033[0m"
    else
        error "$func"
    fi
}

# 3. update libs
function update_libs() {
    func="update_libs"
    echo -e "\033[32m[3/5] Update dependent libraries ...\033[0m"
    # Note:
    #   nginx       : prce zlib
    #   memcached   : libevent
    lib_list="lsof pcre-devel zlib-devel libevent-devel iptables"
    echo "Library list: $lib_list"
    cmd="yum -y install $lib_list"
    $sshexec root:$root_passwd@$host:~ "$cmd" >$WORKDIR/$func.log 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\033[32m[3/5] Update dependent libraries done.\033[0m"
    else
        error "$func"
    fi

}

# 4. add work username
function add_work_user() {
    func="add_work_user"
    echo -e "\033[32m[4/5] Add work user ...\033[0m"
    cmd="adduser $work_user"
    cmd="$cmd && echo "$work_passwd" | passwd --stdin --force $work_user"
    $sshexec root:$root_passwd@$host:~ "$cmd" >$WORKDIR/$func.log 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\033[32m[4/5] Add work user done.\033[0m"
    elif grep "adduser: user $work_user exists" $WORKDIR/$func.log >/dev/null 2>&1; then
        echo -e "\033[32m[4/5] Work user already exists.\033[0m"
    else
        error "$func"
    fi
}

function prerouting() {
    func="prerouting"
    echo -e "\033[32m[5/5] Pre Routing ...\033[0m"
    $sshexec -f $TOOLS_HOME/prerouting.sh -d \
        root:$root_passwd@$host:~ "sh prerouting.sh"
    if [ $? -eq 0 ]; then
        echo -e "\033[32m[4/5] Complete pre routing.\033[0m"
    else
        error "$func"
    fi
}

function init_base_config_and_user_account() {
    echo "**************************************************"
    echo "* Initialize Base Configuration and User Account *"
    echo "**************************************************"
    update_yum
    update_gcc
    update_libs
    add_work_user
    prerouting
    echo
}

#####################################################
#
# Main
#
#####################################################

function main() {
    init_base_config_and_user_account
}

main
