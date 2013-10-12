#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

import os
import shutil
from constants import *

def copyfile(src, dst):
    if not os.path.isfile(src):
        print "file not found " + src
    dst_dir = os.path.dirname(dst)
    if not os.path.isdir(dst_dir):
        os.makedirs(dst_dir)
    shutil.copyfile(src, dst)
    pass

def file_content_replace(path, old_str, new_str):
    if os.path.isfile(path):
        tmp = open(path).read()
        text = tmp.replace(old_str, new_str)
        f = file(path, 'w')
        f.write(text)
        f.close()
    pass
