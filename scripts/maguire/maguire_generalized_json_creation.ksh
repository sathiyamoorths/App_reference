#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/maguire/script"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="maguire_generalized_json_creation"
RUN_DATE=`date +%Y%m%d`
LOG_FILE=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}_${1}.log
echo "Log File Name :  ${LOG_FILE}"
#passing_value="maguire_test"
passing_value="${1}"
f_write_to_log "passing value $passing_value"
f_write_to_log "Fetching ${1}.json query from config table"
time_stmp=`cat ${CONFIG_DIR}/timestamp.txt`

${SQLONTO}<< END >/dev/null

         
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

spool ${CONFIG_DIR}/${passing_value}_sql_json.txt

select TO_CLOB(SELECT_BLOCK)||' '||TO_CLOB(FROM_BLOCK)||' '||TO_CLOB(WHERE_BLOCK) FROM maguire_json_config where JSON_NAME= '${passing_value}';

spool off
EXIT; 
END

cat ${CONFIG_DIR}/${passing_value}_sql_json.txt | sed 's/||/||\n/g'  > ${CONFIG_DIR}/${passing_value}_sql_json1.txt

json_sql_query=`cat ${CONFIG_DIR}/${passing_value}_sql_json1.txt`
echo $json_sql_query
f_write_to_log "Fetching ${passing_value}.JSON data from config table"

${SQLONTO}  <<EOF >/dev/null


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

spool ${CONFIG_DIR}/${passing_value}_maguire_data.txt

$json_sql_query
spool off
EXIT;
EOF

f_write_to_log "remove last char ','"
sed -i '$ s/.$//' ${CONFIG_DIR}/${passing_value}_maguire_data.txt

f_write_to_log "add '[' at start"
sed -i '1s/^/[ /' ${CONFIG_DIR}/${passing_value}_maguire_data.txt

f_write_to_log "add '}]' at end"
sed -i '$ s/.$/}]/' ${CONFIG_DIR}/${passing_value}_maguire_data.txt

f_write_to_log "remove '\' from file"
sed -i 's/\\//g' ${CONFIG_DIR}/${passing_value}_maguire_data.txt

f_write_to_log "remove tab '\t'"
sed -i 's/\t//g' ${CONFIG_DIR}/${passing_value}_maguire_data.txt

f_write_to_log "remove  carriage return"
sed -i 's/\r//g' ${CONFIG_DIR}/${passing_value}_maguire_data.txt

f_write_to_log "remove new line"
sed -i ':a;N;$!ba;s/\n//g' ${CONFIG_DIR}/${passing_value}_maguire_data.txt



f_write_to_log "rename json from ${passing_value}_maguire_data.txt to ${passing_value}_${RUN_DATE}.JSON"

mv ${CONFIG_DIR}/${passing_value}_maguire_data.txt ${CONFIG_DIR}/${passing_value}_${RUN_DATE}.json

f_write_to_log "moving ${passing_value}_${RUN_DATE}.json to output dir : ${OUTPUT_DIR} "

mv ${CONFIG_DIR}/${passing_value}_${RUN_DATE}.json ${OUTPUT_DIR}/${passing_value}_${RUN_DATE}.json

f_write_to_log "moving ${passing_value}_${RUN_DATE}.json to /opt/ontology/output"

cp ${OUTPUT_DIR}/${passing_value}_${RUN_DATE}.json /opt/ontology/output

mv /opt/ontology/output/${passing_value}_${RUN_DATE}.json /opt/ontology/output/${passing_value}.json

chmod -R 0644 /opt/ontology/output/${passing_value}.json

cd ${CONFIG_DIR}
if [ $? -eq 0 ]
then

rm ${passing_value}_sql_json.txt
rm ${passing_value}_sql_json1.txt

fi


${SQLONTO} << EOF
UPDATE prt_u_view_transaction_status SET FLAG_VALUE='COMPLETED',JSON_END_DATE= TO_CHAR(SYSDATE,'dd-mm-yyyy hh:mm:ss')    WHERE TRANSACTION_DATE='$time_stmp' 
AND DETAIL='$passing_value';
COMMIT;
EOF