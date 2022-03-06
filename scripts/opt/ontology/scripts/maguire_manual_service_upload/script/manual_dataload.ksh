#!/bin/sh

APP_DIR="/opt/ontology/scripts/maguire_manual_service_upload"
ONTOLOGY_INPUT="/opt/ontology/input"
MAGUIRE_MANUAL_SERVICE_PATH="/opt/ontology/input/Maguire_manual_service/Service_file"

cd ${APP_DIR}

. ${APP_DIR}/ENV/devEnv.ksh


export DATETIME=`date +"%d%m%Y%H%M%S"`
export format_date="${DATETIME:0:2}/${DATETIME:2:2}/${DATETIME:4:4} ${DATETIME:8:2}:${DATETIME:10:2}:${DATETIME:12:2}"
echo $format_date

cd $SOURCE_DIR
audname="Maguire_Manual_Service_Upload.csv"

if test -f "$audname"; then 
echo not empty,starting script >> ${LOG_DIR}/maguire_manual_file_exist.log
dos2unix ${SOURCE_DIR}/Sample_Maguire_Manual_Upload.csv 

${SQL1} << EOF 
       
    WHENEVER SQLERROR EXIT sql.sqlcode;

		SET ECHO OFF 
        SET HEADING OFF
        SET HEADING OFF
 INSERT INTO maguire_manual_upload_tracking (FILENAME, VALIDATION, DESCRIPTION, SEQUENCE_NO, UPLOAD_TIME)
VALUES('$audname', 'PENDING', NULL, MAGUIRE_MANUAL_SERV_SEQUENCE.nextval, TO_DATE('$format_date','dd/mm/yyyy HH24:MI:SS'));	
COMMIT;

EOF
 
# exit 10		
audnametype=$(file $audname)
		
echo $audnametype

if [[ "$audnametype" == *"ASCII"* ]] ; then

#awk -v RS='"[^"]*"' -v ORS= '{gsub(/\n/, " ", RT); print $0  RT}' file   ##to removenewline.
awk -v RS='"[^"]*"' -v ORS= '{gsub(/\n/, " ", RT); print $0  RT}' $audname > rmvNewline_1.csv
# sed -i '/^$/d' rmvNewline_1.csv > rmvNewline_2.csv
grep -v '^$' rmvNewline_1.csv > rmvNewline_2.csv
awk '{printf "\"%s\",%s\n", NR==1 ? "Sequence_no" : NR-1, $0}' rmvNewline_2.csv > rmvNewline.csv
audname1=$audname
audname=rmvNewline.csv

${SQLLOAD1} control=${SCRIPT_DIR}/dataload.ctl,LOG=${LOG_DIR}/maguire_manual_file_control.log,ERRORS=100

gzip -c  ${SOURCE_DIR}/"$audname1" >  ${BACKUP_DIR}/$audname1"_"$DATETIME.gz
rm "${audname}"
rm "${audname1}"
rm *.*

${SQL1} << EOF 

WHENEVER SQLERROR EXIT sql.sqlcode;

SET ECHO OFF
SET HEADING OFF
SET HEADING OFF
update maguire_manual_upload_tracking set VALIDATION='In Progress' where UPLOAD_TIME=TO_DATE('$format_date','dd/mm/yyyy HH24:MI:SS');	
COMMIT;

EOF

${SQL1} << EOF >  ${LOG_DIR}/proc.log

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
MAG_VALIDATE_MANUAL_SERVICE.RUN_VALIDATION;
END; 

/
EOF


count_val=`${SQL1}<< END
 

WHENEVER SQLERROR EXIT sql.sqlcode; 
set serveroutput on;
set pages 0;
set head off;
set linesize 100;
set trimspool on;
set feedback off; 
set echo off;

SELECT TRIM(COUNT(*)) FROM MAGUIRE_TEMP_MANUAL_SERVICE WHERE VALIDATE_COL='N';
EXIT; 
END`

if [ "$count_val" -eq 0 ]
then


cd ${PROCESS_DIR}
${SQL1} << EOF 
       
    WHENEVER SQLERROR EXIT sql.sqlcode;

		SET ECHO OFF 
        SET HEADING OFF
        SET HEADING OFF
 update maguire_manual_upload_tracking set VALIDATION='In Progress',DESCRIPTION='Validation Successful and File extracting' where UPLOAD_TIME=TO_DATE('$format_date','dd/mm/yyyy HH24:MI:SS');	
COMMIT;

EOF

${SQL}<< END >/dev/null

         
SET NEWP 0 SPACE 0 PAGES 0 FEED OFF HEAD OFF TRIMS OFF TRIM OFF TAB OFF;
set colsep '@#@';
set pagesize 0;
SET LONG 50000;
set trimspool on; 
set trimout on;
set headsep on;
set linesize 32767;
set feedback off; 
set echo off; 
SET TAB OFF;
SET WRAP on;
set longchunksize 32767;

spool ${PROCESS_DIR}/test_sql.txt

select TO_CLOB(SELECT_BLOCK)||' '||TO_CLOB(FROM_BLOCK)||' '||TO_CLOB(WHERE_BLOCK) FROM GEN_JSON_CONFIG where JSON_NAME= 'Maguire_Manual_service_UI';

spool off

EXIT 
END


query=$(head -n 1 ${PROCESS_DIR}/test_sql.txt)
cat ${PROCESS_DIR}/test_sql.txt | sed 's/||/||\n/g' | sed 's/,regexp_replace/\n,regexp_replace/g' > ${PROCESS_DIR}/test_sql1.txt

updated_query=`cat ${PROCESS_DIR}/test_sql1.txt`

${SQL}  <<EOF >/dev/null

SET NEWP 0 SPACE 0 PAGES 0 FEED OFF HEAD OFF TRIMS OFF TRIM OFF TAB OFF;
set pagesize 0;
SET LONG 50000;
set trimspool on; 
set trimout on;
set headsep on;
set linesize 32767;
set feedback off; 
set echo off; 
SET TAB OFF;
SET WRAP on;
set longchunksize 32767;

spool ${PROCESS_DIR}/Maguire_Manual_Services_raw.csv

${updated_query}

spool off
EXIT
EOF

if [ $? -ne 0 ]
then
f_write_to_log "File Generation Failed For File Maguire_Manual_Services_raw.csv  "
${SQL1} << EOF 
       
    WHENEVER SQLERROR EXIT sql.sqlcode;

		SET ECHO OFF 
        SET HEADING OFF
        SET HEADING OFF
 update maguire_manual_upload_tracking set VALIDATION='Failed',DESCRIPTION='Validation successful but file extract fail, contact IT team' where UPLOAD_TIME=TO_DATE('$format_date','dd/mm/yyyy HH24:MI:SS');	
COMMIT;

EOF
exit 10
else
count_val2=`${SQL1}<< END
WHENEVER SQLERROR EXIT sql.sqlcode; 
set serveroutput on;
set pages 0;
set head off;
set linesize 100;
set trimspool on;
set feedback off; 
set echo off;

SELECT TRIM(COUNT(*)) FROM MAGUIRE_TEMP_MANUAL_SERVICE WHERE WARN_VALDT_COL='N';
EXIT; 
END`

if [ "$count_val2" -eq 0 ]
then
${SQL1} << EOF 

WHENEVER SQLERROR EXIT sql.sqlcode;

SET ECHO OFF 
SET HEADING OFF
SET HEADING OFF
update maguire_manual_upload_tracking set VALIDATION='Successful',DESCRIPTION='Validation successful and file extract successful' where UPLOAD_TIME=TO_DATE('$format_date','dd/mm/yyyy HH24:MI:SS');	
COMMIT;

EOF

else

${SQL1} << EOF 

WHENEVER SQLERROR EXIT sql.sqlcode;

SET ECHO OFF 
SET HEADING OFF
SET HEADING OFF
update maguire_manual_upload_tracking set VALIDATION='Successful with warning',DESCRIPTION='Validation successful with warning and file extract successful' where UPLOAD_TIME=TO_DATE('$format_date','dd/mm/yyyy HH24:MI:SS');	
COMMIT;

EOF

fi
cd ${MAGUIRE_MANUAL_SERVICE_PATH}

rm Maguire_Manual_Services.csv

cat ${HEADER}/header.csv > Maguire_Manual_Services.csv

cd ${MAGUIRE_MANUAL_SERVICE_PATH}

cat ${PROCESS_DIR}/Maguire_Manual_Services_raw.csv >> Maguire_Manual_Services.csv

rm ${PROCESS_DIR}/Maguire_Manual_Services_raw.csv

cd ${PROCESS_DIR}

rm *.*
fi
else
${SQL1} << EOF 
       
    WHENEVER SQLERROR EXIT sql.sqlcode;

		SET ECHO OFF 
        SET HEADING OFF
        SET HEADING OFF
 update maguire_manual_upload_tracking set VALIDATION='Failed',DESCRIPTION='Wrong data, check error log' where UPLOAD_TIME=TO_DATE('$format_date','dd/mm/yyyy HH24:MI:SS');	
COMMIT;

EOF
fi

else
echo "Invalid File"
${SQL1} << EOF 
       
    WHENEVER SQLERROR EXIT sql.sqlcode;

		SET ECHO OFF 
        SET HEADING OFF
        SET HEADING OFF
 update maguire_manual_upload_tracking set VALIDATION='Failed',DESCRIPTION='Wrong file format' where UPLOAD_TIME=TO_DATE('$format_date','dd/mm/yyyy HH24:MI:SS');	
COMMIT;

EOF

awk -v RS='"[^"]*"' -v ORS= '{gsub(/\n/, " ", RT); print $0  RT}' $audname > rmvNewline.csv
audname1=$audname
audname=rmvNewline.csv

gzip -c  ${SOURCE_DIR}/"$audname1" >  ${BACKUP_DIR}/$audname1"_InvalidFile_"$DATETIME.gz
rm "${audname}"
rm "${audname1}"
rm *.*
#exit
fi
# exit 10
cd ${SOURCE_DIR}
rm *.*	


else

if [ "$(ls -A $SOURCE_DIR)" ]; then
     echo "Taking action $SOURCE_DIR is not Empty"
	 for wrongfile in *.*
do

${SQL1} << EOF 
       
    WHENEVER SQLERROR EXIT sql.sqlcode;

		SET ECHO OFF 
        SET HEADING OFF
        SET HEADING OFF
 INSERT INTO maguire_manual_upload_tracking (FILENAME, VALIDATION, DESCRIPTION, SEQUENCE_NO, UPLOAD_TIME)
VALUES('$wrongfile', 'Failed', 'Wrong file name', MAGUIRE_MANUAL_SERV_SEQUENCE.nextval, TO_DATE('$format_date','dd/mm/yyyy HH24:MI:SS'));	
COMMIT;

EOF

gzip -c  ${SOURCE_DIR}/"$wrongfile" >  ${BACKUP_DIR}/$wrongfile"_WrongFileName_"$DATETIME.gz
rm "${wrongfile}"
done
rm *.*
else
    echo "$SOURCE_DIR is Empty"
fi

echo The directory $SOURCE_DIR is empty '(or non-existent)' >> ${LOG_DIR}/maguire_manual_file_not_exist.log
exit 10
fi 


# find /opt/ontology/input/Annoations-File-Upload/upload_zipfiles/*.gz -mtime +180 -delete






