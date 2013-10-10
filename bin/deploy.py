#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

import sys
import os
import subprocess

from constants import *
from noah_conf import *
from nginx import Nginx
from tomcat import Tomcat
from memcached import Memcached

def parse_node(conf, node):
    password = conf.get_password(node['host'], node['user'])
    return [node['host'], node['user'], password]

def call_shell(conf, node, script_file):
    host, user, password = parse_node(conf, node)
    root_password = conf.get_password(host, 'root')
    script = os.path.join(NOAH_BIN_DIR, script_file)
    cmd = "sh %s -h %s -r %s -u %s -p %s" % (script, host,
            root_password, user, password)
    print cmd
    '''
    ret = subprocess.call(cmd, shell = True)
    if ret != 0:
        sys.exit(ret)
    '''
    pass

def init_machines(conf):
    hosts = []
    for node in conf.get_nodes():
        hosts.append(node['host'])
    hosts = list(set(hosts))
    for host in hosts:
        root_password = conf.get_password(host, 'root')
        script = os.path.join(NOAH_BIN_DIR, 'machine_init.sh')
        cmd = "sh %s -h %s -r %s" % (script, host, root_password)
        #print cmd
        '''
        ret = subprocess.call(cmd, shell = True)
        if ret != 0:
            sys.exit(ret)
        '''
    pass

def create_work_user(conf, node):
    call_shell(conf, node, 'create_user.sh')

def install_software(conf, node):
    call_shell(conf, node, 'install_software.sh')

def gen_conf(id, soft, conf):
    pass

def gen_software_update_package(conf, node):
    host, user, password = parse_node(conf, node)
    id = user + '@' + host
    for soft in node['soft']:
        class_name = soft.capitalize()
        s = eval(class_name)(id, node['soft'][soft])
        s.gen_conf()
        s.gen_bin()
        s.gen_app()
    pass

def start_service(conf, node):
    call_shell(conf, node, 'start_service.sh')

def main():
    conf = NoahConf()
    init_machines(conf)
    for node in conf.get_nodes():
        create_work_user(conf, node)
        install_software(conf, node)
        gen_software_update_package(conf, node)
        start_service(conf, node)
    pass

if __name__ == '__main__':
    main()
