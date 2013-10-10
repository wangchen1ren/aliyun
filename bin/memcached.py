#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

from constants import *
from software import Software

class Memcached(Software):
    def __init__(self, id, config):
        self.__fullname = 'memcached'
        self.__default_version = "1.4.15"
        pass
