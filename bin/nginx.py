#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

from constants import *
from software import Software

class Nginx(Software):
    def __init__(self, id, config):
        self.__fullname = 'nginx'
        self.__default_version = "1.5.4"
        self.__path = os.path.join(INSTANCE_DIR, id)
        self.__config = config
        pass

    def gen_conf(self):
        pass
