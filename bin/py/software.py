#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

import os
from constants import *

from logger import Logger
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

    DEFAULT_CONFIG_FILE_LIST = []

    CONFIG_FILE_PROPERTY_PREFIX = 'path.config.file.'
    CONST_CONFIG_TEMPATE_FILE_SUFFIX = '.template'

    USER_LABEL = '#USER#'
    PORT_LABEL = '#PORT#'

    ################################
    # public
    ################################

    def __init__(self, id, config):
        self.logger = Logger(NOAH_LOG_FILE)
        self._user = id.split('@')[0]
        self._config = config
        self.__init_fullname()
        self.__init_path(id)
        self.__init_port(config)
        pass

    def gen_conf(self):
        self.__init_config_file_list()
        for f in self._config_file_list:
            src, dst = self._get_conf_path(f)
            config_file_path = self._get_given_config_file_path(f)
            if config_file_path:
                # use given config file
                src = config_file_path
                copyfile(src, dst)
            else:
                # generate by template file
                if not os.path.isfile(src):
                    print 'WARN: config file ' + f + ' not found, skip'
                    continue
                copyfile(src, dst)
                self._software_config_op(dst)
        pass

    def gen_bin(self):
        bin_dir = os.path.join(self._path, 'bin')
        if not os.path.isdir(bin_dir):
            os.mkdir(bin_dir)
        start_script = os.path.join(bin_dir, NOAH_START_SCRIPT_FILE_NAME)
        f = file(start_script, 'w')
        f.write(self._gen_script_content())
        f.close()
        pass

    def gen_app(self):
        pass

    def get_start_command(self):
        script_path = os.path.join(self._deploy_path, 'bin', NOAH_START_SCRIPT_FILE_NAME)
        cmd = 'sh ' + script_path
        return cmd

    def get_stop_command(self):
        cmd = "for p in `ps xf | grep " + self.CONST_FULLNAME + " | grep -v grep | awk '{print $1}'`; do"
        cmd += " kill -9 $p; done"
        return cmd

    def get_monitor_command(self):
        cmd = "ps xf | grep " + self.CONST_FULLNAME + " | grep -v grep"
        cmd += " && /usr/sbin/lsof -i :" + str(self._port)
        return cmd

    ################################
    # protected
    ################################
 
    def _get_given_config_file_path(self, filename):
        key = self.CONFIG_FILE_PROPERTY_PREFIX + filename.replace('/', '.')
        if self._config.has_key(key):
            return self._config[key]
        return None

    def _get_conf_path(self, path):
        template_filename = path + self.CONST_CONFIG_TEMPATE_FILE_SUFFIX
        src = os.path.join(self._config_template_path, template_filename)
        dst = os.path.join(self._path, path)
        return [src, dst]

    def _replace_port(self, path):
        file_content_replace(path, self.PORT_LABEL, self._port)
        pass

    def _replace_user(self, path):
        file_content_replace(path, self.USER_LABEL, self._user)
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
        self._config_template_path = os.path.join(CONFIG_TEMPLATE_DIR, \
                self._fullname)

        # gen destination deploy path
        # example: /home/work/software/nginx-1.5.4
        self._deploy_path = os.path.join('/home', self._user, 'software', \
                self._fullname)
        pass

    def __init_port(self, config):
        if config.has_key('listen.port'):
            self._port = config['listen.port'].strip()
        else:
            self._port = self.CONST_DEFAULT_PORT
            #msg = 'Port not set'
            #self.logger.error(msg)
            #error(msg, 1)
        pass

    def __init_config_file_list(self):
        file_list = self.DEFAULT_CONFIG_FILE_LIST
        if self._config.has_key('config.file.list'):
            tmp = self._config['config.file.list'].split(',')
            for s in tmp:
                file_list.append(s.strip())
        self._config_file_list = list(set(file_list))
        pass


