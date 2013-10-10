#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

import os
from constants import *

class Software:
    def __init__(self, id, config):
        instance_home = os.path.join(INSTANCE_DIR, id)
        if config.has_key('version'):
            version = config['version']
        else:
            version = self.CONST_DEFAULT_VERSION
        fullname = self.CONST_FULLNAME + '-' + version
        self.path = os.path.join(instance_home, fullname)
        if not os.path.isdir(self.path):
            os.makedirs(self.path)
        self.config = config

        user = id.split('@')[0]
        self.deploy_path = os.path.join('/home', user, 'software', fullname)
        pass

    def gen_conf(self):
        pass

    def gen_bin(self):
        bin_dir = os.path.join(self.path, 'bin')
        if not os.path.isdir(bin_dir):
            os.mkdir(bin_dir)
        start_script = os.path.join(bin_dir, NOAH_START_SCRIPT)
        f = file(start_script, 'w')
        f.write(self.gen_script_content())
        f.close()
        pass

    def gen_script_content(self):
        return ""

    def gen_app(self):
        pass

    def get_start_command(self):
        script_path = os.path.join(self.deploy_path, 'bin', NOAH_START_SCRIPT)
        cmd = 'sh ' + script_path
        return cmd

    def get_stop_command(self):
        cmd = "ps xf | grep " + self.CONST_FULLNAME
        cmd += " | awk '{print $1}' | xargs kill -9 2>/dev/null"
        return cmd
