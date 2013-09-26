#!/bin/sh

dir=`dirname $0`
dir=`cd $dir; pwd`

WORKROOT=$dir/../..
TOOLSROOT=$WORKROOT/tools

function usage() {
    echo "usage: `basename $0` -u default_user -p default_pass host" >&2
}

if [ $# -lt 5 ]; then
    echo "ERROR: too few arguments" >&2
    usage >&2
    exit 1
fi

while getopts :u:p: OPTION; do
    case $OPTION in
    u)
        default_user="$OPTARG"
        ;;
    p)
        default_pass="$OPTARG"
        ;;
    \?)
        echo "ERROR: wrong option." >&2
        usage >&2
        exit 1
        ;;
    esac
done

shift `expr $OPTIND - 1`

host=$1

local_host=`hostname`
local_user=$default_user
local_pass=$default_pass

function formatUrl() {
    if echo "$1" | grep -E "^.+:.+@.+$" &>/dev/null; then
        echo "$1"
    else
        echo "$default_user:$default_pass@$1"
    fi
}

machine_name=$host
host_url=`formatUrl $machine_name`
echo "start to ssh $host_url...."
$TOOLSROOT/sshexec/bin/sshexec.sh $host_url:~ "rm -f .ssh/authorized_keys"
$TOOLSROOT/sshexec/bin/sshexec.sh -f "build_trust.py pexpect.py" -d $host_url:~ "python build_trust.py $local_user@$local_host $local_pass;rm -rf pexpect.pyc"
$TOOLSROOT/sshexec/bin/sshexec.sh $host_url:~ "cat ~/.ssh/id_rsa.pub">$HOME/.ssh/tmp.pub
cat $HOME/.ssh/tmp.pub >>$HOME/.ssh/authorized_keys

chmod 644 $HOME/.ssh/authorized_keys
chmod 700 $HOME/.ssh
chmod 711 $HOME
host_url=`formatUrl $machine_name`
echo "send to $host_url...."
$TOOLSROOT/sshexec/bin/sshexec.sh -f "$HOME/.ssh/authorized_keys" -d $host_url:~ "cat authorized_keys>.ssh/auth.tmp"
$TOOLSROOT/sshexec/bin/sshexec.sh $host_url:~ "chmod 700 .ssh;cd .ssh;cat auth.tmp >>authorized_keys;chmod 644 authorized_keys; chmod 711 ~"

