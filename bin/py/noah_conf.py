#!/bin/env python

import os
from xml.etree import ElementTree

from constants import *

class NoahConf:
    
    def _get_property_map(self, xml_element):
        map = {}
        props = xml_element.findall('./property')
        for prop in props:
            name_ele = prop.find('name')
            value_ele = prop.find('value')
            name = name_ele.text
            value = value_ele.text
            if not name:
                name = ""
            if not value:
                value = ""
            map[name] = value
        return map

class NoahUpdateConf(NoahConf):

    CONST_DEFAULT_PASSWORD = 'password'

    def __init__(self):
        self.__nodes = []
        self.__accounts = {}
        self.__load_configuration()
        pass

    def __load_configuration(self, node_conf_file = None, account_conf_file = None):
        if not node_conf_file:
            node_conf_file = os.path.join(NOAH_UPDATE_CONF_DIR, NOAH_NODE_CONF_FILE_NAME)
        self.__read_nodes(node_conf_file)
        if not account_conf_file:
            account_conf_file = os.path.join(NOAH_UPDATE_CONF_DIR, \
                    NOAH_ACCOUNT_CONF_FILE_NAME)
        self.__read_accounts(account_conf_file)
        pass

    def __read_nodes(self, node_conf_file):
        if os.path.isfile(node_conf_file):
            root = ElementTree.parse(node_conf_file)
            elements = root.findall('./node')
            for element in elements:
                host = element.get('host', "")
                user = element.get('username', "")
                id = user + '@' + host
                if host == "" or user == "":
                    print 'ERROR: node conf error. node id not set'
                    sys.exit(1)
                node = {'id' : id,
                        'host' : host,
                        'user' : user
                        }
                node['soft'] = {}
                softs = element.findall('./software')
                for soft in softs:
                    soft_name = soft.get('name', "")
                    if soft_name == "":
                        print 'ERROR: node conf error. software name not set in node ' + id
                        sys.exit(1)
                    node['soft'][soft_name] = self._get_property_map(soft)
                self.__nodes.append(node)
            #print self.__nodes
        pass

    def __read_accounts(self, account_conf_file):
        if os.path.isfile(account_conf_file):
            root = ElementTree.parse(account_conf_file)
            elements = root.findall('./user')
            for ele in elements:
                username = ele.get('username', '')
                password = ele.get('password', self.CONST_DEFAULT_PASSWORD)
                host = ele.get('host', '')
                id = username + '@' + host
                self.__accounts[id] = password
        pass

    def get_nodes(self):
        return self.__nodes

    def get_accounts(self):
        return self.__accounts

    def get_password(self, host, user):
        id = user + '@' + host
        if self.__accounts.has_key(id):
            return self.__accounts[id]
        else:
            print 'WARN: No password for ' + user + '@' + host
            print '      Use default password "' + \
                    self.CONST_DEFAULT_PASSWORD + '"'
            return self.CONST_DEFAULT_PASSWORD
        pass

class NoahDownloadConf(NoahConf):

    def __init__(self):
        self.download_list = []
        self.__load_configuration()
        pass

    def __load_configuration(self, download_conf_file = None):
        if not download_conf_file:
            download_conf_file = os.path.join(NOAH_CONF_DIR, \
                    NOAH_DOWNLOAD_CONF_FILE_NAME)
        self.__read_downloads(download_conf_file)
        pass

    def __read_downloads(self, download_conf_file):
        if os.path.isfile(download_conf_file):
            root = ElementTree.parse(download_conf_file)
            for ele in root.iter():
                item = self.__parse(ele)
                if item:
                    self.download_list.append(item)
        pass

    def __parse(self, ele):
        item = {}
        item['type'] = ele.tag
        item['name'] = ele.get('name')
        props = self._get_property_map(ele)
        if not props.has_key('download.url'):
            return None
        item['url'] = props['download.url']
        return item

    def get_download_list(self):
        return self.download_list

