#!/bin/ksh

. /opt/ontology/scripts/configuration/ontyd2.env
#DATETIME=`date '+%b%Y'`
DATETIME=($(date '+%Y%m' |  cut -c3- ))
input_file='/opt/ontology/scripts/msp_blue/upload/intlist_msp_uk_.csv'

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
	echo "File Present" > /opt/ontology/scripts/msp_blue/msp_blue.txt

	
	for audname in *.csv
	do
		#filename=($( echo $audname | sed 's/[0-9]//g' ))
		#mv $audname $filename

	
	#done

	



#if [ -f "$input_file" ] && [ $(stat -c%s "$input_file")  -gt 0 ]
#then


${SQL2} << EOF 

insert into network_msp_blue_bkp  (ROUTER,PORT,CUSTOMER,ADMIN,OPER,DESCRIPTION,UPLOAD_DATE,archive_date ) 
select  ROUTER,PORT,CUSTOMER,ADMIN,OPER,DESCRIPTION,UPLOAD_DATE, sysdate  from network_msp_blue;



DELETE FROM network_msp_blue_bkp WHERE archive_date IN ( Select archive_date from network_msp_blue_bkp where To_Char(archive_date,'YYYYMM') < 
to_char(add_months(trunc(sysdate,'mm'),-3),'YYYYMM') AND TO_DATE(archive_date,'DD-MON-YYYY') in  (select * from (
SELECT distinct TO_DATE(archive_date,'DD-MON-YYYY')  from network_msp_blue_bkp ORDER BY  TO_DATE(archive_date,'DD-MON-YYYY') asc) where rownum < 2 ) ) ;


truncate table network_msp_blue;
/
EOF


${SQLLOAD2}  data="$audname",control='/opt/ontology/scripts/msp_blue/msp_blue.ctl',LOG="/opt/ontology/scripts/msp_blue/msp_blue.log",ERRORS=100


${SQL2} << EOF 


insert into PRT_MANUAL_UPLOAD_TRACKER values ( SYSDATE , 'MSP BLUE' , 'File uploaded successfully.' );
UPDATE ONTOLOGY.NETWORK_EXTRACT SET extract_date = sysdate where extract_no= '17';
UPDATE ONTOLOGY.NETWORK_SUMMARY_TABLE SET DATA_EXTRACTION_DATE = (SYSDATE -1) WHERE NETWORK_NAME = 'BLUE MSP';
WHENEVER SQLERROR EXIT sql.sqlcode;
set pagesize 0;
SET LONG 50000;
set trimspool on;
set trimout on;
set headsep on;
set linesize 32767;
set feedback off;
set echo off;

BEGIN
ONTOLOGY.update_network_summary_pkg.update_network_summary_tab('MSP_BLUE');

END;
/
commit;
EOF


${SQL2} << EOF >  /opt/ontology/scripts/msp_blue/proc_finalload.log

WHENEVER SQLERROR EXIT sql.sqlcode; 
set pagesize 0; 
SET LONG 50000; 
set trimspool on; 
set trimout on; 
set headsep on; 
set linesize 32767; 
set feedback off; 
set echo off;
    
BEGIN
IPVPN_NW_MSP_BLUE_PACKAGE.EXECUTE_ALL();

END; 
/
EOF

gzip -c /opt/ontology/scripts/msp_blue/upload/*.csv > /opt/ontology/scripts/msp_blue/upload_zipfiles/upload$DATETIME.gz
rm /opt/ontology/scripts/msp_blue/upload/*.csv
find /opt/ontology/scripts/msp_blue/upload_zipfiles/*.gz -mtime +180 -delete
done

else
echo "Files is not present ." > /opt/ontology/scripts/msp_blue/msp_blue.txt
fi
