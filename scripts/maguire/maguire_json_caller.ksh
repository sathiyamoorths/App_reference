#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/maguire/script"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="maguire_json_caller"
RUN_DATE=`date +%Y%m%d`
LOG_FILE=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}.log
echo "Log File Name :  ${LOG_FILE}"
time_stmp=`cat ${CONFIG_DIR}/timestamp.txt`

counter=0
jsonExecutionCounter=0
#IntialisenoOfParallelProcess=$(<${CONFIG_DIR}/noOfParallelProcess.txt)

IntialisenoOfParallelProcess=10

f_write_to_log "starting ${SCRIPTNAME} "

while [ : ]
do

	if test -f "${CONFIG_DIR}/magureDAPkgExecuterComplete.txt"; 

	then


flagvalue1=`sqlplus -s ${ORAUSERON}/${ORAPASSON}@${ORAHOST}:${ORAPORT}/${ORASERVICE}<< END
WHENEVER SQLERROR EXIT sql.sqlcode; 
set serveroutput on;
set pages 0;
set head off;
set linesize 100;
set trimspool on;
set feedback off; 
set echo off;
select trim(count(PACKAGE_NAME)) from prt_dataload_status where PACKAGE_NAME='MAGUIRE_DATA_REFRESH' and 	STATUS='COMPLETED';
EXIT;
END`
#flagvalue1=1
			if [ "$flagvalue1" -gt 0 ]; 
			then
##START JSON
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

spool ${CONFIG_DIR}/jsonNameList.txt

select trim(JSON_NAME) from maguire_json_config where INCLUDE_YN='Y';

spool off

EXIT 
END

noOfJsonExecution=$(wc -l ${CONFIG_DIR}/jsonNameList.txt | cut -d " " -f 1 )

while read configLine ;
do

configLine1="$(echo -e "${configLine}" | tr -d '[[:space:]]' | tr -d '\015' | tr -d '\n' )"

${SQLONTO} << EOF
INSERT INTO prt_u_view_transaction_status (TRANSACTION_DATE, DETAIL, FLAG_VALUE, TRANSACTION_TIME, JSON_START_DATE, JSON_END_DATE, SERVER_NAME, VIEW_DETAIL)
VALUES('$time_stmp','$configLine1','IN PROGRESS',TO_CHAR(SYSTIMESTAMP),TO_CHAR(SYSDATE,'dd-mm-yyyy hh:mm:ss'),NULL,'MAIN1','MAGUIRE VIEW');

COMMIT;
EOF

ksh -x /opt/ontology/scripts/maguire/script/maguire_generalized_json_creation.ksh $configLine1 &

jsonExecutionCounter=`expr $jsonExecutionCounter + 1`
echo $jsonExecutionCounter
sleep 20

[[ $((jsonExecutionCounter%IntialisenoOfParallelProcess)) -eq 0 ]] && wait

done < ${CONFIG_DIR}/jsonNameList.txt

wait
			
			f_write_to_log "All Json creation completed successfully, exit from script"
			
			cd ${CONFIG_DIR}
			if [ $? -eq 0 ]
			then
			rm magureDAPkgExecuterComplete.txt
			rm jsonNameList.txt
			fi
			exit 0

			else
				f_write_to_log "MAGUIRE_DATA_REFRESH failed and quit script "
				exit 10
			fi
	else
		f_write_to_log "count value is $counter"
		counter=`expr $counter + 1`
		f_write_to_log "waiting for MAGUIRE_DATA_REFRESH, going for sleep"
		sleep 5m
		if [ "$counter" -eq 36 ]
		then

		f_write_to_log "MAGUIRE_DATA_REFRESH failed and quit script"
		
		exit 10
		fi

		#continue
	fi



done
