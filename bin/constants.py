#!/bin/env python

import os

NOAH_HOME = os.environ['NOAH_HOME']
NOAH_CONF_DIR = os.environ['NOAH_CONF_DIR']
NOAH_BIN_DIR = os.path.join(NOAH_HOME, 'bin')
NOAH_NODES_CONF_FILE_NAME = 'nodes.xml'
NOAH_ACCOUNTS_CONF_FILE_NAME = 'accounts.xml'
NOAH_START_SCRIPT = 'noah_start.sh'
NOAH_STOP_SCRIPT = 'noah_stop.sh'

WORK_DIR = os.path.join(NOAH_HOME, 'workdir')
INSTANCE_DIR = os.path.join(WORK_DIR, 'instance')
APP_DIR = os.path.join(NOAH_HOME, 'app')

