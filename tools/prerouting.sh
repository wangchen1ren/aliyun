#!/bin/sh

iptables -t mangle -I PREROUTING -p tcp --dport 80 -j MARK --set-mark 8888
iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8888
iptables -I INPUT -p tcp --dport 8080 -m mark --mark 8888 -j ACCEPT
service iptables save
service iptables restart
