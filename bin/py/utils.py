#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

import os
import shutil
import subprocess
import sys
import urlparse
import urllib2
import hashlib

from constants import *

def error(msg, ret, skip = False):
    sys.stderr.write(msg)
    if skip == False:
        sys.exit(1)
    pass

def copyfile(src, dst):
    dst_dir = os.path.dirname(dst)
    if not os.path.isdir(dst_dir):
        os.makedirs(dst_dir)

    url = urlparse.urlparse(src, scheme = 'file')
    if url.scheme == 'file':
        if not os.path.isfile(src):
            print "file not found " + src
        shutil.copyfile(src, dst)
    else:
        remote = urllib2.urlopen(src)
        hash = hashlib.md5()
        if os.path.isfile(dst):
            os.remove(dst)
        file = open(dst, 'a')
        try:
            while True:
                data = remote.read(4096)
                if not data:
                    break
                hash.update(data)
                file.write(data)
        finally:
            remote.close()
            file.close()
    pass

def file_content_replace(path, old_str, new_str):
    if os.path.isfile(path):
        tmp = open(path).read()
        text = tmp.replace(old_str, new_str)
        f = file(path, 'w')
        f.write(text)
        f.close()
    pass

def shell_exec(cmd):
    process = subprocess.Popen(cmd, shell = True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
    out, err = process.communicate()
    returncode = process.returncode
    return [returncode, out, err]
