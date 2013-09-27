#!/bin/sh

dir=`dirname $0`
dir=`cd $dir; pwd`

cp /home/work/software/nginx-1.5.4/conf/nginx.conf $dir/nginx-1.5.4/conf/nginx.conf.bak \
&& cp $dir/nginx-1.5.4/conf/nginx.conf /home/work/software/nginx-1.5.4/conf/nginx.conf \
&& cp $dir/nginx-1.5.4/conf/proxy.conf /home/work/software/nginx-1.5.4/conf/proxy.conf \
&& cp /home/work/software/apache-tomcat-7.0.42/conf/server.xml $dir/apache-tomcat-7.0.42/conf/server.xml.bak \
&& cp $dir/apache-tomcat-7.0.42/conf/server.xml /home/work/software/apache-tomcat-7.0.42/conf/server.xml
exit $?
