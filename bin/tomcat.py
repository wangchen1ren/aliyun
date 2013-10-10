#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

from constants import *
from software import Software

class Tomcat(Software):
    def __init__(self, id, config):
        self.__fullname = 'apache-tomcat'
        self.__default_version = "7.0.42"
        pass
