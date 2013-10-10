#!/bin/sh

bin=`dirname "$0"`
bin=`cd $bin; pwd`

. "$bin"/common.sh "$@"

log=$LOGDIR/`basename $0 .sh`.log
echo >>$log
echo "====================================" >>$log
echo "`date`" >>$log
echo "====================================" >>$log


#####################################################
#
# Install Softwares
#
#####################################################

function make_env() {
    $sshexec $work_user:$work_passwd@$host:~ "mkdir -p ~/software" >>$log 2>&1
    $sshexec -f $TOOLS_HOME/bashrc.template \
        $work_user:$work_passwd@$host:~ \
        "mv bashrc.template .bashrc && cp .bashrc .bash_profile" >>$log 2>&1
}

function install() {
    i=$1
    n=$2
    name=$3
    echo -e "\033[32m[$i/$n] Install $name ...\033[0m"
    $sshexec $work_user:$work_passwd@$host:~/software "test -d $name" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\033[32m[$i/$n] $name already exists.\033[0m"
    else
        md5=`md5sum $SOFT_HOME/$name.tar.gz | awk '{print $1}'`
        $sshexec -f $SOFT_HOME/$name.tar.gz \
            $work_user:$work_passwd@$host:~/software \
            "md5sum $name.tar.gz" >.remote_md5 2>>$log
        remote_md5=`cat .remote_md5 | awk '{print $1}'`
        if [ "$md5" = "$remote_md5" ]; then
            echo -e "\033[32m[$i/$n]\033[0m Upload file done."
        else
            echo -e "\033[31m[$i/$n] Failed to upload $name.tar.gz\033[0m"
            exit 1
        fi
        $sshexec $work_user:$work_passwd@$host:~/software \
            "tar zxf $name.tar.gz && rm -f $name.tar.gz" >>$log 2>&1
        if [ $? -eq 0 ]; then
            echo -e "\033[32m[$i/$n] Complete install $name.\033[0m"
        else
            echo -e "\033[31m[$i/$n] Install $name error!\033[0m"
            exit 1
        fi
    fi
}

function install_softwares() {
    echo "******************************************************"
    echo "   Install Softwares on $work_user@$host "
    echo "******************************************************"

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
    install_softwares
}

main
