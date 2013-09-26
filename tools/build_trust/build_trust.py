#!/bin/env python
# coding=utf-8

__author__ = "wangchen"
__email__ = "pdd.list@e-future.com.cn"
__version__ = "1.0.0"

import sys
import os
import pexpect
import time

def genkey():
    home_dir = os.getenv("HOME")
    rsa_keyfile = {
            "pri" : home_dir + '/.ssh/id_rsa',
            "pub": home_dir + '/.ssh/id_rsa.pub'
            }
    # re-generate public key or private key if not exists
    if (not os.path.isfile(rsa_keyfile["pri"]) \
            or not os.path.isfile(rsa_keyfile["pub"])):
        keygen = pexpect.spawn('ssh-keygen -t rsa', timeout=10)
        keygen.expect('[:?]')
        keygen.sendline('')
    #os.system("cat %s" % rsa_keyfile["pri"])
    #os.system("cat %s" % rsa_keyfile["pub"])
    return rsa_keyfile
    pass

def main():
    if len(sys.argv) != 3:
        print "usage: "+ sys.argv[0] + " remote passwd"
        return
    remote = sys.argv[1]
    passwd = sys.argv[2]

    # test if relationship has already been built
    detect_cmd = 'ssh ' + remote + ' "exit"'
    trust = pexpect.spawn(detect_cmd, timeout=10)
    index = trust.expect ([pexpect.EOF, "assword:", "\(yes/no\)\?"])
    # trust has already been built, just exit
    if not trust.isalive() and index == 0:
        print "Trust has been build"
        return
    trust.close()

    # not trust
    rsa_keyfile = genkey()
    time.sleep(2)

    #os.system("cat %s" % rsa_keyfile["pri"])
    #os.system("cat %s" % rsa_keyfile["pub"])

    # send public key to remote
    ssh_cmd = 'ssh ' + remote \
            + ' "test -d .ssh || mkdir -m 0700 .ssh && cat >>.ssh/authorized_keys && chmod 0600 .ssh/*" < '\
            + rsa_keyfile["pub"]
    ssh = pexpect.spawn ('/bin/bash', ['-c', ssh_cmd], timeout=10)
    pwd_count = 0
    while 1:
        try:
            index = ssh.expect(['\(yes/no\)\?', 'assword:'])
            if index == 0:
                ssh.sendline("yes")
            elif index == 1:
                if pwd_count > 0:
                    print "Password is wrong"
                    return
                else:
                    ssh.sendline(passwd)
                pwd_count = pwd_count + 1
        except pexpect.EOF:
            break
        except pexpect.TIMEOUT:
            break
    print "Trust build sucess"
    #print ssh.before   # Print the result of the ls command.
    #ssh.interact()
    pass

if __name__ == '__main__':
    main()
