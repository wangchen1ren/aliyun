#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

import logging
import os
import sys
import subprocess

from base_operation import BaseOperation
from constants import *
from logger import Logger
from memcached import Memcached
from noah_conf import NoahUpdateConf
from nginx import Nginx
from tomcat import Tomcat
from utils import *

class Deployer(BaseOperation):

    def __init__(self, conf = None):
        self.logger = Logger(NOAH_LOG_FILE)
        BaseOperation.__init__(self, conf)
        pass

    def deploy(self):
        self.logger.info("Start deploy process ...")
        hosts = []
        for node in self._conf.get_nodes():
            hosts.append(node['host'])
        hosts = set(hosts)

        for node in self._conf.get_nodes():
            if node['host'] in hosts:
                self.__init_machines(node)
                hosts.remove(node['host'])
            self.__create_work_user(node)
            self.__install_software(node)
            self.__gen_software_update_package(node)
            self.__start_service(node)
        pass

    def __init_machines(self, node):
        self.logger.info("Init machine")
        self._call_shell(node, 'machine_init.sh')
        self.logger.info("Init machine complete")
        pass

    def __create_work_user(self, node):
        self.logger.info("Create work user")
        self._call_shell(node, 'create_user.sh')
        self.logger.info("Create work user compelete")
        pass

    def __install_software(self, node):
        self.logger.info("Install software")
        self._call_shell(node, 'install_software.sh')
        self.logger.info("Install software complete")
        pass

    def __start_service(self, node):
        self.logger.info("Start server")
        self._call_shell(node, 'start_service.sh')
        self.logger.info("Start server complete")
        pass
    
    def __gen_script(self, id, softs, type):
        str = []
        str.append('#!/bin/sh')
        for soft in softs:
            line = {
                    'start' : soft.get_start_command,
                    'stop'  : soft.get_stop_command
                    }.get(type)()
            str.append(line + ' && \\')
        str.append('echo >/dev/null')
        content = '\n'.join(str)

        # write file
        instance_home = os.path.join(INSTANCE_DIR, id)
        script_name = {
                'start' : NOAH_START_SCRIPT_FILE_NAME,
                'stop'  : NOAH_STOP_SCRIPT_FILE_NAME
                }.get(type)
        script = os.path.join(instance_home, script_name)
        f = file(script, 'w')
        f.write(content)
        f.close()
        pass
       
    def __gen_software_update_package(self, node):
        host, user, password = self._parse_node(node)
        id = user + '@' + host
        software_instance = []
        for soft in node['soft']:
            class_name = soft.capitalize()
            s = eval(class_name)(id, node['soft'][soft])
            software_instance.append(s)
            s.gen_bin()
            s.gen_conf()
            s.gen_app()
        self.__gen_script(id, software_instance, 'start')
        self.__gen_script(id, software_instance, 'stop')
        pass

