#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

from constants import *
from software import Software

class Nginx(Software):

    CONST_FULLNAME = 'nginx'
    CONST_DEFAULT_VERSION = '1.5.4'
    CONST_DEFAULT_PORT = 8888
    CONST_CONF_FILES = ['nginx.conf', 'proxy.conf']

    def __init__(self, id, config):
        Software.__init__(self, id, config)
        pass

    def gen_conf(self):
        conf_dir = os.path.join(self.path, 'conf')
        if not os.path.isdir(conf_dir):
            os.mkdir(conf_dir)
        pass

    def gen_script_content(self):
        cmd = '$dir/../sbin/nginx'
        s = '\n'.join(self.START_SCRIPT_CONTENT) % (self.port, cmd)
        return s
