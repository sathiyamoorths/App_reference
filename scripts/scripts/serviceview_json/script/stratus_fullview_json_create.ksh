#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/serviceview_json/script"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="stratus_fullview_json_create"
RUN_DATE=`date +%Y%m%d`
LOG_FILE=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}.log
echo "Log File Name :  ${LOG_FILE}"

cd ${SCRIPT_DIR}
if [ $? -ne 0 ]
then
	f_write_to_log "Error in changing directory to ${SCRIPT_DIR}"
	exit 10
else
	f_write_to_log "Directory changed to ${SCRIPT_DIR}"
fi

COUNTER=0
f_write_to_log "Counter initialised to 0"

while [ : ]
do
    FLAG_VALUE=`${SQL}<< END

		WHENEVER SQLERROR EXIT sql.sqlcode;
		SET serveroutput ON;
		SET pages 0;
		SET head OFF;
		SET linesize 100;
		SET trimspool ON;
		SET feedback OFF;
		SET echo OFF;
		SELECT TRIM(COUNT(FLAG_VALUE))
		FROM ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
		WHERE TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD')
		AND FLAG_VALUE        ='PENDING'
		AND SERVER_NAME       ='MAIN1'
		AND VIEW_DETAIL       ='Stratus View';
		EXIT;        
END`

    if [ "$FLAG_VALUE" -gt 0 ]
    then
		f_write_to_log "Stratus Data Refresh package completed successfully"
		${SQL}<<END
		WHENEVER SQLERROR EXIT sql.sqlcode;
		SET serveroutput ON;
		SET pages 0;
		SET head OFF;
		SET linesize 100;
		SET trimspool ON;
		SET feedback OFF;
		SET echo OFF;
		
		UPDATE ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS SET
		SERVER_NAME ='S1',
		FLAG_VALUE = 'COMPLETED';
		WHERE
		TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND
		VIEW_DETAIL       = 'Stratus View' AND
		SERVER_NAME    = 'MAIN1' AND
		FLAG_VALUE        = 'PENDING';
		
		COMMIT;

		INSERT INTO ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
		(
		TRANSACTION_DATE, DETAIL, FLAG_VALUE, TRANSACTION_TIME, JSON_START_DATE, JSON_END_DATE, SERVER_NAME, VIEW_DETAIL
		)
		SELECT
		TO_CHAR(SYSDATE,'YYYY-MM-DD') AS TRANSACTION_DATE,
		'Stratus View JSON Creation' AS DETAIL,
		'STARTED' AS FLAG_VALUE,
		NULL AS TRANSACTION_TIME,
		TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS') AS JSON_START_DATE,
		NULL AS JSON_END_DATE,
		'S1' AS SERVER_NAME,
		'STRATUS_JSON_CREATION_S1' AS VIEW_DETAIL
		FROM DUAL;
		
		COMMIT;

END
		f_write_to_log "Spooling JSON Query from DB"
        ${SQL}<<END
		SET NEWP 0 SPACE 0 PAGES 0 FEED OFF HEAD OFF TRIMS OFF TRIM OFF TAB OFF;
		SET colsep '@#@';
		SET pagesize 0;
		SET LONG 50000;
		SET trimspool ON;
		SET trimout ON;
		SET headsep ON;
		SET linesize 32767;
		SET feedback OFF;
		SET echo OFF;
		SET TAB OFF;
		SET WRAP ON;
		SET longchunksize 32767;
		
		spool ${CONFIG_DIR}/stratus_query.txt
		SELECT TO_CLOB(SELECT_BLOCK)
		 ||' '
		 ||TO_CLOB(FROM_BLOCK)
		 ||' '
		 ||TO_CLOB(WHERE_BLOCK)
		FROM OTHER_JSON_CONFIG
		WHERE JSON_NAME='Stratus-Full-View-Json';
		spool OFF
		EXIT        
END
   
		if [ -f ${CONFIG_DIR}/stratus_query.txt ]
		then
			f_write_to_log "Spool file stratus_query created"
		cat ${CONFIG_DIR}/stratus_query.txt | sed 's/||/||\n/g'  > ${CONFIG_DIR}/stratus_query_temp.txt
		rm ${CONFIG_DIR}/stratus_query.txt
			f_write_to_log "File stratus_query deleted"
		else
			f_write_to_log "Spool file stratus_query error while creating"
			exit 10
		fi
		if [ -f ${CONFIG_DIR}/stratus_query_temp.txt ]
		then
			f_write_to_log "Formated spooled file exists"
			JSON_SQL_QUERY=`cat ${CONFIG_DIR}/stratus_query_temp.txt`
			rm ${CONFIG_DIR}/stratus_query_temp.txt
			f_write_to_log "Formated spooled file deleted"
			f_write_to_log "Fetching Stratus-Full-View-Json.JSON data from config table"
			
			${SQL}<<EOF
			SET NEWP 0 SPACE 0 PAGES 0 FEED OFF HEAD OFF TRIMS OFF TRIM OFF TAB OFF;
			SET pagesize 0;
			SET LONG 50000;
			SET trimspool ON;
			SET trimout ON;
			SET headsep ON;
			SET linesize 32767;
			SET feedback OFF;
			SET echo OFF;
			SET TAB OFF;
			SET WRAP ON;
			SET longchunksize 32767;
			
			spool ${CONFIG_DIR}/stratus_full_view_data.txt
			$JSON_SQL_QUERY
			spool OFF
			EXIT
EOF
			if [ -f ${CONFIG_DIR}/stratus_full_view_data.txt ]
			then
				f_write_to_log "Data spool from DB successful"
				
				f_write_to_log "remove last char ','"
				sed -i '$ s/.$//' ${CONFIG_DIR}/stratus_full_view_data.txt
				f_write_to_log "add '[' at start"
				sed -i '1s/^/[ /' ${CONFIG_DIR}/stratus_full_view_data.txt
				f_write_to_log "add '}]' at end"
				sed -i '$ s/.$/} ]/' ${CONFIG_DIR}/stratus_full_view_data.txt
				f_write_to_log "remove '\' from file"
				sed -i 's/\\//g' ${CONFIG_DIR}/stratus_full_view_data.txt

				mv ${CONFIG_DIR}/stratus_full_view_data.txt ${CONFIG_DIR}/Stratus-Full-View-Json.json
			else
				f_write_to_log "Error while spooling file from DB"
				exit 10
			fi
		else
			f_write_to_log "Error while formating spool file"
		exit 10
		fi
		
		if [ -f ${CONFIG_DIR}/Stratus-Full-View-Json.json ]                  
		then
			f_write_to_log "Stratus View JSON file exists. Checking JSON format"
			python -m json.tool ${CONFIG_DIR}/Stratus-Full-View-Json.json > /opt/ontology/output/Stratus-Full-View-Json.json
			if [ $? -ne 0 ]
			then
				${SQL}<<EOF
				SET NEWP 0 SPACE 0 PAGES 0 FEED OFF HEAD OFF TRIMS OFF TRIM OFF TAB OFF;
				SET pagesize 0;
				SET LONG 50000;
				SET trimspool ON;
				SET trimout ON;
				SET headsep ON;
				SET linesize 32767;
				SET feedback OFF;
				SET echo OFF;
				SET TAB OFF;
				SET WRAP ON;
				SET longchunksize 32767;
				
				UPDATE ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS SET
				FLAG_VALUE          ='FAILED'
				WHERE TRANSACTION_DATE= TO_CHAR(SYSDATE,'YYYY-MM-DD')
				AND FLAG_VALUE        ='STARTED'
				AND SERVER_NAME       ='S1'
				AND VIEW_DETAIL       ='STRATUS_JSON_CREATION_S1';
				COMMIT;
				EXIT
EOF
				rm ${CONFIG_DIR}/Stratus-Full-View-Json.json
				exit 10
			else
			
				${SQL}<<EOF
				SET NEWP 0 SPACE 0 PAGES 0 FEED OFF HEAD OFF TRIMS OFF TRIM OFF TAB OFF;
				SET pagesize 0;
				SET LONG 50000;
				SET trimspool ON;
				SET trimout ON;
				SET headsep ON;
				SET linesize 32767;
				SET feedback OFF;
				SET echo OFF;
				SET TAB OFF;
				SET WRAP ON;
				SET longchunksize 32767;
				UPDATE ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
				SET FLAG_VALUE          ='COMPLETED',
				JSON_END_DATE           =TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS')
				WHERE TRANSACTION_DATE= TO_CHAR(SYSDATE,'YYYY-MM-DD')
				AND FLAG_VALUE        ='STARTED'
				AND SERVER_NAME       ='S1'
				AND VIEW_DETAIL       ='STRATUS_JSON_CREATION_S1';
				COMMIT;
				EXIT
EOF
				f_write_to_log "Deleting temporary JSON File"
				rm ${CONFIG_DIR}/Stratus-Full-View-Json.json
				f_write_to_log "Taking Backup of Stratusview JSON"
				cp /opt/ontology/output/Stratus-Full-View-Json.json ${BACKUP_DIR}/Stratus-Full-View-Json_${RUN_DATE}.json
				f_write_to_log "Script executed successfully"
				exit 0
			fi
		else
			f_write_to_log "Stratus View JSON file doesnot exist. Terminating process."
			exit 10
		fi
                       
    else

        COUNTER=`expr $COUNTER + 1`
        f_write_to_log "waiting for Stratus View  to complete, going for sleep"
        sleep 5m
        if [ "$COUNTER" -eq 60 ]
        then
            f_write_to_log "STRATUS_DATA_REFRESH package didnot run successfully. So, quit script"
            exit 10
        fi
    fi
done

