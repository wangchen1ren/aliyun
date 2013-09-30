#!/bin/sh

/home/work/software/nginx-1.5.4/sbin/nginx -s stop
ps xf | grep nginx | awk '{print $1}' | xargs kill -9 2>/dev/null
ps xf | grep tomcat | awk '{print $1}' | xargs kill -9 2>/dev/null
ps xf | grep memcached | awk '{print $1}' | xargs kill -9 2>/dev/null
exit 0
