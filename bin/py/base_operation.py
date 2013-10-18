#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

from logger import Logger
from noah_conf import NoahUpdateConf
from utils import *

class BaseOperation:

    def __init__(self, conf = None):
        if not conf:
            conf = NoahUpdateConf()
        self._conf = conf
        pass

    def _parse_node(self, node):
        password = self._conf.get_password(node['host'], node['user'])
        return [node['host'], node['user'], password]

    def _call_shell(self, node, script_file, error_skip = False):
        host, user, password = self._parse_node(node)
        self.logger.info("node: " + user + "@" + host)
        root_password = self._conf.get_password(host, 'root')
        script = os.path.join(NOAH_SHELL_DIR, script_file)
        cmd = "sh %s -h %s -r %s -u %s -p %s" % (script, host, 
                root_password, user, password)
        #print cmd
        ret, out, err = shell_exec(cmd)
        if ret != 0:
            msg = "Error in running " + script_file + "\n"
            msg += err
            msg += "Return code: " + str(ret)
            self.logger.error(msg)
            error(msg, ret, error_skip)
        return ret

