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

    def __init__(self, id, config):
        Software.__init__(self, id, config)
        pass

    def gen_bin(self):
        bin_dir = os.path.join(self.path, 'bin')
        if not os.path.isdir(bin_dir):
            os.mkdir(bin_dir)
        start_script = os.path.join(bin_dir, NOAH_START_SCRIPT)
        f = file(start_script, 'w')
        f.write(self.__gen_script_content())
        f.close()
        pass

    def __gen_script_content(self):
        s = []
        s.append('#!/bin/sh')
        s.append('dir=`dirname $0`')
        s.append('dir=`cd $dir; pwd`')
        cmd = '$dir/../bin/memcached'
        if self.config.has_key('port'):
            cmd += ' -p ' + self.config['port']
        if self.config.has_key('memory'):
            cmd += ' -m ' + self.config['memory']
        if self.config.has_key('daemon'):
            cmd += ' -d'
        s.append(cmd)
        return '\n'.join(s)
