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

export ROOT_HOME=`dirname "$bin"`
export TOOLS_HOME=$ROOT_HOME/tools
export SOFT_HOME=$ROOT_HOME/software

if [ $# -gt 1 ]; then
  if [ "--config" = "$1" ]; then
    shift
    confdir=$1
    shift
    CONF_DIR=$confdir
  fi
fi

# Allow alternate conf dir location.
export CONF_DIR="${CONF_DIR:-$ROOT_HOME/conf}"

if [ -f "${CONF_DIR}/env.sh" ]; then
  . "${CONF_DIR}/env.sh"
fi
