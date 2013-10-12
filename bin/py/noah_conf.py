#!/bin/env python

import os
from xml.etree import ElementTree

from constants import *

class NoahUpdateConf:

    CONST_DEFAULT_PASSWORD = 'password'

    def __init__(self):
        self.__nodes = []
        self.__accounts = {}
        self.__load_configuration()
        pass

    def __load_configuration(self, nodes_file = None, accounts_file = None):
        if not nodes_file:
            nodes_file = os.path.join(NOAH_UPDATE_CONF_DIR, NOAH_NODES_CONF_FILE_NAME)
        self.__read_nodes(nodes_file)
        if not accounts_file:
            accounts_file = os.path.join(NOAH_UPDATE_CONF_DIR, \
                    NOAH_ACCOUNTS_CONF_FILE_NAME)
        self.__read_accounts(accounts_file)
        pass

    def __read_nodes(self, nodes_file):
        if os.path.isfile(nodes_file):
            root = ElementTree.parse(nodes_file)
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
                    node['soft'][soft_name] = self.__get_property_map(soft)
                self.__nodes.append(node)
            #print self.__nodes
        pass

    def __read_accounts(self, accounts_file):
        if os.path.isfile(accounts_file):
            root = ElementTree.parse(accounts_file)
            elements = root.findall('./user')
            for ele in elements:
                username = ele.get('username', '')
                password = ele.get('password', self.CONST_DEFAULT_PASSWORD)
                host = ele.get('host', '')
                id = username + '@' + host
                self.__accounts[id] = password
        pass

    def __get_property_map(self, xml_element):
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
            print '      Use default password "' + self.CONST_DEFAULT_PASSWORD + '"'
            return self.CONST_DEFAULT_PASSWORD
        pass

class NoahDownloadConf:

    def __init__(self):
        pass
