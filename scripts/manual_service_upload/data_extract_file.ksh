#!/bin/sh

APP_DIR="/opt/ontology/scripts/manual_service_upload"
ONTOLOGY_INPUT="/opt/ontology/input"
MANUAL_SERVICE_PATH="/opt/ontology/input/Manual_service/Service_file"

cd ${APP_DIR}

. ${APP_DIR}/ENV/devEnv.ksh


export DATETIME=`date +"%d%m%Y%H%M%S"`
export format_date="${DATETIME:0:2}/${DATETIME:2:2}/${DATETIME:4:4} ${DATETIME:8:2}:${DATETIME:10:2}:${DATETIME:12:2}"
echo $format_date

cd $SOURCE_DIR
audname="Manual_Service_Upload.csv"

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

select TO_CLOB(SELECT_BLOCK)||' '||TO_CLOB(FROM_BLOCK)||' '||TO_CLOB(WHERE_BLOCK) FROM GEN_JSON_CONFIG where JSON_NAME= 'Manual_service_UI';

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

spool ${PROCESS_DIR}/Manual_Services_raw.csv

${updated_query}

spool off
EXIT
EOF

cd ${MANUAL_SERVICE_PATH}

rm Manual_Services.csv

cat ${HEADER}/header.csv > Manual_Services.csv

cd ${MANUAL_SERVICE_PATH}

cat ${PROCESS_DIR}/Manual_Services_raw.csv >> Manual_Services.csv

rm ${PROCESS_DIR}/Manual_Services_raw.csv

cd ${PROCESS_DIR}

rm *.*