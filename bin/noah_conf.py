#!/bin/env python

import os
from xml.etree import ElementTree

from constants import *

class NoahConf:
    def __init__(self):
        self.__nodes = []
        self.__accounts = {}
        self.__load_configuration()
        pass

    def __load_configuration(self, nodes_file = None, accounts_file = None):
        if not nodes_file:
            nodes_file = os.path.join(NOAH_CONF_DIR, NOAH_NODES_CONF_FILE_NAME)
        self.__read_nodes(nodes_file)
        if not accounts_file:
            accounts_file = os.path.join(NOAH_CONF_DIR,
                    NOAH_ACCOUNTS_CONF_FILE_NAME)
        self.__read_accounts(accounts_file)
        pass

    def __read_nodes(self, nodes_file):
        if os.path.isfile(nodes_file):
            root = ElementTree.parse(nodes_file)
            elements = root.findall('./Node')
            for element in elements:
                host = element.attrib['host']
                user = element.attrib['username']
                node = {'id' : user + '@' + host,
                        'host' : host,
                        'user' : user
                        }
                node['soft'] = {}
                softs = element.findall('./software')
                for soft in softs:
                    soft_name = soft.attrib['name']
                    soft_prop = {}
                    props = soft.findall('./property')
                    for prop in props:
                        name = prop.find('name')
                        value = prop.find('value')
                        soft_prop[name.text] = value.text
                    node['soft'][soft_name] = soft_prop
                self.__nodes.append(node)
            print self.__nodes
        pass

    def __read_accounts(self, accounts_file):
        if os.path.isfile(accounts_file):
            root = ElementTree.parse(accounts_file)
            elements = root.findall('./User')
            for element in elements:
                username = element.attrib['username']
                password = element.attrib['password']
                host = element.attrib['host']
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
            print 'No password for ' + user + '@' + host
            return "password"
        pass

