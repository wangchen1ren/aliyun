#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

import logging

class Logger:

    def __init__(self, file_path, level = logging.DEBUG):
        self.__logger = logging.getLogger('logger')
        handler = logging.FileHandler(file_path)
        formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
        handler.setFormatter(formatter)
        self.__logger.addHandler(handler)
        self.__logger.setLevel(level)
        pass

    def info(self, msg):
        self.__logger.info(msg)
        pass

    def debug(self, msg):
        self.__logger.debug(msg)
        pass

    def error(self, msg):
        self.__logger.error(msg)
        pass
