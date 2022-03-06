#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/serviceview_json/script"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="execute_populate_annotation_pkg"
RUN_DATE=`date +%Y%m%d`
LOG_FILE=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}.log
echo "Log File Name :  ${LOG_FILE}"
COUNTER=0
f_write_to_log "Starting To Execute Script $SCRIPTNAME"

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
		SELECT TRIM(COUNT(FLAG_VALUE))
		FROM 
			ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
		WHERE 
			TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND 
			FLAG_VALUE ='PENDING' AND 
			SERVER_NAME ='MAIN1' AND 
			VIEW_DETAIL = 'POPULATE ANNOTATION' ;
		EXIT
END`
	if [ "$FLAG_VALUE" -gt 0 ] 
	then
		f_write_to_log "Export Annotation Completed."
		${SQL}<< END
			WHENEVER SQLERROR EXIT sql.sqlcode;
			set serveroutput on;
			set pages 0;
			set head off;
			set linesize 100;
			set trimspool on;
			set feedback off;
			set echo off;
			
			INSERT INTO ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
			(
				TRANSACTION_DATE, DETAIL, FLAG_VALUE, TRANSACTION_TIME, JSON_START_DATE, JSON_END_DATE, SERVER_NAME, VIEW_DETAIL
			)
			SELECT 
				TO_CHAR(SYSDATE,'YYYY-MM-DD') AS TRANSACTION_DATE,
				'Export Annotation' AS DETAIL,
				'COMPLETED' AS FLAG_VALUE,
				F_GET_DATE_DIFF(TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' 19:30:00','YYYY-MM-DD HH24:MI:SS' ),TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' )) AS TRANSACTION_TIME,
				TO_CHAR(TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' 19:30:00','YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS') AS JSON_START_DATE,
				TO_CHAR(TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD') ||' ' ||SUBSTR(TRANSACTION_TIME,0,8),'YYYY-MM-DD HH24:MI:SS' ),'DD-MM-YYYY HH24:MI:SS') AS JSON_END_DATE,
				'S1' AS SERVER_NAME,
				'ANNOTATION_EXPORT' AS VIEW_DETAIL
			FROM 
				ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
			WHERE 
				TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND 
				FLAG_VALUE='PENDING' AND 
				SERVER_NAME='MAIN1' AND 
				VIEW_DETAIL='POPULATE ANNOTATION';
			COMMIT;
			
			UPDATE ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS SET FLAG_VALUE='IN PROGRESS' WHERE 
				VIEW_DETAIL='POPULATE ANNOTATION' AND 
				TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND 
				FLAG_VALUE='PENDING' ;
			COMMIT;

			BEGIN
				POPULATE_ANNOTATION.START_POPULATE_ANNOTATION();
			END;
			/
			
			EXIT
END
		if [ $? -ne 0 ]
		then
			f_write_to_log "Error In Execution Of SQL Block. Terminating The Script"
			sed "s/IP_ADDRESS/${SERVER_1}/g" ${CONFIG_DIR}/populate_annotation_script_sql.html > ${CONFIG_DIR}/populate_annotation_script_sql_${RUN_DATE}.html
			send_mail "SQL Block Failed On ${RUN_DATE}" "${CONFIG_DIR}/populate_annotation_script_sql_${RUN_DATE}.html" "${TO_ADDR}" "${CC_ADDR}" "${FROM_ADDR}"
			rm ${CONFIG_DIR}/populate_annotation_script_sql_${RUN_DATE}.html
			exit 10
		else
			f_write_to_log "SQL Block Execution Completed."
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
			SELECT TRIM(COUNT(FLAG_VALUE))
			FROM 
				ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
			WHERE 
				TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND 
				FLAG_VALUE ='COMPLETED' AND 
				SERVER_NAME ='MAIN1' AND 
				VIEW_DETAIL = 'POPULATE ANNOTATION' ;
			EXIT
END`
		if [ "$FLAG_VALUE" -gt 0 ]
		then
			${SQL}<< END
			WHENEVER SQLERROR EXIT sql.sqlcode;
			set serveroutput on;
			set pages 0;
			set head off;
			set linesize 100;
			set trimspool on;
			set feedback off;
			set echo off;
			
			INSERT INTO ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
			(
				TRANSACTION_DATE, DETAIL, FLAG_VALUE, TRANSACTION_TIME, JSON_START_DATE, JSON_END_DATE, SERVER_NAME, VIEW_DETAIL
			)
			SELECT 
				TO_CHAR(SYSDATE,'YYYY-MM-DD') AS TRANSACTION_DATE,
				'Populate Annotation DB Package' AS DETAIL,
				STATUS AS FLAG_VALUE,
				F_GET_DATE_DIFF (STARTTIME,ENDTIME) AS TRANSACTION_TIME,
				TO_CHAR(STARTTIME,'DD-MM-YYYY HH24:MI:SS') AS JSON_START_DATE, 
				TO_CHAR(ENDTIME,'DD-MM-YYYY HH24:MI:SS') AS JSON_END_DATE,
				'DB_SERVER' AS SERVER_NAME,
				'POPULATE_ANNOTATION_PKG' AS VIEW_DETAIL
			FROM 
				ONTOLOGY.PRT_DATALOAD_STATUS 
			WHERE 
				PACKAGE_NAME='POPULATE_ANNOTATION';
			COMMIT;	
			EXIT
END
			f_write_to_log "Populate Annotation Package Completed Sucessfully"
		else
			${SQL}<< END
                        WHENEVER SQLERROR EXIT sql.sqlcode;
                        set serveroutput on;
                        set pages 0;
                        set head off;
                        set linesize 100;
                        set trimspool on;
                        set feedback off;
                        set echo off;

                        INSERT INTO ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
                        (
                                TRANSACTION_DATE, DETAIL, FLAG_VALUE, TRANSACTION_TIME, JSON_START_DATE, JSON_END_DATE, SERVER_NAME, VIEW_DETAIL
                        )
                        SELECT
                                TO_CHAR(SYSDATE,'YYYY-MM-DD') AS TRANSACTION_DATE,
                                'Populate Annotation DB Package' AS DETAIL,
                                'FAILED' AS FLAG_VALUE,
                                F_GET_DATE_DIFF (STARTTIME,ENDTIME) AS TRANSACTION_TIME,
                                TO_CHAR(STARTTIME,'DD-MM-YYYY HH24:MI:SS') AS JSON_START_DATE,
                                TO_CHAR(ENDTIME,'DD-MM-YYYY HH24:MI:SS') AS JSON_END_DATE,
                                'DB_SERVER' AS SERVER_NAME,
                                'POPULATE_ANNOTATION_PKG' AS VIEW_DETAIL
                        FROM
                                ONTOLOGY.PRT_DATALOAD_STATUS
                        WHERE
                                PACKAGE_NAME='POPULATE_ANNOTATION';
                        COMMIT;
                        EXIT
END
			f_write_to_log "Export Annotation Ontology Transaction Failed Today. Hence Package Run Is Not Completed"
			sed "s/IP_ADDRESS/${SERVER_1}/g" ${CONFIG_DIR}/export_annotation.html > ${CONFIG_DIR}/export_annotation_${RUN_DATE}.html
			send_mail "Export Annotation Transaction Failed On ${RUN_DATE}" "${CONFIG_DIR}/export_annotation_${RUN_DATE}.html" "${TO_ADDR}" "${CC_ADDR}" "${FROM_ADDR}"
			rm ${CONFIG_DIR}/export_annotation_${RUN_DATE}.html
			exit 10
		fi
		f_write_to_log "Script Execution Sucessfully Completed"
		exit 0
	fi
	COUNTER=`expr ${COUNTER} + 1`
	sleep 5m
	if [ "${COUNTER}" -eq 36 ]
	then
		f_write_to_log "Export Annotation Ontology Transaction Failed Today. Hence Package Run Is Not Completed"
		sed "s/IP_ADDRESS/${SERVER_1}/g" ${CONFIG_DIR}/export_annotation.html > ${CONFIG_DIR}/export_annotation_${RUN_DATE}.html
		send_mail "Export Annotation Transaction Failed On ${RUN_DATE}" "${CONFIG_DIR}/export_annotation_${RUN_DATE}.html" "${TO_ADDR}" "${CC_ADDR}" "${FROM_ADDR}"
		rm ${CONFIG_DIR}/export_annotation_${RUN_DATE}.html
		exit 10
	fi
done
