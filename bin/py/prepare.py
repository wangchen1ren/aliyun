#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

from downloader import Downloader

def download():
    downloader = Downloader()
    downloader.download()
    pass

def main():
    download()
    pass

if __name__ == '__main__':
    main()
