#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

from constants import *
from software import Software
from utils import *
from zipfile import ZipFile

class Mule(Software):

    CONST_FULLNAME = 'mule-standalone'
    CONST_DEFAULT_VERSION = '3.2.1'
    CONST_DEFAULT_PORT = 10001

    CONST_APP_SUFFIX = '.zip'

    def gen_app(self):
        dst_root = os.path.join(self._path, 'apps')
        if not self._config.has_key('applist') or \
                self._config['applist'] == '':
            applist = []
        else:
            applist = self._config['applist'].split(',')
        for app in applist:
            app = app.strip()
            app_filename = app + self.CONST_APP_SUFFIX
            src = os.path.join(NOAH_UPDATE_APP_DIR, app_filename)
            dst = os.path.join(dst_root, app)
            if not os.path.isdir(dst):
                os.makedirs(dst)

            #uncompress
            cmd = "unzip -o %s -d %s" % (src, dst)
            ret, out, err = shell_exec(cmd)
            if ret != 0:
                msg = 'app zip file error:\n'
                msg += err
                self.logger.error(msg)
                error(msg, ret)
            '''
            #try:
            f = ZipFile(src, 'r')
            f.extractall(dst)
            f.close()
            except:
                msg = "zip file error"
                self.logger.error(msg)
                error(msg, 1)
            '''
        pass

    def _gen_script_content(self):
        cmd = 'sh $dir/../bin/mule restart'
        s = '\n'.join(self.START_SCRIPT_CONTENT) % (self._port, cmd)
        return s
