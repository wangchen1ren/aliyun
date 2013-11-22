#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

import sys
import os
import subprocess

from constants import *
from logger import Logger
from noah_conf import NoahDownloadConf
from utils import copyfile

class Downloader:

    def __init__(self, conf = None):
        self.logger = Logger(NOAH_LOG_FILE)
        if not conf:
            conf = NoahDownloadConf()
        self.__conf = conf
        pass

    def download(self):
        self.logger.info("Start download ...");
        for item in self.__conf.get_download_list():
            self.__download_item(item)
        self.logger.info("Download complete.");
        pass

    def __download_item(self, item):
        src = item['url']
        dst = os.path.join(NOAH_DOWNLOAD_HOME, item['type'], item['name'])
        self.logger.info("Downloading " + src + " to " + dst)
        copyfile(src, dst)
        pass

