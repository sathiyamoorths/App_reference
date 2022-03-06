#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/serviceview_json/script"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="delete_30days_old_logs"
RUN_DATE=`date +%Y%m%d`
LOG_FILE=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}.log
echo "Log File Name :  ${LOG_FILE}"

######################################################################################################################################################################
#
#	Script Name :- /opt/ontology/scripts/serviceview_json/script/delete_30days_old_logs.ksh
#	Author      :- TCS
#	Date        :- 15th January 2021
#	Scheduling  :- Crontab Schedule Daily at 15:00 BST
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

#Change The Directory To Find If Directory Exists Or Not
cd ${BACKUP_DIR}
if [ $? -ne 0 ]
then
	f_write_to_log "Problem In Changing Directory To  ${BACKUP_DIR} !!! Terminating The Process !!!"
    exit 10
else
    f_write_to_log "Directory Sucessfully Changed To  ${BACKUP_DIR}."
fi

#Delete 30 Days old Logs
find "${BACKUP_DIR}" -mtime +30 -delete
if [ $? -ne 0 ]
then
    f_write_to_log "30 Days Old Backup Could Not Be Deleted !!! Terminating The Process !!!"
    exit 10
else
    f_write_to_log "30 Days Old Backup Are Deleted."
fi

#Connecting to database to delete from PRT_U_VIEW_TRANSACTION_STATUS
${SQL}<<END

	WHENEVER SQLERROR EXIT sql.sqlcode; 
	set serveroutput on;
	set pages 0;
	set head off;
	set linesize 100;
	set trimspool on;
	set feedback off; 
	set echo off;

	DELETE FROM ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS WHERE TO_DATE(SUBSTR(TRANSACTION_DATE,0,10),'YYYY-MM-DD')<SYSDATE-30;
	COMMIT;

	DELETE FROM ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS WHERE VIEW_DETAIL='Cust View';
	COMMIT;

	EXIT; 
END

if [ $? -ne 0 ]
then
    f_write_to_log "Error in SQL Query execution"
    exit 10
else
    f_write_to_log "SQL Query executed successfully"
fi

f_write_to_log "Script executed successfully"
exit 0
