#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

import sys
import os
import subprocess

from constants import *
from noah_conf import NoahDownloadConf
from utils import copyfile

def download(item):
    src = item['url']
    dst = os.path.join(NOAH_DOWNLOAD_HOME, item['type'], item['name'])
    copyfile(src, dst)

def main():
    conf = NoahDownloadConf()
    for item in conf.get_download_list():
        download(item)
    pass

if __name__ == '__main__':
    main()
