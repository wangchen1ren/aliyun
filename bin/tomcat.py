#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

import shutil
import subprocess

from constants import *
from software import Software

class Tomcat(Software):

    CONST_FULLNAME = 'apache-tomcat'
    CONST_DEFAULT_VERSION = '7.0.42'
    CONST_APP_SUFFIX = '.war'

    def __init__(self, id, config):
        Software.__init__(self, id, config)
        pass

    def gen_app(self):
        dest_root = os.path.join(self.path, 'webapps')
        applist = self.config['applist'].split(',')
        for app in applist:
            app = app.strip()
            app_filename = app + self.CONST_APP_SUFFIX
            src = os.path.join(APP_DIR, app_filename)
            dest_dir = os.path.join(dest_root, app)
            if not os.path.isdir(dest_dir):
                os.makedirs(dest_dir)
            shutil.copy(src, dest_dir)

            #uncompress
            cmd = "cd %s && jar -xf %s" % (dest_dir, app_filename)
            ret = subprocess.call(cmd, shell = True)
            if ret != 0:
                sys.exit(ret)
            os.remove(os.path.join(dest_dir, app_filename))
        pass

    def gen_script_content(self):
        s = []
        s.append('#!/bin/sh')
        s.append('dir=`dirname $0`')
        s.append('dir=`cd $dir; pwd`')
        s.append('sh $dir/../bin/startup.sh')
        return '\n'.join(s)
