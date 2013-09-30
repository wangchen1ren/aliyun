#!/usr/bin/env python

import sys
import getopt
import smtplib
from email.mime.text import MIMEText

sender = {
        'host':'smtp.163.com',
        'user':'efuture_monitor',
        'pass':'efuture123',
        'postfix':'163.com'
        }

subject = ""
mailto = []

def usage():
    print("Usage:%s [-a|-o|-c] [--help|--output] args...." %Dsys.argv[0]) 

def send_mail(mailto, subject, content):
    user = sender['user']
    me = sender['user'] + "<" + sender['user'] + "@" + sender['postfix'] + ">"
    msg = MIMEText(content)
    msg['Subject'] = subject
    msg['From'] = me
    msg['To'] = ";".join(mailto)
    try:
        s = smtplib.SMTP()
        s.connect(sender['host'])
        s.login(sender['user'], sender['pass'])
        s.sendmail(me, mailto, msg.as_string())
        s.close()
        return True
    except Exception, e:
        print str(e)
        return False


def parse_args():
    try:
        shortargs = 'hs:t:'
        longargs = ['help', 'subject=', 'to=']
        opts, args = getopt.getopt(sys.argv[1:], shortargs, longargs)  
        sub = to = ""
        for opt, arg in opts:
            if opt in ('-h', '--help'):
                usage()
                sys.exit(0)
            elif opt in ('-s', '--subject'):
                sub = arg
            elif opt in ('-t', '--to'):
                to = arg
        if sub == '':
            print "No subject"
            sys.exit(1)
        if to == "":
            print "No mailto"
            sys.exit(1)
        return sub, to.split()
    except getopt.GetoptError:
        usage()
        sys.exit(1)

def get_content():
    content = ""
    while True:
        line = sys.stdin.readline()
        if not line:
            break
        content = content + line
    return content

def main():
    subject, mailto = parse_args()
    content = get_content()
    if not send_mail(mailto, subject, content):
        print "Failed to send"
        sys.exit(1)

if __name__ == '__main__':
    main()
