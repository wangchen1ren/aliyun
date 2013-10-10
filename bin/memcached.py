#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

from constants import *
from software import Software

class Memcached(Software):

    CONST_FULLNAME = 'memcached'
    CONST_DEFAULT_VERSION = '1.4.15'
    CONST_DEFAULT_PORT = '11211'

    def __init__(self, id, config):
        Software.__init__(self, id, config)
        pass

    def gen_script_content(self):
        cmd = '$dir/../bin/memcached'
        cmd += ' -p ' + self.port
        if self.config.has_key('memory'):
            cmd += ' -m ' + self.config['memory'].strip()
        if self.config.has_key('daemon'):
            cmd += ' -d'
        s = '\n'.join(self.START_SCRIPT_CONTENT) % (self.port, cmd)
        return s
