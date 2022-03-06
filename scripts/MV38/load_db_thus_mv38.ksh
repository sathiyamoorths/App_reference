#!/bin/ksh

. /opt/ontology/scripts/configuration/ontyd2.env
DATETIME=($(date '+%Y%m'))

rm /opt/ontology/scripts/MV38/upload/Thus/*

lftp sftp://sftpuser1:Q8j%26Ii%5EX8L@GBVWS-AS009 << EOF >/opt/ontology/scripts/MV38/thus_file.txt

cd MV38
lcd "/opt/ontology/scripts/MV38/upload/Thus/"
mget  MV38_THUS_$DATETIME".csv"

bye
EOF


dos2unix /opt/ontology/scripts/MV38/upload/Thus/*

chmod -R 777 /opt/ontology/scripts/MV38/upload/Thus/

cd /opt/ontology/scripts/MV38/upload/Thus/
file_count=($( ls * | wc -l ))
if [ $file_count -gt 0 ]
then
	echo "File Present" > /opt/ontology/scripts/MV38/MV38_thus.txt

	
	for audname in *.csv
	do
		



${SQL2} << EOF 


insert into NETWORK_NQRT_EXTRACT_BKP (ASTN_STATE,PROTECTION,TYPE,DATE_ADDED,NETWORK_CATEGORY,OPERATIONAL_STATE,WORKER_STATE,
NAME,SERVICE_STATE,archive_date)
select ASTN_STATE,PROTECTION,TYPE,DATE_ADDED,NETWORK_CATEGORY,OPERATIONAL_STATE,WORKER_STATE,
NAME,SERVICE_STATE,SYSDATE from NETWORK_NQRT_EXTRACT ;


DELETE FROM NETWORK_NQRT_EXTRACT_BKP WHERE archive_date IN ( Select archive_date from NETWORK_MV38_DATA_bkp where To_Char(archive_date,'YYYYMM') < 
to_char(add_months(trunc(sysdate,'mm'),-3),'YYYYMM') AND TO_DATE(archive_date,'DD-MON-YYYY') in  (select * from (
SELECT distinct TO_DATE(archive_date,'DD-MON-YYYY')  from NETWORK_NQRT_EXTRACT_BKP ORDER BY  TO_DATE(archive_date,'DD-MON-YYYY') asc) where rownum < 2 ) ) ;



truncate table NETWORK_NQRT_EXTRACT;
commit;

EOF


${SQLLOAD2}  data="$audname",  control='/opt/ontology/scripts/MV38/load_thus_mv38.ctl',LOG="/opt/ontology/scripts/MV38/load_thus_mv38.log",ERRORS=100

 
${SQL2} << EOF > /opt/ontology/scripts/MV38/proc_thus.log

update NETWORK_NQRT_EXTRACT set NETWORK_CATEGORY = 'NQRT_CIRCUIT' ;
insert into PRT_MANUAL_UPLOAD_TRACKER values ( SYSDATE , 'THUS MV38' , 'File uploaded successfully.' );
UPDATE ONTOLOGY.NETWORK_EXTRACT SET extract_date = sysdate where extract_no= '11';
commit;
EOF


gzip -c /opt/ontology/scripts/MV38/upload/Thus/"$audname" > /opt/ontology/scripts/MV38/upload_zipfiles/Thus/upload_Thus$DATETIME.gz
rm /opt/ontology/scripts/MV38/upload/Thus/"$audname"
find /opt/ontology/scripts/MV38/upload_zipfiles/Thus/*.gz -mtime +180 -delete

done
else
echo "Files is not present ." > /opt/ontology/scripts/MV38/thus_mv38.txt
fi


