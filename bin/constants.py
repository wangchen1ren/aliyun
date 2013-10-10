#!/bin/env python

import os

NOAH_HOME = os.environ['NOAH_HOME']
NOAH_CONF_DIR = os.environ['NOAH_CONF_DIR']
NOAH_BIN_DIR = os.path.join(NOAH_HOME, 'bin')
NOAH_NODES_CONF_FILE_NAME = 'nodes.xml'
NOAH_ACCOUNTS_CONF_FILE_NAME = 'accounts.xml'

WORK_DIR = os.path.join(NOAH_HOME, 'workdir')
INSTANCE_DIR = os.path.join(WORK_DIR, 'instance')

