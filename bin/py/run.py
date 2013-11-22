#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

import optparse
from deployer import Deployer

def deploy(is_test):
    deployer = Deployer(is_test)
    deployer.deploy()
    pass

def main():
    opt = optparse.OptionParser()
    opt.add_option("-t", action="store_true", dest="is_test")
    (options, args) = parser.parse_args()

    deploy(options.is_test)
    pass

if __name__ == '__main__':
    main()
