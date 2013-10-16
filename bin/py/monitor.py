#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

import sys

from base_operation import BaseOperation
from constants import *
from logger import Logger
from memcached import Memcached
from nginx import Nginx
from noah_conf import NoahUpdateConf
from tomcat import Tomcat

class Monitor(BaseOperation):

    def __init__(self, conf = None):
        self.logger = Logger(NOAH_MONITOR_LOG_FILE)
        BaseOperation.__init__(self, conf)
        pass

    def run(self):
        for node in self._conf.get_nodes():
            self.__gen_monitor_script(node)
            self.__check_node(node)
        pass

    def __gen_monitor_script(self, node):
        host, user, password = self._parse_node(node)
        id = user + '@' + host

        str = []
        str.append('#!/bin/sh')

        for soft in node['soft']:
            class_name = soft.capitalize()
            s = eval(class_name)(id, node['soft'][soft])
            line = s.get_monitor_command()
            str.append(line + ' && \\')

        str.append('echo >/dev/null')
        content = '\n'.join(str)

        # write file
        instance_home = os.path.join(INSTANCE_DIR, id)
        script_name = NOAH_MONITOR_FILE_NAME
        script = os.path.join(instance_home, script_name)
        f = file(script, 'w')
        f.write(content)
        f.close()

        pass

    def __check_node(self, node):
        self.logger.info("Check node")
        ret = self._call_shell(node, "check_node.sh", error_skip = True)
        if ret == 0:
            self.logger.info("Node ok.")
        else:
            self.logger.error("Node error.")
        pass

def main():
    monitor = Monitor()
    monitor.run()
    pass

if __name__ == '__main__':
    work_date = sys.argv[1]
    main()
