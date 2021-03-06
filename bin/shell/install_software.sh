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
    echo "<font color="#33CC00">[$i/$n] Install $name ...</font>" >>$log
    $sshexec $work_user:$work_passwd@$host:~/software "test -d $name" >>$log 2>&1
    if [ $? -eq 0 ]; then
        echo "<font color="#33CC00">[$i/$n] $name already exists.</font>" >>$log
    else
        md5=`md5sum $NOAH_UPDATE_SOFTWARE_DIR/$name.tar.gz | awk '{print $1}'`
        $sshexec -f $NOAH_UPDATE_SOFTWARE_DIR/$name.tar.gz \
            $work_user:$work_passwd@$host:~/software \
            "md5sum $name.tar.gz" >$bin/.tmp_remote_md5 2>>$log
        remote_md5=`cat $bin/.tmp_remote_md5 | awk '{print $1}'`
        if [ "$md5" = "$remote_md5" ]; then
            echo "<font color="#33CC00">[$i/$n]</font> Upload file done." >>$log
        else
            echo "<font color="#FF0000">[$i/$n] Failed to upload $name.tar.gz</font>" >>$log
            exit 1
        fi
        $sshexec $work_user:$work_passwd@$host:~/software \
            "tar zxf $name.tar.gz && rm -f $name.tar.gz" >>$log 2>&1
        if [ $? -eq 0 ]; then
            echo "<font color="#33CC00">[$i/$n] Complete install $name.</font>" >>$log
        else
            echo "<font color="#FF0000">[$i/$n] Install $name error!</font>" >>$log
            exit 1
        fi
    fi
}

function install_softwares() {
    echo "******************************************************" >>$log
    echo "   Install Softwares on $work_user@$host " >>$log
    echo "******************************************************" >>$log

    make_env
    soft_list=""
    n_soft=0
    for file in `ls $NOAH_UPDATE_SOFTWARE_DIR`; do
        soft=`basename $file .tar.gz`
        soft_list="$soft_list $soft"
        ((n_soft=$n_soft+1))
    done
    i=0
    for soft in $soft_list; do
        ((i=$i+1))
        install $i $n_soft $soft
    done
    echo >>$log
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
