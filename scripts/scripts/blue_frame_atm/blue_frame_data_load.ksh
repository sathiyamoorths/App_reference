#!/bin/ksh
#dir=$1;

#env=`grep -w "env" ${dir} | cut -f2 -d"="`
#export env
#echo ${env}
#. ${env}

#blue_frame=`grep -w "blue_frame" ${dir} | cut -f2 -d"="`
#export blue_frame
#echo ${blue_frame}

#cd ${blue_frame}


. /opt/ontology/scripts/configuration/ontyd2.env

DATETIME=`date '+%Y%m%d'`

cd /opt/ontology/scripts/blue_frame_atm/upload
rm output.csv
if [ -e *.xls ]
then 
	for file in *xls
	do 
		ls -l "$file"
		echo ${file}
		
    		echo not empty,starting script 
		java -jar /opt/ontology/scripts/blue_frame_atm/XlsToCsv.jar /opt/ontology/scripts/blue_frame_atm/upload/"${file}" /opt/ontology/scripts/blue_frame_atm/upload/

		
		
			for audname in *.csv
			do
				ls -l "$audname" > output1.csv
				echo ${audname}
				
				switch_name=($(awk  '{print $9}' output1.csv | cut -d . -f 1 ))
				echo ${switch_name}
				 awk -F, 'length>NF+1' ${audname} | sed "s|^|${switch_name},|"  >> output.csv
				
			done

		rm output1.csv

		${SQLLOAD2} control='/opt/ontology/scripts/blue_frame_atm/network_frame_blue_temp.ctl',LOG="/opt/ontology/scripts/blue_frame_atm/network_frame_blue_temp.log",ERRORS=100

		gzip -c *.csv > /opt/ontology/scripts/blue_frame_atm/upload_zipfiles/upload$DATETIME.gz
		gzip -c *.xls > /opt/ontology/scripts/blue_frame_atm/upload_zipfiles/upload_xls_$DATETIME.gz
		rm *.csv
		rm *.xls
		find /opt/ontology/scripts/blue_frame_atm/upload_zipfiles/*.gz -mtime +180 -delete
	done


${SQL2} << EOF > /opt/ontology/scripts/blue_frame_atm/network_frame_blue_temp_proc.log
WHENEVER SQLERROR EXIT sql.sqlcode; 
set pagesize 0; 
SET LONG 50000; 
set trimspool on; 
set trimout on; 
set headsep on; 
set linesize 32767; 
set feedback off; 
set echo off; 

DECLARE 
NO_RECORDER_NEW VArchar2(10);
NO_RECORDER_NEW1 VArchar2(10);
NULL_VALUES VArchar2(10);
OLD_RECORDS VARCHAR2(10);
flag NUMBER;

BEGIN
flag := 0;

SELECT COUNT (DISTINCT NODE||PORT||sbearer ) INTO NO_RECORDER_NEW1 from network_frame_blue_temp;

SELECT COUNT(*) INTO NO_RECORDER_NEW from network_frame_blue_temp;

SELECT COUNT(*) into OLD_RECORDS FROM network_frame_blue;


IF NO_RECORDER_NEW1 != NO_RECORDER_NEW THEN

	insert into PRT_MANUAL_UPLOAD_TRACKER values ( SYSDATE , 'BLUE FRAME ATM' , 'Duplicate entries are present.' );

	flag:= ( flag + 1);
end if;
IF OLD_RECORDS > NO_RECORDER_NEW THEN
	IF ( OLD_RECORDS - NO_RECORDER_NEW ) > 50 THEN
		insert into PRT_MANUAL_UPLOAD_TRACKER values ( SYSDATE , 'BLUE FRAME ATM' , 'Difference between old and new records is more than 50.' );

		flag:= ( flag + 1);
	END IF;

end if;

if flag = 0 then 



			INSERT INTO network_frame_blue_bkp ( ARCHIVE_DATE ,NODE,MORI333,FRUNI,UNLCK,ENA,LMI_STATUS1,LMI_STATUS2,ANSI,FIELD1,FIELD2,PORT,SBEARER,Nx64K,
PRT_STATUS,CIRCUIT_REF,JASON_ACTION,CUSTOMER,INCLUDE,ORDER_REF,COMMENTS,PRT_SERVICEID,UPLOAD_DATE ) 
SELECT SYSDATE ,NODE,MORI333,FRUNI,UNLCK,ENA,LMI_STATUS1,LMI_STATUS2,ANSI,FIELD1,FIELD2,PORT,SBEARER,Nx64K,
PRT_STATUS,CIRCUIT_REF,JASON_ACTION,CUSTOMER,INCLUDE,ORDER_REF,COMMENTS,PRT_SERVICEID,UPLOAD_DATE FROM network_frame_blue ;

DELETE FROM network_frame_blue_bkp WHERE archive_date IN ( Select archive_date from network_frame_blue_bkp where To_Char(archive_date,'YYYYMM') < to_char(add_months(trunc(sysdate,'mm'),-3),'YYYYMM') AND TO_DATE(archive_date,'DD-MON-YYYY') in  (select * from (
SELECT distinct TO_DATE(archive_date,'DD-MON-YYYY')  from network_frame_blue_bkp ORDER BY  TO_DATE(archive_date,'DD-MON-YYYY') asc) where rownum < 2 ) ) ;

EXECUTE IMMEDIATE 'TRUNCATE TABLE network_frame_blue' ;


insert into network_frame_blue  (UPLOAD_DATE,NODE ,FRUNI,UNLCK,ENA,LMI_STATUS1,LMI_STATUS2,ANSI,FIELD1,FIELD2,PORT,SBEARER,Nx64K,COMMENTS,JASON_ACTION) 
select SYSDATE, NODE ,FRUNI,UNLCK,ENA,LMI_STATUS1,LMI_STATUS2,ANSI,FIELD1,FIELD2,PORT,SBEARER,Nx64K,COMMENTS,JASON_ACTION from network_frame_blue_temp;



#UPDATE ONTOLOGY.NETWORK_EXTRACT SET extract_date = sysdate where extract_no= '5';


update network_frame_blue set PRT_STATUS  =  DECODE ( UPPER(JASON_ACTION) , 'LIVE', 'LIVE',                                                
                              'CEASE', 'DEAD',
                              'COMPLETED','DEAD',
                              'DELETED', 'DEAD',
                               null);

update network_frame_blue b set ( b.MORI333, b.CIRCUIT_REF, b.CUSTOMER, b.INCLUDE, b.ORDER_REF, b.PRT_SERVICEID ) =
 
( SELECT k.MORI333, k.CIRCUIT_REF ,k.CUSTOMER, k.INCLUDE,k.ORDER_REF, k.PRT_SERVICEID from network_frame_blue_bkp k where k.ARCHIVE_DATE = b.UPLOAD_DATE 
and k.NODE||k.PORT = b.NODE||b.PORT );
 
SELECT COUNT(*) INTO NULL_VALUES FROM network_frame_blue WHERE INCLUDE IS NULL;


END IF;
IF NULL_VALUES > 0 THEN

	insert into PRT_MANUAL_UPLOAD_TRACKER values ( SYSDATE , 'BLUE FRAME ATM' , 'Include field is null, but file is uploaded.' );

	
else

insert into PRT_MANUAL_UPLOAD_TRACKER values ( SYSDATE , 'BLUE FRAME ATM' , 'File uploaded successfully.' );
end if;

--EXECUTE IMMEDIATE 'update network_frame_green g set g.CUSTOMER_NAME = (select CUSTOMER_NAME from network_frame_green_bkp b where b.path_name = g.path_name and b.import_date = g.file_date ) ,


commit;

--END IF;



END;
/
EOF
	
else
cd ..
    echo The directory "${file}" is empty '(or non-existent)' 
fi 


