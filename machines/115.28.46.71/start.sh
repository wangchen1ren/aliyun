#!/bin/sh

#. ~/.bash_profile

/home/work/software/nginx-1.5.4/sbin/nginx -t \
&& /home/work/software/nginx-1.5.4/sbin/nginx \
&& sh /home/work/software/apache-tomcat-7.0.42/bin/startup.sh \
&& /home/work/software/memcached-1.4.15/bin/memcached -p 11211 -m 64m -d
exit $?
