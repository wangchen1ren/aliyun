#!/bin/env python

import os

NOAH_HOME = os.environ['NOAH_HOME']
NOAH_CONF_DIR = os.environ['NOAH_CONF_DIR']
NOAH_UPDATE_CONF_DIR = os.environ['NOAH_UPDATE_CONF_DIR']
NOAH_UPDATE_APP_DIR = os.environ['NOAH_UPDATE_APP_DIR']
CONFIG_TEMPLATE_DIR = os.path.join(os.environ['TOOLS_HOME'], 'config_template')

NOAH_SHELL_DIR = os.path.join(NOAH_HOME, 'bin', 'shell')
WORK_DIR = os.path.join(NOAH_HOME, 'workdir')
INSTANCE_DIR = os.path.join(WORK_DIR, 'instance')

# filenames
NOAH_NODES_CONF_FILE_NAME = 'node-conf.xml'
NOAH_ACCOUNTS_CONF_FILE_NAME = 'account-conf.xml'
NOAH_START_SCRIPT_FILE_NAME = 'noah_start.sh'
NOAH_STOP_SCRIPT_FILE_NAME = 'noah_stop.sh'

