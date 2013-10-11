#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

import os
from constants import *
from utils import *

class Software:

    START_SCRIPT_CONTENT = ["#!/bin/sh",
                            "dir=`dirname $0`",
                            "dir=`cd $dir; pwd`",
                            "if /usr/sbin/lsof -i :%s >/dev/null; then",
                            "    exit 1",
                            "else",
                            "    %s",
                            "fi"
                            ]

    CONFIG_FILE_LIST = []
    CONST_CONFIG_TEMPATE_FILE_SUFFIX = '.template'
    PORT_LABEL = '#PORT#'

    ################################
    # public
    ################################

    def __init__(self, id, config):
        self._config = config
        self.__init_fullname()
        self.__init_path(id)
        self.__init_port(config)
        pass

    def gen_conf(self):
        for f in self.CONFIG_FILE_LIST:
            # copy template file to update package
            template_filename = f + self.CONST_CONFIG_TEMPATE_FILE_SUFFIX
            src = os.path.join(self._config_template_path, template_filename)
            dst = os.path.join(self._path, f)
            copyfile(src, dst)

            self._replace_port(dst)
        pass

    def gen_bin(self):
        bin_dir = os.path.join(self._path, 'bin')
        if not os.path.isdir(bin_dir):
            os.mkdir(bin_dir)
        start_script = os.path.join(bin_dir, NOAH_START_SCRIPT)
        f = file(start_script, 'w')
        f.write(self._gen_script_content())
        f.close()
        pass

    def gen_app(self):
        pass

    def get_start_command(self):
        script_path = os.path.join(self._deploy_path, 'bin', NOAH_START_SCRIPT)
        cmd = 'sh ' + script_path
        return cmd

    def get_stop_command(self):
        cmd = "ps xf | grep " + self.CONST_FULLNAME
        cmd += " | awk '{print $1}' | xargs kill -9 2>/dev/null"
        return cmd

    ################################
    # protected
    ################################
 
    def _gen_config_path(self):
        pass

    def _replace_port(self, file_path):
        content = open(file_path).read()
        content = content.replace(self.PORT_LABEL, self._port)
        f = file(file_path, 'w')
        f.write(content)
        f.close()
        pass   

    def _gen_script_content(self):
        return ""

    ################################
    # private
    ################################

    def __init_fullname(self):
        # gen software fullname
        # example: nginx-1.5.4
        if self._config.has_key('version'):
            version = self._config['version']
        else:
            version = self.CONST_DEFAULT_VERSION
        self._fullname = self.CONST_FULLNAME + '-' + version
        pass

    def __init_path(self, id):
        # gen update package path
        instance_home = os.path.join(INSTANCE_DIR, id)
        self._path = os.path.join(instance_home, self._fullname)
        if not os.path.isdir(self._path):
            os.makedirs(self._path)

        # get software config template file dir
        self._config_template_path = os.path.join(
                CONFIG_TEMPLATE_DIR, self._fullname)

        # gen destination deploy path
        # example: /home/work/software/nginx-1.5.4
        user = id.split('@')[0]
        self._deploy_path = os.path.join('/home', user, 'software', self._fullname)
        pass

    def __init_port(self, config):
        if config.has_key('port'):
            self._port = config['port'].strip()
        else:
            self._port = str(self.CONST_DEFAULT_PORT)
        pass


