#!/bin/sh

DATETIME=`date '+%Y%m'`
rm /opt/ontology/scripts/msp_blue/upload/*

lftp sftp://sftpuser1:Q8j%26Ii%5EX8L@GBVWS-AS009 << EOF >/opt/ontology/scripts/msp_blue/file.txt

cd msp
lcd "/opt/ontology/scripts/msp_blue/upload/"
mget *$DATETIME".csv"

bye
EOF

dos2unix /opt/ontology/scripts/msp_blue/upload/*

chmod -R 777 /opt/ontology/scripts/msp_blue/upload/

cd /opt/ontology/scripts/msp_blue/upload/
file_count=($( ls * | wc -l ))
if [ $file_count -gt 0 ]
then
	echo "File Present"
	
	for audname in *.csv
	do
		filename=($( echo $audname | sed 's/[0-9]//g' ))
		mv $audname $filename

	done


	
fi

