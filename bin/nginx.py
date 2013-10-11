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
    CONST_CONF_FILES = ['conf/nginx.conf', 'conf/proxy.conf']

    # public
    def gen_conf(self):
        Software.gen_conf(self)
        pass

    # protected && overwrite
    def _gen_script_content(self):
        cmd = '$dir/../sbin/nginx'
        s = '\n'.join(self.START_SCRIPT_CONTENT) % (self._port, cmd)
        return s
