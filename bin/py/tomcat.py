#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

from constants import *
from software import Software
from utils import *

class Tomcat(Software):

    CONST_FULLNAME = 'apache-tomcat'
    CONST_DEFAULT_VERSION = '7.0.42'
    CONST_DEFAULT_PORT = 8080
    CONST_DEFAULT_SHUTDOWN_PORT = 9005
    CONST_APP_SUFFIX = '.war'

    SHUTDOWN_PORT_LABEL = '#SHUTDOWN_PORT#'

    DEFAULT_CONFIG_FILE_LIST = ['conf/server.xml']

    def _software_config_op(self, path):
        self._replace_port(path)
        self._replace_shutdown_port(path)
        pass

    def gen_app(self):
        dst_root = os.path.join(self._path, 'webapps')
        if not self._config.has_key('applist') or \
                self._config['applist'] == '':
            applist = []
        else:
            applist = self._config['applist'].split(',')
        for app in applist:
            app = app.strip()
            app_filename = app + self.CONST_APP_SUFFIX
            src = os.path.join(NOAH_UPDATE_APP_DIR, app_filename)
            dst = os.path.join(dst_root, app, app_filename)
            copyfile(src, dst)

            #uncompress
            dst_dir = os.path.dirname(dst)
            cmd = "cd %s && jar -xf %s" % (dst_dir, app_filename)
            ret, out, err = shell_exec(cmd)
            if ret != 0:
                msg = "gen tomcat app error: " + "\n"
                msg += err
                self.logger.error(msg)
                error(msg, ret)
            os.remove(dst)
        pass

    def _replace_shutdown_port(self, path):
        if self._config.has_key('shutdown.port'):
            shutdown_port = self._config['shutdown.port']
        else:
            print 'WARN: tomcat shutdown port not set, use default ' + \
                    str(self.CONST_DEFAULT_SHUTDOWN_PORT)
            shutdown_port = str(self.CONST_DEFAULT_SHUTDOWN_PORT)
        file_content_replace(path, self.SHUTDOWN_PORT_LABEL, shutdown_port)
        pass

    def _gen_script_content(self):
        cmd = 'export TOMCAT_HOME=$dir/..'
        cmd += ' && export CATALINA_HOME=$TOMCAT_HOME'
        cmd += ' && export CATALINA_BASE=$TOMCAT_HOME'
        cmd += ' && sh $dir/../bin/startup.sh'
        s = '\n'.join(self.START_SCRIPT_CONTENT) % (self._port, cmd)
        return s
