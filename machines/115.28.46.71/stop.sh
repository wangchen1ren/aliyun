#!/bin/sh

/home/work/software/nginx-1.5.4/sbin/nginx -s stop
ps xf | grep nginx | awk '{print $1}' | xargs kill -9
ps xf | grep tomcat | awk '{print $1}' | xargs kill -9
#sh /home/work/software/apache-tomcat-7.0.42/bin/shutdown.sh
exit 0
