#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/maguire/script"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="call_package"
RUN_DATE=`date +%Y%m%d`
pass="${1}"
LOG_FILE=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}_${pass}.log
echo "Log File Name :  ${LOG_FILE}"
time_stmp=`cat ${CONFIG_DIR}/timestamp.txt`

pkg_name_var="${pass}.Run_All();"


# ${SQLONTO} << EOF
# INSERT INTO prt_u_view_transaction_status (TRANSACTION_DATE, DETAIL, FLAG_VALUE, TRANSACTION_TIME, JSON_START_DATE, JSON_END_DATE, SERVER_NAME, VIEW_DETAIL)
# VALUES('$time_stmp','$pass','PENDING',TO_CHAR(SYSTIMESTAMP),TO_CHAR(SYSDATE,'dd-mm-yyyy hh:mm:ss'),NULL,'MAIN1','MAGUIRE VIEW');

# COMMIT;
# EOF

${SQLDA} << EOF >  ${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}_${pass}_sql.log

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
${pkg_name_var}
END; 

/
EOF



if [ $? -ne 0 ]
then
        f_write_to_log "Problem Occured While Executing ${pass} package From DATAANALYST Schema !!! Terminating The Process !!!"
        exit 10
else
        f_write_to_log "${pass} package completed successfully "
fi