import os
import codecs as cd
import sys
import smtplib , ssl
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from email.mime.base import MIMEBase
from email import encoders

fromaddr = sys.argv[5]
toaddr=sys.argv[3]
tobcc=sys.argv[4]

msg = MIMEMultipart()
msg['From'] = sys.argv[5]
msg['To'] = sys.argv[3]
msg['Bcc'] = sys.argv[4]
msg['Subject'] = sys.argv[1]
body = cd.open(sys.argv[2],'r').read()

msg.attach(MIMEText(body, 'html'))
files = 'dibyarup.jpg'
a_file = '/home/ontology/deepesh/dibyarup.jpg'
attachment = open(a_file, 'rb')
p = MIMEBase('application', 'octet-stream')
p.set_payload((attachment).read())
encoders.encode_base64(p)
p.add_header('Content-Disposition', "inline; filename= %s" % files)
msg.attach(p)

s = smtplib.SMTP('SMTP.INTERNAL.VODAFONE.COM:25')
s.ehlo
text =  msg.as_string()
s.sendmail(fromaddr, (toaddr+tobcc).split(';'), text)
