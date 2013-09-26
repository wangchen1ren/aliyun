#!/bin/sh

bin=`dirname "$0"`
bin=`cd $bin; pwd`

. "$bin"/common-env.sh

# machine info
host=$1
root_passwd=$2
work_user="work"
work_passwd="work"

sshexec="$TOOLS_HOME/sshexec/bin/sshexec.sh"

WORKDIR=$ROOT_HOME/workdir
if [ ! -d $WORKDIR ]; then
    mkdir $WORKDIR
fi

function error() {
    func=$1
    echo "Error in $func." >&2
    echo "Please see $WORKDIR/$func.log and check manually!" >&2
    exit 1
}

function done() {
    echo "done."
}

#####################################################
#
# Initialize Base Configuration and User Account
#
#####################################################

# 1. update yum
function update_yum() {
    func="update_yum"
    echo -e "\033[32m[1/4] Update yum source ...\033[0m"
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
    echo -e "\033[32m[1/4] Update yum source done.\033[0m"
}

# 2. update gcc
function update_gcc() {
    func="update_gcc"
    echo -e "\033[32m[2/4] Update gcc ...\033[0m"
    cmd="sed -i 's/^exclude/#exclude/' /etc/yum.conf"
    cmd="$cmd && yum -y install gcc gcc-c++"
    cmd="$cmd && sed -i 's/^#exclude/exclude/' /etc/yum.conf"
    $sshexec root:$root_passwd@$host:~ "$cmd" >$WORKDIR/$func.log 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\033[32m[2/4] Update gcc done.\033[0m"
    else
        error "$func"
    fi
}

# 3. update libs
function update_libs() {
    func="update_libs"
    echo -e "\033[32m[3/4] Update dependent libraries ...\033[0m"
    # Note:
    #   nginx       : prce zlib
    #   memcached   : libevent
    lib_list="pcre-devel zlib-devel libevent-devel"
    echo "Library list: $lib_list"
    cmd="yum -y install $lib_list"
    $sshexec root:$root_passwd@$host:~ "$cmd" >$WORKDIR/$func.log 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\033[32m[3/4] Update dependent libraries done.\033[0m"
    else
        error "$func"
    fi

}

# 4. add work username
function add_work_user() {
    func="add_work_user"
    echo -e "\033[32m[4/4] Add work user ...\033[0m"
    cmd="adduser $work_user"
    cmd="$cmd && echo "$work_passwd" | passwd --stdin --force $work_user"
    $sshexec root:$root_passwd@$host:~ "$cmd" >$WORKDIR/$func.log 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\033[32m[4/4] Add work user done.\033[0m"
    elif grep "adduser: user $work_user exists" $WORKDIR/$func.log >/dev/null 2>&1; then
        echo -e "\033[32m[4/4] Work user already exists.\033[0m"
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
    echo
}

#####################################################
#
# Install Softwares
#
#####################################################

function make_env() {
    $sshexec $work_user:$work_passwd@$host:~ "mkdir -p ~/software"
    $sshexec -f $TOOLS_HOME/bash_profile.template \
        $work_user:$work_passwd@$host:~ "mv bash_profile.template .bash_profile"
}

function install() {
    i=$1
    n=$2
    name=$3
    echo -e "\033[32m[$i/$n] Install $name ...\033[0m"
    $sshexec $work_user:$work_passwd@$host:~/software "test -d $name"
    if [ $? -eq 0 ]; then
        echo -e "\033[32m[$i/$n] $name already exists.\033[0m"
    else
        $sshexec -f $SOFT_HOME/$name.tar.gz -d \
            $work_user:$work_passwd@$host:~/software "tar zxf $name.tar.gz"
    fi
    echo -e "\033[32m[$i/$n] Install $name done.\033[0m"
}

function install_softwares() {
    echo "*********************"
    echo "* Install Softwares *"
    echo "*********************"
    make_env
    soft_list=""
    n_soft=0
    for file in `ls $SOFT_HOME`; do
        soft=`basename $file .tar.gz`
        soft_list="$soft_list $soft"
        ((n_soft=$n_soft+1))
    done
    i=0
    for soft in $soft_list; do
        ((i=$i+1))
        install $i $n_soft $soft
    done
    echo
}

#####################################################
#
# Main
#
#####################################################

function main() {
    init_base_config_and_user_account
    install_softwares
}

main
