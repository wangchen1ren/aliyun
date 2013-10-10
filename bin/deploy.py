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
    #print cmd
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
        ret = subprocess.call(cmd, shell = True)
        if ret != 0:
            sys.exit(ret)
    pass

def create_work_user(conf, node):
    call_shell(conf, node, 'create_user.sh')

def install_software(conf, node):
    call_shell(conf, node, 'install_software.sh')

def gen_start_script(id, softs):
    instance_home = os.path.join(INSTANCE_DIR, id)
    start_script = os.path.join(instance_home, NOAH_START_SCRIPT)
    s = []
    s.append('#!/bin/sh')
    for soft in softs:
        s.append(soft.get_start_command() + ' && \\')
    s.append('echo >/dev/null')
    content = '\n'.join(s)
    f = file(start_script, 'w')
    f.write(content)
    f.close()
    pass

def gen_stop_script(id, softs):
    instance_home = os.path.join(INSTANCE_DIR, id)
    stop_script = os.path.join(instance_home, NOAH_STOP_SCRIPT)
    s = []
    s.append('#!/bin/sh')
    for soft in softs:
        s.append(soft.get_stop_command() + ' && \\')
    s.append('echo >/dev/null')
    content = '\n'.join(s)
    f = file(stop_script, 'w')
    f.write(content)
    f.close()
    pass

def gen_software_update_package(conf, node):
    host, user, password = parse_node(conf, node)
    id = user + '@' + host
    software_instance = []
    for soft in node['soft']:
        class_name = soft.capitalize()
        s = eval(class_name)(id, node['soft'][soft])
        software_instance.append(s)
        s.gen_conf()
        s.gen_bin()
        s.gen_app()
    gen_start_script(id, software_instance)
    gen_stop_script(id, software_instance)
    pass

def start_service(conf, node):
    call_shell(conf, node, 'start_service.sh')

def main():
    conf = NoahConf()
    #init_machines(conf)
    for node in conf.get_nodes():
        #create_work_user(conf, node)
        install_software(conf, node)
        gen_software_update_package(conf, node)
        start_service(conf, node)
    pass

if __name__ == '__main__':
    main()
