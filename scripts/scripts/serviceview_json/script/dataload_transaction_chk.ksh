#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/serviceview_json/script"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="dataload_transaction_chk"
RUN_DATE=`date +%Y%m%d`
LOG_FILE=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}.log

echo "Log File Name :  ${LOG_FILE}"
######################################################################################################################################################################
#
#	Script Name :- /opt/ontology/scripts/serviceview_json/script/dataload_transaction_chk.ksh
#	Author      :- TCS
#	Date        :- 15th January 2021
#	Scheduling  :- Crontab Schedule Daily at 13:00 BST
#
#
#	Description :- This Script checks dataload transaction in Server 2 is completed or not.
#
#
#
#######################################################################################################################################################################

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
		TRIM( COUNT(FLAG_VALUE) ) 
	FROM 
		ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS 
	WHERE 
		TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND
		FLAG_VALUE='COMPLETED' AND
		SERVER_NAME='S2' AND
		VIEW_DETAIL='DATALOAD_EXTRACTION';
		EXIT
END`
if [ "$FLAG_VALUE" -gt 0 ] 
then
	f_write_to_log "Dataload Transaction On Server-2 ${SERVER_2} Completed Successfully."
	${SQL}<< END
		WHENEVER SQLERROR EXIT sql.sqlcode;
		set serveroutput on;
		set pages 0;
		set head off;
		set linesize 100;
		set trimspool on;
		set feedback off;
		set echo off;
		
		UPDATE ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
		SET
			TRANSACTION_TIME=F_GET_DATE_DIFF (TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ${SERVER2_DATALOAD_TIME}','YYYY-MM-DD HH24:MI:SS' ),TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' )),
			JSON_START_DATE=TO_CHAR( TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ${SERVER2_DATALOAD_TIME}','YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS'),
			JSON_END_DATE=TO_CHAR( TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS')
		WHERE
			TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND
			FLAG_VALUE='COMPLETED' AND
			SERVER_NAME='S2' AND
			VIEW_DETAIL='DATALOAD_EXTRACTION';
		COMMIT;	
		EXIT
END
	f_write_to_log "Script Executed Successfully."
	exit 0
else
	f_write_to_log "Dataload Transaction On Server-2 ${SERVER_2} Failed Today."
	${SQL}<< END
		WHENEVER SQLERROR EXIT sql.sqlcode;
		set serveroutput on;
		set pages 0;
		set head off;
		set linesize 100;
		set trimspool on;
		set feedback off;
		set echo off;
		
		INSERT
		INTO PRT_U_VIEW_TRANSACTION_STATUS
		  (
			TRANSACTION_DATE,
			DETAIL,
			FLAG_VALUE,
			TRANSACTION_TIME,
			JSON_START_DATE,
			JSON_END_DATE,
			SERVER_NAME,
			VIEW_DETAIL
		  )
		SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD') AS TRANSACTION_DATE,
		  'Dataload Transaction'              AS DETAIL,
		  'FAILED'                            AS FLAG_VALUE,
		  F_GET_DATE_DIFF(TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD')
		  ||' ${SERVER2_DATALOAD_TIME}','YYYY-MM-DD HH24:MI:SS'),SYSDATE) AS TRANSACTION_TIME,
		  TO_CHAR(TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD')
		  ||' ${SERVER2_DATALOAD_TIME}','YYYY-MM-DD HH24:MI:SS'),'DD-MM-YYYY HH24:MI:SS') AS JSON_START_DATE,
		  TO_CHAR(SYSDATE, 'DD-MM-YYYY HH24:MI:SS')                       AS JSON_END_DATE,
		  'S2'                                                            AS SERVER_NAME,
		  'DATALOAD_EXTRACTION'                                           AS VIEW_DETAIL
		FROM DUAL;
		COMMIT;
		EXIT
END
	f_write_to_log "Sending Mail."
	sed "s/IP_ADDRESS/${SERVER_2}/g" ${CONFIG_DIR}/dataload_transaction.html > ${CONFIG_DIR}/dataload_transaction_${RUN_DATE}.html
	send_mail "Dataload Transaction Failed On ${RUN_DATE}" "${CONFIG_DIR}/dataload_transaction_${RUN_DATE}.html" "${TO_ADDR}" "${CC_ADDR}" "${FROM_ADDR}"
	rm ${CONFIG_DIR}/dataload_transaction_${RUN_DATE}.html
	f_write_to_log "Script Failed."
	exit 10
fi

