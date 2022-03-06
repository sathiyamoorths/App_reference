#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/maguire/script"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="delete_30days_old_logs"
RUN_DATE=`date +%Y%m%d`
LOG_FILE=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}.log
echo "Log File Name :  ${LOG_FILE}"

######################################################################################################################################################################
#
#	Script Name :- /opt/ontology/scripts/maguire/script/delete_30days_old_logs.ksh
#	Author      :- TCS
#	Date        :- 1st August 2020
#	Scheduling  :- Crontab (Monthly Once . 1st Of Every Month . At 12:00 AM BST)	
#
#
#	Description :- This Script Deletes 30 Days olod Logs From Both DB And Unix Box (House Keeping)
#
#
#
#######################################################################################################################################################################


#Change The Directory To Find If Directory Exists Or Not
cd ${LOG_DIR}
if [ $? -ne 0 ]
then
	f_write_to_log "Problem In Changing Directory To  ${LOG_DIR} !!! Terminating The Process !!!"
        exit 10
else
        f_write_to_log "Directory Sucessfully Changed To  ${LOG_DIR}."
fi

#Delete 30 Days old Logs
find "${LOG_DIR}" -mtime +30 -delete
if [ $? -ne 0 ]
then
        f_write_to_log "30 Days Old Logs Could Not Be Deleted !!! Terminating The Process !!!"
        exit 10
else
        f_write_to_log "30 Days Old Logs Are Deleted."
fi

#Connect To Dataanalyst Schema For Deletion  Of Old Logs
$ORACLE_HOME/bin/sqlplus -s ${ORAUSERDATA}/${ORAPASSDATA}@${ORAHOST}:${ORAPORT}/${ORASERVICE}<<EOF
set serveroutput on;
whenever sqlerror exit 10 rollback;
whenever oserror exit 10 rollback;
DELETE FROM DATAANALYST.MAGUIRE_ETL_LOG WHERE TRUNC(PROCESS_START_TIME) < TRUNC( SYSDATE - 30 );
COMMIT;
exit;
EOF
if [ $? -ne 0 ]
then
        f_write_to_log "Problem Occured While Executing SQL Query For Deltion Of Logs From DATAANALYST Schema !!! Terminating The Process !!!"
        exit 10
else
        f_write_to_log "30 Days Old Logs Deleted From DATAANALYST.MAGUIRE_ETL_LOG Sucesssfully."
fi

#Connect To ontology Schema For Deletion  Of Old Logs
$ORACLE_HOME/bin/sqlplus -s ${ORAUSERON}/${ORAPASSON}@${ORAHOST}:${ORAPORT}/${ORASERVICE}<<EOF
set serveroutput on;
whenever sqlerror exit 10 rollback;
whenever oserror exit 10 rollback;
DELETE FROM ONTOLOGY.MAGUIRE_ETL_LOG WHERE TRUNC(PROCESS_START_TIME) < TRUNC( SYSDATE - 30 );
COMMIT;
exit;
EOF
if [ $? -ne 0 ]
then
        f_write_to_log "Problem Occured While Executing SQL Query For Deltion Of Logs From ONTOLOGY Schema !!! Terminating The Process !!!"
        exit 10
else
        f_write_to_log "30 Days Old Logs Deleted From ONTOLOGY.MAGUIRE_ETL_LOG Sucesssfully."
fi
exit 0
