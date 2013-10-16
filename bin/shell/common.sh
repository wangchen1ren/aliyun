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
if [ "X$bin" = "X" ]; then
    dir=`dirname "$this"`
    script=`basename "$this"`
    bin=`cd "$dir/.."; pwd`
fi
this="$dir/$script"

export NOAH_HOME=`dirname "$bin"`
export TOOLS_HOME=$NOAH_HOME/tools

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
        -d )
        export work_date="$2"
        shift; shift;
        continue
        ;;
        * )
        break
        ;;
    esac
done

export sshexec="$TOOLS_HOME/sshexec/bin/sshexec.sh"

if [ "X" = "X$work_date" ]; then
    work_date=`date +%Y%m%d`
fi

export DOWNLOAD_HOME=$NOAH_HOME/download/$work_date
export NOAH_UPDATE_CONF_DIR=$DOWNLOAD_HOME/config
export NOAH_UPDATE_APP_DIR=$DOWNLOAD_HOME/app
export NOAH_UPDATE_SOFTWARE_DIR=$DOWNLOAD_HOME/software
export NOAH_UPDATE_OTHER_DIR=$DOWNLOAD_HOME/other


export WORKDIR=$NOAH_HOME/workdir
export LOGDIR=$WORKDIR/log
export INSTANCEDIR=$WORKDIR/$work_date
if [ ! -d $LOGDIR ]; then
    mkdir -p $LOGDIR
fi

if [ ! -d $INSTANCEDIR ]; then
    mkdir -p $INSTANCEDIR
fi
