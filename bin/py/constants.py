#!/bin/env python

import os

NOAH_HOME = os.environ['NOAH_HOME']
NOAH_CONF_DIR = os.environ['NOAH_CONF_DIR']

NOAH_DOWNLOAD_HOME = os.environ['DOWNLOAD_HOME']
NOAH_UPDATE_CONF_DIR = os.environ['NOAH_UPDATE_CONF_DIR']
NOAH_UPDATE_APP_DIR = os.environ['NOAH_UPDATE_APP_DIR']
NOAH_UPDATE_SOFTWARE_DIR = os.environ['NOAH_UPDATE_SOFTWARE_DIR']
NOAH_UPDATE_OTHER_DIR = os.environ['NOAH_UPDATE_OTHER_DIR']
WORK_DIR = os.environ['WORKDIR']
INSTANCE_DIR = os.environ['INSTANCEDIR']

NOAH_SHELL_DIR = os.path.join(NOAH_HOME, 'bin', 'shell')
CONFIG_TEMPLATE_DIR = os.path.join(os.environ['TOOLS_HOME'], 'config_template')

# log
NOAH_LOG_DIR = os.environ['LOGDIR']
NOAH_LOG_FILE = os.path.join(NOAH_LOG_DIR, 'noah_log.log')
NOAH_MONITOR_LOG_FILE = os.path.join(NOAH_LOG_DIR, 'monitor_log.log')

# filenames
NOAH_DOWNLOAD_CONF_FILE_NAME = 'download-conf.xml'
NOAH_NODE_CONF_FILE_NAME = 'node-conf.xml'
NOAH_ACCOUNT_CONF_FILE_NAME = 'account-conf.xml'
NOAH_START_SCRIPT_FILE_NAME = 'noah_start.sh'
NOAH_STOP_SCRIPT_FILE_NAME = 'noah_stop.sh'
NOAH_MONITOR_FILE_NAME = 'noah_monitor.sh'
