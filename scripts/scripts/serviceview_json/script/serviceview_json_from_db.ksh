#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/serviceview_json/script"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="serviceview_json_from_db"
RUN_DATE=`date +%Y%m%d`
LOG_FILE=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}_${1}.log
echo "Log File Name :  ${LOG_FILE}"

f_write_to_log "Starting Execution Of The Script."
f_write_to_log "Starting Operation Of JSON = ${1}"

cd ${SCRIPT_DIR}
if [ $? -ne 0 ]
then
    f_write_to_log "Error in changing directory to ${SCRIPT_DIR}"
    exit 10
else
    f_write_to_log "Directory changed to ${SCRIPT_DIR}"
fi


${SQL}<<END 

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

	spool ${CONFIG_DIR}/${1}_sql_json.txt

		SELECT 
			TO_CLOB(SELECT_BLOCK)||' '||TO_CLOB(FROM_BLOCK)||' '||TO_CLOB(WHERE_BLOCK) 
		FROM 
			ONTOLOGY.SERVICEVIEW_JSON_CONFIG 
		WHERE 
			JSON_NAME='${1}';

	spool off
	
	EXIT
END

if [ $? -ne 0 ]
then
    f_write_to_log "Error In Execution Of SQL Block . Terminating The Process !!!"
    exit 10
fi

if [ -f ${CONFIG_DIR}/${1}_sql_json.txt ]
then
	f_write_to_log "Spool File Is There. Formatting Spool File"
	cat ${CONFIG_DIR}/${1}_sql_json.txt | sed 's/||/||\n/g'  > ${CONFIG_DIR}/${1}_sql_json_1.txt
	if [ -f ${CONFIG_DIR}/${1}_sql_json_1.txt ]
	then
		rm ${CONFIG_DIR}/${1}_sql_json.txt
		f_write_to_log "File Deleted. (${CONFIG_DIR}/${1}_sql_json.txt)"
		JSON_SQL_QUERY=`cat ${CONFIG_DIR}/${1}_sql_json_1.txt`
		if [ -z ${JSON_SQL_QUERY} ]
		then
			f_write_to_log "Variable Is Empty. !!! terminating The Process !!!"
			exit 10
		else
			rm ${CONFIG_DIR}/${1}_sql_json_1.txt
			f_write_to_log "Temporary File ${CONFIG_DIR}/${1}_sql_json_1.txt Deleted"
			f_write_to_log "JSON Query Variable Is Now Set."
		fi
	else
		f_write_to_log "Error In Formatting The File. Terminating The Process !!!"
		rm ${CONFIG_DIR}/${1}_sql_json.txt
		f_write_to_log "File Deleted. (${CONFIG_DIR}/${1}_sql_json.txt)"
		exit 10
	fi
else
	f_write_to_log "Error In Spooling File. Terminating The Process !!!"
	exit 10
fi

f_write_to_log "Fetching Data For JSON Creation"

${SQL}<<EOF

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

	spool ${CONFIG_DIR}/${1}_serviceview_data.txt

		${JSON_SQL_QUERY}
	
	spool off
	EXIT

EOF

if [ $? -ne 0 ]
then
    f_write_to_log "Error In Execution Of SQL Block . Terminating The Process !!!"
    exit 10
fi

if [ -f ${CONFIG_DIR}/${1}_serviceview_data.txt ]
then
	f_write_to_log "Spool File Completed . Post Spool Operation Starting"
	
	f_write_to_log "remove last char ','"
	sed -i '$ s/.$//' ${CONFIG_DIR}/${1}_serviceview_data.txt
	
	f_write_to_log "add '[' at start"
	sed -i '1s/^/[ /' ${CONFIG_DIR}/${1}_serviceview_data.txt
	
	f_write_to_log "add '}]' at end"
	sed -i '$ s/.$/}]/' ${CONFIG_DIR}/${1}_serviceview_data.txt

	f_write_to_log "remove '\' from file"
	sed -i 's/\\//g' ${CONFIG_DIR}/${1}_serviceview_data.txt
	
	f_write_to_log "remove tab '\t'"
	sed -i 's/\t//g' ${CONFIG_DIR}/${1}_serviceview_data.txt
	
	f_write_to_log "remove  carriage return"
	sed -i 's/\r//g' ${CONFIG_DIR}/${1}_serviceview_data.txt
	
	f_write_to_log "remove new line"
	sed -i ':a;N;$!ba;s/\n//g' ${CONFIG_DIR}/${1}_serviceview_data.txt

else
	f_write_to_log "Unable To Spool File . Terminating The Process !!!"
    exit 10
fi

if [ -f ${CONFIG_DIR}/${1}_serviceview_data.txt ]
then 
	f_write_to_log "All Opertion Completed On ${1}_serviceview_data.txt. Copying File Into .json Format"
	mv ${CONFIG_DIR}/${1}_serviceview_data.txt ${CONFIG_DIR}/${1}.json
	if [ $? -ne 0 ]
	then
		f_write_to_log "Unable To Move File Into ${CONFIG_DIR}/${1}.json. !!! Terminating The Process !!!"
		exit 10
	else
		f_write_to_log "File Move Sucessful. Json File Is Now Created."
	fi
else
	f_write_to_log "All Opertion Not Completed On ${1}_serviceview_data.txt. Terminating The Script"
	exit 10
fi

if [ -f ${CONFIG_DIR}/${1}.json ]
then
	f_write_to_log "Checking For JSON Parsing Issue. If exists"
	python -m json.tool "${CONFIG_DIR}/${1}.json" > "/opt/ontology/output/${1}.json"	
	if [ $? -eq 0 ]
	then
		if [ -f /opt/ontology/output/${1}.json ]
		then
			rm ${CONFIG_DIR}/${1}.json
			f_write_to_log "Temporary File Deleted . ${CONFIG_DIR}/${1}.json "
			cp /opt/ontology/output/${1}.json ${BACKUP_DIR}/${1}_${RUN_DATE}.json
			f_write_to_log "Backup File Created."
			JSON_SIZE=`du /opt/ontology/output/${1}.json|grep -o -E '[0-9]+'|head -1`
			if [ -z ${JSON_SIZE} ]
			then
				f_write_to_log "Variable JSON_SIZE Is Empty"
				f_write_to_log "Script Failed"
				exit 10
			else
				${SQL}<<END

                			WHENEVER SQLERROR EXIT sql.sqlcode;
                			SET serveroutput ON;
                			SET pages 0;
                			SET head OFF;
                			SET linesize 100;
                			SET trimspool ON;
                			SET feedback OFF;
               				 SET echo OFF;

					
					UPDATE ONTOLOGY.SERVICEVIEW_JSON_CONFIG 
						SET JSON_SIZE=TO_NUMBER('${JSON_SIZE}')
					WHERE 
						JSON_NAME='${1}';
					COMMIT;

                			EXIT
END
				f_write_to_log "Json Size Update For ${1}.json In Table ONTOLOGY.SERVICEVIEW_JSON_CONFIG"
			fi
			f_write_to_log "Script Execution Sucessfully Completed"
			exit 0
		else
			f_write_to_log "/opt/ontology/output/${1}.json Does Not Exists.!! Terminating The Process !!!"
			exit 10
		fi
	else
		f_write_to_log "There Is JSON Parsing Issue. Terminating The Process"
		
		${SQL}<<END

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

			INSERT INTO ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
			(
				TRANSACTION_DATE, DETAIL, FLAG_VALUE, TRANSACTION_TIME, 
				JSON_START_DATE, JSON_END_DATE, SERVER_NAME, VIEW_DETAIL
			)
			SELECT
				TO_CHAR( SYSDATE ,'YYYY-MM-DD') TRANSACTION_DATE,
				ONTOLOGY_VIEW_NAME AS DETAIL,
				'FAILED' AS FLAG_VALUE,
				F_GET_DATE_DIFF(SYSDATE,SYSDATE) AS TRANSACTION_TIME,
				TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS') AS JSON_START_DATE,
				TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS') AS JSON_END_DATE,
				'S1' AS SERVER_NAME,
				'JSON_CREATION_S1' AS VIEW_DETAIL
			FROM
				ONTOLOGY.SERVICEVIEW_JSON_CONFIG
			WHERE
				JSON_NAME='${1}';
			COMMIT;

			EXIT
END
		f_write_to_log "Failed Entry Inserted Into Transaction Table."
		f_write_to_log "Sending Mail"
		VIEW_NAME=`${SQL}<<END

        	WHENEVER SQLERROR EXIT sql.sqlcode;
                SET serveroutput ON;
                SET pages 0;
                SET head OFF;
                SET linesize 100;
                SET trimspool ON;
                SET feedback OFF;
                SET echo OFF;

                SELECT 
			TRIM ( ONTOLOGY_VIEW_NAME ) AS  ONTOLOGY_VIEW_NAME 
		FROM 
			ONTOLOGY.SERVICEVIEW_JSON_CONFIG WHERE JSON_NAME='${1}';

                EXIT
END`
		cat ${CONFIG_DIR}/serviceview_json_error.html|sed "s/V_JSON_NAME/${1}/g"|sed "s/V_SERVER_1/${SERVER_1}/g"|sed "s/V_SERVER_2/${SERVER_2}/g"|sed "s/V_SERVER_3/${SERVER_3}/g"|sed "s/V_SERVER_4/${SERVER_4}/g"|sed "s/V_VIEW_NAME/${VIEW_NAME}/g" > ${CONFIG_DIR}/serviceview_json_error_${1}_${RUN_DATE}.html
        	send_mail "JSON Parsing Error On ${RUN_DATE} For ${VIEW_NAME}" "${CONFIG_DIR}/serviceview_json_error_${1}_${RUN_DATE}.html" "${TO_ADDR}" "${CC_ADDR}" "${FROM_ADDR}"
        	rm ${CONFIG_DIR}/serviceview_json_error_${1}_${RUN_DATE}.html
		f_write_to_log "Temporary File ${CONFIG_DIR}/serviceview_json_error_${1}_${RUN_DATE}.html Deleted !!!"
		f_write_to_log "Script Failed"
		exit 10
	fi
else
	f_write_to_log "Unable To Move File Into ${CONFIG_DIR}/${1}.json. !!! Terminating The Process !!!"
	exit 10
fi
