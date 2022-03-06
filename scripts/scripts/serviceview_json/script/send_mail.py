import os
import codecs as cd
import sys
import smtplib , ssl
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

fromaddr = sys.argv[5]
toaddr=sys.argv[3]
tocc=sys.argv[4]

msg = MIMEMultipart()
msg['From'] = sys.argv[5]
msg['To'] = sys.argv[3]
msg['Cc'] = sys.argv[4]
msg['Subject'] = sys.argv[1]
body = cd.open(sys.argv[2],'r').read()

msg.attach(MIMEText(body, 'html'))
s = smtplib.SMTP('appsmtp-north.internal.vodafone.com:25')
s.ehlo
text =  msg.as_string()
s.sendmail(fromaddr, (toaddr+tocc).split(';'), text)
