#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/serviceview_json/script"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="execute_optical_serviceview_pkg"
RUN_DATE=`date +%Y%m%d`
LOG_FILE=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}.log
echo "Log File Name :  ${LOG_FILE}"
######################################################################################################################################################################
#
#	Script Name :- /opt/ontology/scripts/serviceview_json/script/execute_optical_serviceview_pkg.ksh
#	Author      :- TCS
#	Date        :- 13th September 2021
#	Scheduling  :- Crontab Schedule Daily at 02:30 BST
#
#
#	Description :- This Script triggers Daily Table Refresh Pakg after successful transaction of Exports from all the 4 servers.
#
#
#
######################################################################################################################################################################

f_write_to_log "Starting To Execute Script $SCRIPTNAME"

#Change The Directory To Find If Directory Exists Or Not
cd ${SCRIPT_DIR}
if [ $? -ne 0 ]
then
	f_write_to_log "Problem In Changing Directory To  ${SCRIPT_DIR} !!! Terminating The Process !!!"
    exit 10
else
    f_write_to_log "Directory Sucessfully Changed To  ${SCRIPT_DIR}."
fi

COUNTER=0

while [ : ]
do

	FLAG_VALUE=`${SQL}<< END
	WHENEVER SQLERROR EXIT sql.sqlcode;
	set serveroutput on;
	set pages 0;
	set head off;
	set linesize 100;
	set trimspool on;
	set feedback off;
	set echo off;

	SELECT 
		TRIM(COUNT(FLAG_VALUE))
	FROM 
		ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
	WHERE 
		TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD')
		AND DETAIL            ='Datamart Creation'
		AND FLAG_VALUE        = 'COMPLETED' ;

	EXIT
END`

	if [ "$FLAG_VALUE" -gt 0 ]
	then
		f_write_to_log "Daily Table Refresh package Completed Sucessfully"
		f_write_to_log "Optical Serviceview package Will Be Triggered Now"
		${SQL}<<EOF 	

			T LONG 50000;
			set trimspool on;
			set trimout on;
			set headsep on;
			set linesize 32767;
			set feedback off;
			set echo off;
			
			INSERT INTO ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
				(
					TRANSACTION_DATE, DETAIL, FLAG_VALUE, TRANSACTION_TIME, JSON_START_DATE, JSON_END_DATE, SERVER_NAME, VIEW_DETAIL
				)
			SELECT 
				TO_CHAR(SYSDATE,'YYYY-MM-DD') AS TRANSACTION_DATE,
				'Optical Serviceview Creation' AS DETAIL,
				'STARTED' AS FLAG_VALUE,
				NULL AS TRANSACTION_TIME,
				TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS') AS JSON_START_DATE,
				NULL AS JSON_END_DATE,
				'DB_SERVER' AS SERVER_NAME,
				'OPTICAL_SERVICEVIEW_PKG' AS VIEW_DETAIL 
			FROM DUAL;
			COMMIT;

			BEGIN
				OPTICAL_SERVICEVIEW_PKG.RUN_ALL();
			END;
			/
EOF
		if [ $? -ne 0 ]
        then
            f_write_to_log "Error In Execution Of SQL Block. Terminating The Script"
            send_mail "SQL Block Failed On ${RUN_DATE}" "${CONFIG_DIR}/optical_serviceview_pkg_script.html" "${TO_ADDR}" "${CC_ADDR}" "${FROM_ADDR}"
			exit 10
        else
            f_write_to_log "SQL Block Execution Completed."
			FLAG_VALUE=`${SQL}<< END
                        WHENEVER SQLERROR EXIT sql.sqlcode;
                        set serveroutput on;
                        set pages 0;
                        set head off;
                        set linesize 100;
                        set trimspool on;
                        set feedback off;
                        set echo off;
                        SELECT TRIM(COUNT(FLAG_VALUE))
                        FROM
                            ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
                        WHERE
                            TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND
                            FLAG_VALUE ='COMPLETED' AND
                            SERVER_NAME ='DB_SERVER' AND
                            VIEW_DETAIL = 'OPTICAL_SERVICEVIEW_PKG' ;
                        EXIT
END`
			if [ "$FLAG_VALUE" -gt 0 ]
            then
				f_write_to_log "OPTICAL_SERVICEVIEW_PKG package Execution Completed Sucessfully."
			else
				f_write_to_log "OPTICAL_SERVICEVIEW_PKG package Execution Failed"
				send_mail "OPTICAL_SERVICEVIEW_PKG Failed On ${RUN_DATE}" "${CONFIG_DIR}/optical_serviceview_pkg_script_fail.html" "${TO_ADDR}" "${CC_ADDR}" "${FROM_ADDR}"
			fi

        fi
		exit 0
	else
		f_write_to_log "DAILY_TABLE_REFRESH_PKG package Execution Failed"
	fi
done

