#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/maguire/script"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="maguire_dataanlyst_package_executer"
RUN_DATE=`date +%Y%m%d`
LOG_FILE=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}.log
echo "Log File Name :  ${LOG_FILE}"
time_stmp=`cat ${CONFIG_DIR}/timestamp.txt`

counter=0
packageExecutionCounter=0
f_write_to_log "count and packageExecutionCounter variable initialized to 0"
IntialisenoOfParallelProcess=$(<${CONFIG_DIR}/noOfParallelProcess.txt)
f_write_to_log "Parallel process count $IntialisenoOfParallelProcess"
f_write_to_log "fetching package name"
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

spool ${CONFIG_DIR}/packageExecutionList.txt

SELECT TRIM( PACKAGE_NAME) PACKAGE_NAME FROM ONTOLOGY.MAGUIRE_PACKAGE_CONFIG WHERE INCLUDE_YN='Y';

spool off

EXIT 
END

#noOfPackageExecution=wc -l ${CONFIG_DIR}/packageExecutionList.txt | cut -d " " -f 1 
noOfPackageExecution=$(< ${CONFIG_DIR}/packageExecutionList.txt wc -l )
f_write_to_log "noOfPackageExecution : $noOfPackageExecution"
if [ noOfPackageExecution = 0 ]
then
f_write_to_log "No package available. so, stopping script and removing packageExecutionList.txt"
rm ${CONFIG_DIR}/packageExecutionList.txt
exit 10
fi	


while [ : ]
do 

if test -f "${CONFIG_DIR}/populateAnnotationComplete.txt";
then
f_write_to_log "populate annotation complete and file watcher populateAnnotationComplete.txt removed "
rm ${CONFIG_DIR}/populateAnnotationComplete.txt

${SQLONTO} << EOF
UPDATE prt_u_view_transaction_status SET FLAG_VALUE='IN PROGRESS' WHERE TRANSACTION_DATE='$time_stmp' 
AND DETAIL='MAGUIRE DB PACKAGE SCRIPT STATUS';
COMMIT;
EOF

while read configLine ;
do


configLine1="$(echo -e "${configLine}" | tr -d '[[:space:]]' | tr -d '\015' | tr -d '\n' )"



f_write_to_log "$configLine1 pkg is going to call"

sh -x /opt/ontology/scripts/maguire/script/call_package.ksh $configLine1 &



packageExecutionCounter=`expr $packageExecutionCounter + 1`

sleep 20

[[ $((packageExecutionCounter%IntialisenoOfParallelProcess)) -eq 0 ]] && wait

done < ${CONFIG_DIR}/packageExecutionList.txt

wait
f_write_to_log "All package completed successful"
f_write_to_log "Remove packageExecutionList.txt"
rm ${CONFIG_DIR}/packageExecutionList.txt

#touch ${CONFIG_DIR}/executionOFDataanalystPackagesCompleted
#exit 0

# ${SQLONTO} << EOF
# INSERT INTO prt_u_view_transaction_status (TRANSACTION_DATE, DETAIL, FLAG_VALUE, TRANSACTION_TIME, JSON_START_DATE, JSON_END_DATE, SERVER_NAME, VIEW_DETAIL)
# VALUES('$time_stmp','MAGUIRE_DATA_REFRESH','IN PROGRESS',TO_CHAR(SYSTIMESTAMP),TO_CHAR(SYSDATE,'dd-mm-yyy hh:mm:ss'),NULL,'MAIN1','MAGUIRE VIEW');

# COMMIT;
# EOF

${SQLONTO} << EOF >  ${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}_maguire_d_refresh.log

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
MAGUIRE_DATA_REFRESH.RUN_ALL();
END; 

/
EOF

${SQLONTO} << EOF
UPDATE prt_u_view_transaction_status SET FLAG_VALUE='COMPLETED',JSON_END_DATE= TO_CHAR(SYSDATE,'dd-mm-yyyy hh:mm:ss')    WHERE TRANSACTION_DATE='$time_stmp' 
AND DETAIL='MAGUIRE DB PACKAGE SCRIPT STATUS';
COMMIT;
EOF

if [ $? -ne 0 ]
then
        f_write_to_log "Problem Occured While Executing MAGUIRE_DATA_REFRESH package From DATAANALYST Schema !!! Terminating The Process !!!"
        exit 10
else
		touch ${CONFIG_DIR}/magureDAPkgExecuterComplete.txt
        f_write_to_log "MAGUIRE_DATA_REFRESH package completed successfully "
		exit 0
fi


else

counter=`expr $counter + 1`
f_write_to_log "Count value is $counter"
sleep 1
if [ "$counter" -eq 36 ]
then

f_write_to_log "populate annotation didnot run today"
rm ${CONFIG_DIR}/packageExecutionList.txt
exit 10
fi

fi

done

