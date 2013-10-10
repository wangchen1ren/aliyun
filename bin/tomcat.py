#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

from constants import *
from software import Software

class Tomcat(Software):

    CONST_FULLNAME = 'apache-tomcat'
    CONST_DEFAULT_VERSION = '7.0.42'

    def __init__(self, id, config):
        Software.__init__(self, id, config)
        pass

    def gen_script_content(self):
        s = []
        s.append('#!/bin/sh')
        s.append('sh ../bin/startup.sh')
        return '\n'.join(s)
