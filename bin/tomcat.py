#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

import subprocess

from constants import *
from software import Software
from utils import *

class Tomcat(Software):

    CONST_FULLNAME = 'apache-tomcat'
    CONST_DEFAULT_VERSION = '7.0.42'
    CONST_DEFAULT_PORT = 8080
    CONST_APP_SUFFIX = '.war'

    CONFIG_FILE_LIST = ['conf/server.xml']

    def gen_conf(self):
        Software.gen_conf(self)
        pass

    def gen_app(self):
        dest_root = os.path.join(self._path, 'webapps')
        if not self._config['applist']:
            applist = []
        else:
            applist = self._config['applist'].split(',')
        for app in applist:
            app = app.strip()
            app_filename = app + self.CONST_APP_SUFFIX
            src = os.path.join(APP_DIR, app_filename)
            dst = os.path.join(dest_root, app, app_filename)
            copyfile(src, dst)

            #uncompress
            dst_dir = os.path.dirname(dst)
            cmd = "cd %s && jar -xf %s" % (dst_dir, app_filename)
            ret = subprocess.call(cmd, shell = True)
            if ret != 0:
                sys.exit(ret)
            os.remove(dst)
        pass

    def _gen_script_content(self):
        cmd = 'sh $dir/../bin/startup.sh'
        s = '\n'.join(self.START_SCRIPT_CONTENT) % (self._port, cmd)
        return s
