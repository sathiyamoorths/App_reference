#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/maguire/script"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="check_populate_annotations_status"
RUN_DATE=`date +%Y%m%d`
LOG_FILE=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}.log
echo "Log File Name :  ${LOG_FILE}"
time_stamp=`date "+%Y-%m-%d %H:%M:%S"`

count=1

cd ${CONFIG_DIR}
if [ $? -eq 0 ]
then
rm ${CONFIG_DIR}/populateAnnotationComplete.txt
f_write_to_log "old populateAnnotationComplete file watcher remove, if exists"
fi

while [ : ]
do

flagvalue1=`sqlplus -s ${ORAUSERON}/${ORAPASSON}@${ORAHOST}:${ORAPORT}/${ORASERVICE}<< END
         

        WHENEVER SQLERROR EXIT sql.sqlcode; 
set serveroutput on;
	set pages 0;
	set head off;
	set linesize 100;
	set trimspool on;
	set feedback off; 
        set echo off;

select trim(count(status)) from prt_dataload_status where PACKAGE_NAME='POPULATE_ANNOTATION' and to_date(STARTTIME,'dd-mon-yy')=to_date(sysdate,'dd-mon-yy') and STATUS='COMPLETED';
EXIT; 
END`

f_write_to_log "flagvalue1 is $flagvalue1"

flagvalue2=`sqlplus -s ${ORAUSERON}/${ORAPASSON}@${ORAHOST}:${ORAPORT}/${ORASERVICE}<< END
 WHENEVER SQLERROR EXIT sql.sqlcode; 
set serveroutput on;
	set pages 0;
	set head off;
	set linesize 100;
	set trimspool on;
	set feedback off; 
        set echo off;
select trim(count(status)) from prt_dataload_status where PACKAGE_NAME='POPULATE_ANNOTATION' and to_date(STARTTIME,'dd-mon-yy')=to_date(sysdate,'dd-mon-yy') and STATUS like '%FAILED%';
EXIT;
END`

f_write_to_log "flagvalue2 is $flagvalue2"

if [ "$flagvalue1" -gt 0 ] 
then

cd ${CONFIG_DIR}

touch ${CONFIG_DIR}/populateAnnotationComplete.txt
echo $time_stamp > ${CONFIG_DIR}/timestamp.txt

${SQLONTO} << EOF
INSERT INTO prt_u_view_transaction_status (TRANSACTION_DATE, DETAIL, FLAG_VALUE, TRANSACTION_TIME, JSON_START_DATE, JSON_END_DATE, SERVER_NAME, VIEW_DETAIL)
VALUES('$time_stamp','MAGUIRE DB PACKAGE SCRIPT STATUS','PENDING',TO_CHAR(SYSTIMESTAMP),TO_CHAR(SYSDATE,'dd-mm-yyyy hh:mm:ss'),NULL,'MAIN1','MAGUIRE VIEW');

COMMIT;
EOF

f_write_to_log "populateAnnotationComplete file watcher created, exit from script"
exit 0

else
f_write_to_log "going for sleep"
sleep 5m
count=`expr $count + 1`
f_write_to_log "count value is $count"
if [ "$count" -eq 36 ] || [ "$flagvalue2" -gt 0 ]
then

cd ${CONFIG_DIR}
if [ $? -eq 0 ]
then
rm ${CONFIG_DIR}/populateAnnotationComplete.txt
fi
f_write_to_log "Populate annotation pkg didn't run, quit from script"
exit 10

fi


fi



done