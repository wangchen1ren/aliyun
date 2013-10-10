#!/bin/sh
export LANG=en_US.UTF-8

# resolve links - $0 may be a softlink
this="$0"
while [ -h "$this" ]; do
  ls=`ls -ld "$this"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '.*/.*' > /dev/null; then
    this="$link"
  else
    this=`dirname "$this"`/"$link"
  fi
done

# convert relative path to absolute path
bin=`dirname "$this"`
script=`basename "$this"`
bin=`cd "$bin"; pwd`
this="$bin/$script"

export NOAH_HOME=`dirname "$bin"`
export TOOLS_HOME=$NOAH_HOME/tools
export SOFT_HOME=$NOAH_HOME/software

if [ $# -gt 1 ]; then
  if [ "--config" = "$1" ]; then
    shift
    confdir=$1
    shift
    NOAH_CONF_DIR=$confdir
  fi
fi

# Allow alternate conf dir location.
export NOAH_CONF_DIR="${NOAH_CONF_DIR:-$NOAH_HOME/conf}"

if [ -f "${NOAH_CONF_DIR}/env.sh" ]; then
  . "${NOAH_CONF_DIR}/env.sh"
fi

# Deal with arguments
export host=""
export root_passwd="root"
export work_user="work"
export work_passwd="work"
while [ "X$1" != "X" ]; do
    case "$1" in
        -h )
        export host="$2"
        shift; shift;
        continue
        ;;
        -r )
        export root_passwd="$2"
        shift; shift;
        continue
        ;;
        -u )
        export work_user="$2"
        shift; shift;
        continue
        ;;
        -p )
        export work_passwd="$2"
        shift; shift;
        continue
        ;;
        * )
        break
        ;;
    esac
done

export sshexec="$TOOLS_HOME/sshexec/bin/sshexec.sh"

WORKDIR=$NOAH_HOME/workdir
LOGDIR=$WORKDIR/log
INSTANCEDIR=$WORKDIR/instance
if [ ! -d $LOGDIR ]; then
    mkdir -p $LOGDIR
fi

if [ ! -d $INSTANCEDIR ]; then
    mkdir -p $INSTANCEDIR
fi
