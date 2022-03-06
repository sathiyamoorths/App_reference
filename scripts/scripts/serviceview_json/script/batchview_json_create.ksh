#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/serviceview_json/script"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="batchview_json_create"
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
		AND SERVER_NAME       IN ('MAIN1','MAIN2','MAIN3','MAIN4')
		AND VIEW_DETAIL       ='Batch View';
		
		EXIT;        
END`

    if [ "$FLAG_VALUE" -gt 3 ]
    then
		f_write_to_log "Batch View Export completed in all servers"
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
				DETAIL = 'Batch View Export' ,
				FLAG_VALUE = 'COMPLETED' ,
				VIEW_DETAIL = 'ONTOLOGY_BATCHVIEW_EXPORT'
			WHERE 
				TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND 
				VIEW_DETAIL       ='Batch View' AND 
				SERVER_NAME      IN ('MAIN1','MAIN2','MAIN3','MAIN4') AND 
				FLAG_VALUE='PENDING';
			COMMIT;

			UPDATE ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS SET 
				SERVER_NAME ='S1',
				JSON_START_DATE = TO_CHAR(TO_DATE(TO_CHAR(SYSDATE-1,'YYYY-MM-DD') ||' ${SERVER1_MAIN_TIME}','YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS'),
				JSON_END_DATE = TO_CHAR(TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS'),
				TRANSACTION_TIME=F_GET_DATE_DIFF (TO_DATE(TO_CHAR(SYSDATE-1,'YYYY-MM-DD') ||' ${SERVER1_MAIN_TIME}','YYYY-MM-DD HH24:MI:SS' ),TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' )) 
			WHERE 
				TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND 
				VIEW_DETAIL = 'ONTOLOGY_BATCHVIEW_EXPORT' AND 
				SERVER_NAME  = 'MAIN1' AND 
				FLAG_VALUE = 'COMPLETED';
			COMMIT;

			UPDATE ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS SET 
				SERVER_NAME ='S2',
				JSON_START_DATE = TO_CHAR(TO_DATE(TO_CHAR(SYSDATE-1,'YYYY-MM-DD') ||' ${SERVER2_MAIN_TIME}','YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS'),
				JSON_END_DATE = TO_CHAR(TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS'),
				TRANSACTION_TIME=F_GET_DATE_DIFF (TO_DATE(TO_CHAR(SYSDATE-1,'YYYY-MM-DD') ||' ${SERVER2_MAIN_TIME}','YYYY-MM-DD HH24:MI:SS' ),TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' )) 
			WHERE 
				TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND 
				VIEW_DETAIL = 'ONTOLOGY_BATCHVIEW_EXPORT' AND 
				SERVER_NAME = 'MAIN2' AND 
				FLAG_VALUE = 'COMPLETED';
			COMMIT;
			
			UPDATE ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS SET 
				SERVER_NAME ='S3',
				JSON_START_DATE = TO_CHAR(TO_DATE(TO_CHAR(SYSDATE-1,'YYYY-MM-DD') ||' ${SERVER3_MAIN_TIME}','YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS'),
				JSON_END_DATE = TO_CHAR(TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS'),
				TRANSACTION_TIME=F_GET_DATE_DIFF (TO_DATE(TO_CHAR(SYSDATE-1,'YYYY-MM-DD') ||' ${SERVER3_MAIN_TIME}','YYYY-MM-DD HH24:MI:SS' ),TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' )) 
			WHERE 
				TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND 
				VIEW_DETAIL = 'ONTOLOGY_BATCHVIEW_EXPORT' AND 
				SERVER_NAME = 'MAIN3' AND 
				FLAG_VALUE = 'COMPLETED';
			COMMIT;
			
			UPDATE ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS SET 
				SERVER_NAME ='S4',
				JSON_START_DATE = TO_CHAR(TO_DATE(TO_CHAR(SYSDATE-1,'YYYY-MM-DD') ||' ${SERVER4_MAIN_TIME}','YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS'),
				JSON_END_DATE = TO_CHAR(TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS'),
				TRANSACTION_TIME=F_GET_DATE_DIFF (TO_DATE(TO_CHAR(SYSDATE-1,'YYYY-MM-DD') ||' ${SERVER4_MAIN_TIME}','YYYY-MM-DD HH24:MI:SS' ),TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' )) 
			WHERE 
				TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND 
				VIEW_DETAIL = 'ONTOLOGY_BATCHVIEW_EXPORT' AND 
				SERVER_NAME = 'MAIN4' AND 
				FLAG_VALUE = 'COMPLETED';
			COMMIT;
			
			INSERT INTO ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
				(
					TRANSACTION_DATE, DETAIL, FLAG_VALUE, TRANSACTION_TIME, JSON_START_DATE, JSON_END_DATE, SERVER_NAME, VIEW_DETAIL
				)
			SELECT 
				TO_CHAR(SYSDATE,'YYYY-MM-DD') AS TRANSACTION_DATE,
				'Batch View JSON Creation' AS DETAIL,
				'STARTED' AS FLAG_VALUE,
				NULL AS TRANSACTION_TIME,
				TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS') AS JSON_START_DATE,
				NULL AS JSON_END_DATE,
				'S1' AS SERVER_NAME,
				'BATCH_JSON_CREATION_S1' AS VIEW_DETAIL 
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
			
			spool ${CONFIG_DIR}/batch_cust_query.txt
			SELECT TO_CLOB(SELECT_BLOCK)
			  ||' '
			  ||TO_CLOB(FROM_BLOCK)
			  ||' '
			  ||TO_CLOB(WHERE_BLOCK)
			FROM OTHER_JSON_CONFIG
			WHERE JSON_NAME='Full-Batch-CustomerView-Json';
			
			spool OFF
			EXIT        
END
    
		if [ -f ${CONFIG_DIR}/batch_cust_query.txt ]
		then
			f_write_to_log "Spool file batch_cust_query created"
			cat ${CONFIG_DIR}/batch_cust_query.txt | sed 's/||/||\n/g'  > ${CONFIG_DIR}/batch_cust_query_temp.txt
			rm ${CONFIG_DIR}/batch_cust_query.txt
			f_write_to_log "File batch_cust_query deleted"
		else
			f_write_to_log "Spool file batch_cust_query error while creating"
			exit 10
		fi
	
		if [ -f ${CONFIG_DIR}/batch_cust_query_temp.txt ]
		then
			f_write_to_log "Formated spooled file exists"
			JSON_SQL_QUERY=`cat ${CONFIG_DIR}/batch_cust_query_temp.txt`
			rm ${CONFIG_DIR}/batch_cust_query_temp.txt
			f_write_to_log "Formated spooled file deleted"
			f_write_to_log "Fetching Full-Batch-CustomerView-Json.JSON data from config table"
			
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
				
				spool ${CONFIG_DIR}/full_batch_cust_data.txt 
				$JSON_SQL_QUERY
				spool OFF
				EXIT 
EOF
		
			if [ -f ${CONFIG_DIR}/full_batch_cust_data.txt ]
			then
				f_write_to_log "Data spool from DB successful"
				
				f_write_to_log "remove last char ','"
				sed -i '$ s/.$//' ${CONFIG_DIR}/full_batch_cust_data.txt

				f_write_to_log "add '[' at start"
				sed -i '1s/^/[ /' ${CONFIG_DIR}/full_batch_cust_data.txt

				f_write_to_log "add '}]' at end"
				sed -i '$ s/.$/} ]/' ${CONFIG_DIR}/full_batch_cust_data.txt

				f_write_to_log "remove '\' from file"
				sed -i 's/\\//g' ${CONFIG_DIR}/full_batch_cust_data.txt

				f_write_to_log "rename json from Full-Batch-CustomerView-Json_serviceview_data.txt to Full-Batch-CustomerView-Json.JSON"

				mv ${CONFIG_DIR}/full_batch_cust_data.txt ${CONFIG_DIR}/Full-Batch-CustomerView-Json.json
			else
				f_write_to_log "Error while spooling file from DB"
				exit 10
			fi
		else
			f_write_to_log "Error while formating spool file"
			exit 10
		fi
		
		if [ -f ${CONFIG_DIR}/Full-Batch-CustomerView-Json.json ]                   
		then
			f_write_to_log "Batchview JSON file exists. Checking JSON format"
			python -m json.tool ${CONFIG_DIR}/Full-Batch-CustomerView-Json.json > /opt/ontology/output/Full-Batch-CustomerView-Json.json
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
					
					UPDATE ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
						SET TRANSACTION_TIME  =F_GET_DATE_DIFF(TO_DATE(JSON_START_DATE,'DD-MM-YYYY HH24:MI:SS'),TO_DATE(TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS'),'DD-MM-YYYY HH24:MI:SS')),
						JSON_END_DATE       =TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS'),
						FLAG_VALUE          ='FAILED'
					WHERE TRANSACTION_DATE= TO_CHAR(SYSDATE,'YYYY-MM-DD')
						AND FLAG_VALUE        ='STARTED'
						AND SERVER_NAME       = 'S1'
						AND VIEW_DETAIL       = 'BATCH_JSON_CREATION_S1';
					COMMIT;
					EXIT
EOF
				send_mail "Batchview JSON Parsing Error On ${RUN_DATE}" "${CONFIG_DIR}/batchview_json_parsing_error.html" "${TO_ADDR}" "${CC_ADDR}" "${FROM_ADDR}"
				rm ${CONFIG_DIR}/Full-Batch-CustomerView-Json.json
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
						SET TRANSACTION_TIME  =F_GET_DATE_DIFF(TO_DATE(JSON_START_DATE,'DD-MM-YYYY HH24:MI:SS'),TO_DATE(TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS'),'DD-MM-YYYY HH24:MI:SS')),
						JSON_END_DATE       =TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS'),
						FLAG_VALUE          ='COMPLETED'
					WHERE TRANSACTION_DATE= TO_CHAR(SYSDATE,'YYYY-MM-DD')
						AND FLAG_VALUE        ='STARTED'
						AND SERVER_NAME       = 'S1'
						AND VIEW_DETAIL       = 'BATCH_JSON_CREATION_S1';
					COMMIT;
					EXIT
EOF
				f_write_to_log "Deleting temporary JSON File"
				rm ${CONFIG_DIR}/Full-Batch-CustomerView-Json.json
				f_write_to_log "Taking Backup of Batchview JSON"
				cp /opt/ontology/output/Full-Batch-CustomerView-Json.json ${BACKUP_DIR}/Full-Batch-CustomerView-Json_${RUN_DATE}.json
				f_write_to_log "Script executed successfully"
				exit 0
			fi
		else
			f_write_to_log "Batchview JSON file doesnot exist. Terminating process."
			exit 10
		fi
                       
    else

        COUNTER=`expr $COUNTER + 1`
        f_write_to_log "waiting for Batch View Export to complete, going for sleep"
        sleep 5m
        if [ "$COUNTER" -eq 60 ]
        then
            f_write_to_log "Batch View Export didn't ran. So, quit script"
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
					DETAIL = 'Batch View Export' ,
					FLAG_VALUE = 'COMPLETED' ,
					VIEW_DETAIL = 'ONTOLOGY_BATCHVIEW_EXPORT'
				WHERE 
					TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND 
					VIEW_DETAIL       ='Batch View' AND 
					SERVER_NAME      IN ('MAIN1','MAIN2','MAIN3','MAIN4') AND 
					FLAG_VALUE='PENDING';
				COMMIT;

				UPDATE ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS SET 
					SERVER_NAME ='S1',
					JSON_START_DATE = TO_CHAR(TO_DATE(TO_CHAR(SYSDATE-1,'YYYY-MM-DD') ||' ${SERVER1_MAIN_TIME}','YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS'),
					JSON_END_DATE = TO_CHAR(TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS'),
					TRANSACTION_TIME=F_GET_DATE_DIFF (TO_DATE(TO_CHAR(SYSDATE-1,'YYYY-MM-DD') ||' ${SERVER1_MAIN_TIME}','YYYY-MM-DD HH24:MI:SS' ),TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' )) 
				WHERE 
					TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND 
					VIEW_DETAIL = 'ONTOLOGY_BATCHVIEW_EXPORT' AND 
					SERVER_NAME  = 'MAIN1' AND 
					FLAG_VALUE = 'COMPLETED';
				COMMIT;

				UPDATE ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS SET 
					SERVER_NAME ='S2',
					JSON_START_DATE = TO_CHAR(TO_DATE(TO_CHAR(SYSDATE-1,'YYYY-MM-DD') ||' ${SERVER2_MAIN_TIME}','YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS'),
					JSON_END_DATE = TO_CHAR(TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS'),
					TRANSACTION_TIME=F_GET_DATE_DIFF (TO_DATE(TO_CHAR(SYSDATE-1,'YYYY-MM-DD') ||' ${SERVER2_MAIN_TIME}','YYYY-MM-DD HH24:MI:SS' ),TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' )) 
				WHERE 
					TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND 
					VIEW_DETAIL = 'ONTOLOGY_BATCHVIEW_EXPORT' AND 
					SERVER_NAME = 'MAIN2' AND 
					FLAG_VALUE = 'COMPLETED';
				COMMIT;
				
				UPDATE ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS SET 
					SERVER_NAME ='S3',
					JSON_START_DATE = TO_CHAR(TO_DATE(TO_CHAR(SYSDATE-1,'YYYY-MM-DD') ||' ${SERVER3_MAIN_TIME}','YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS'),
					JSON_END_DATE = TO_CHAR(TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS'),
					TRANSACTION_TIME=F_GET_DATE_DIFF (TO_DATE(TO_CHAR(SYSDATE-1,'YYYY-MM-DD') ||' ${SERVER3_MAIN_TIME}','YYYY-MM-DD HH24:MI:SS' ),TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' )) 
				WHERE 
					TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND 
					VIEW_DETAIL = 'ONTOLOGY_BATCHVIEW_EXPORT' AND 
					SERVER_NAME = 'MAIN3' AND 
					FLAG_VALUE = 'COMPLETED';
				COMMIT;
				
				UPDATE ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS SET 
					SERVER_NAME ='S4',
					JSON_START_DATE = TO_CHAR(TO_DATE(TO_CHAR(SYSDATE-1,'YYYY-MM-DD') ||' ${SERVER4_MAIN_TIME}','YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS'),
					JSON_END_DATE = TO_CHAR(TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS'),
					TRANSACTION_TIME=F_GET_DATE_DIFF (TO_DATE(TO_CHAR(SYSDATE-1,'YYYY-MM-DD') ||' ${SERVER4_MAIN_TIME}','YYYY-MM-DD HH24:MI:SS' ),TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' )) 
				WHERE 
					TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND 
					VIEW_DETAIL = 'ONTOLOGY_BATCHVIEW_EXPORT' AND 
					SERVER_NAME = 'MAIN4' AND 
					FLAG_VALUE = 'COMPLETED';
				COMMIT;
END
            FLAG_FAILED=`${SQL}<< END

				WHENEVER SQLERROR EXIT sql.sqlcode;
				SET serveroutput ON;
				SET pages 0;
				SET head OFF;
				SET linesize 100;
				SET trimspool ON;
				SET feedback OFF;
				SET echo OFF;
				
				SELECT LISTAGG(SERVER_NAME, ', ') WITHIN GROUP (
				ORDER BY SERVER_NAME) AS SERVER_NAME
				FROM
				  (SELECT SERVER_NAME
				  FROM
					( SELECT 'V_SERVER_1' SERVER_NAME FROM DUAL
					UNION
					SELECT 'V_SERVER_2' SERVER_NAME FROM DUAL
					UNION
					SELECT 'V_SERVER_3' SERVER_NAME FROM DUAL
					UNION
					SELECT 'V_SERVER_4' SERVER_NAME FROM DUAL
					)
				MINUS
					(SELECT DECODE(SERVER_NAME,'S1','V_SERVER_1','S2','V_SERVER_2','S3','V_SERVER_3','S4','V_SERVER_4',SERVER_NAME ) AS SERVER_NAME
					FROM ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
					WHERE VIEW_DETAIL   ='ONTOLOGY_BATCHVIEW_EXPORT'
					AND SERVER_NAME    IN ('S1','S2','S3','S4')
					AND FLAG_VALUE      ='COMPLETED'
					AND TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD')
					)
				) ;
				COMMIT;
				
				EXIT;        
END`
			cat ${CONFIG_DIR}/batchview_export_fail.html|sed "s/V_SERVER_NAME/${FLAG_FAILED}/g"|sed "s/V_SERVER_1/${SERVER_1}/g"|sed "s/V_SERVER_2/${SERVER_2}/g"|sed "s/V_SERVER_3/${SERVER_3}/g"|sed "s/V_SERVER_4/${SERVER_4}/g" > ${CONFIG_DIR}/batchview_export_fail_${RUN_DATE}.html
			send_mail "Batchview Export Transaction Failed On ${RUN_DATE}" "${CONFIG_DIR}/batchview_export_fail_${RUN_DATE}.html" "${TO_ADDR}" "${CC_ADDR}" "${FROM_ADDR}"
			rm ${CONFIG_DIR}/batchview_export_fail_${RUN_DATE}.html

            exit 10
        fi
    fi
done

