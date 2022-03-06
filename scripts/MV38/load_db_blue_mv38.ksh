#!/bin/ksh

. /opt/ontology/scripts/configuration/ontyd2.env
DATETIME=($(date '+%Y%m'))

rm /opt/ontology/scripts/MV38/upload/Blue/*

lftp sftp://sftpuser1:Q8j%26Ii%5EX8L@GBVWS-AS009 << EOF >/opt/ontology/scripts/MV38/blue_file.txt

cd MV38
lcd "/opt/ontology/scripts/MV38/upload/Blue/"
mget  MV38_BLUE_$DATETIME".csv"

bye
EOF
#MV38_BLUE_201804.csv

dos2unix /opt/ontology/scripts/MV38/upload/Blue/*

chmod -R 777 /opt/ontology/scripts/MV38/upload/Blue/

cd /opt/ontology/scripts/MV38/upload/Blue/
file_count=($( ls * | wc -l ))
if [ $file_count -gt 0 ]
then
	echo "File Present" > /opt/ontology/scripts/MV38/MV38_blue.txt

	
	for audname in *.csv
	do
		

${SQL2} << EOF 


insert into NETWORK_MV38_DATA_BKP  ( UPLOAD_DATE,WORKER_PROT_STATE,SERVICE_STATE,PROTECTION,ASON_STATE,DRIRECTIONALITY,
TYPE,OPER_STATE,NAME,archive_DATE)
select  UPLOAD_DATE,WORKER_PROT_STATE,SERVICE_STATE,PROTECTION,ASON_STATE,DRIRECTIONALITY,TYPE,OPER_STATE,NAME, SYSDATE 
from  NETWORK_MV38_DATA ;


DELETE FROM NETWORK_MV38_DATA_bkp WHERE archive_date IN ( Select archive_date from NETWORK_MV38_DATA_bkp where To_Char(archive_date,'YYYYMM') < 
to_char(add_months(trunc(sysdate,'mm'),-3),'YYYYMM') AND TO_DATE(archive_date,'DD-MON-YYYY') in  (select * from (
SELECT distinct TO_DATE(archive_date,'DD-MON-YYYY')  from NETWORK_MV38_DATA_bkp ORDER BY  TO_DATE(archive_date,'DD-MON-YYYY') asc) where rownum < 2 ) ) ;



truncate table NETWORK_MV38_DATA;
COMMIT;

EOF


${SQLLOAD2}  data="$audname",  control='/opt/ontology/scripts/MV38/load_blue_mv38.ctl',LOG="/opt/ontology/scripts/MV38/load_blue_mv38.log",ERRORS=100

 
${SQL2} << EOF > /opt/ontology/scripts/MV38/proc_blue.log


insert into PRT_MANUAL_UPLOAD_TRACKER values ( SYSDATE , 'BLUE MV38' , 'File uploaded successfully.' );
UPDATE ONTOLOGY.NETWORK_EXTRACT SET extract_date = sysdate where extract_no= '11';
COMMIT;
UPDATE ONTOLOGY.NETWORK_SUMMARY_TABLE SET DATA_EXTRACTION_DATE = SYSDATE WHERE NETWORK_NAME = 'BLUE MV38';
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
ONTOLOGY.update_network_summary_pkg.update_network_summary_tab('BLUE_MV38');

END;
/
commit;
EOF


gzip -c /opt/ontology/scripts/MV38/upload/Blue/"$audname" > /opt/ontology/scripts/MV38/upload_zipfiles/Blue/upload_blue$DATETIME.gz
rm /opt/ontology/scripts/MV38/upload/Blue/"$audname"
find /opt/ontology/scripts/MV38/upload_zipfiles/Blue/*.gz -mtime +180 -delete

done
else
echo "Files is not present ." > /opt/ontology/scripts/MV38/blue_mv38.txt
fi


