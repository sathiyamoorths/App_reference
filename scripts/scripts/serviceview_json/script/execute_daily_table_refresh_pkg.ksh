#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/serviceview_json/script"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="execute_daily_table_refresh_pkg"
RUN_DATE=`date +%Y%m%d`
LOG_FILE=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}.log
echo "Log File Name :  ${LOG_FILE}"
######################################################################################################################################################################
#
#	Script Name :- /opt/ontology/scripts/serviceview_json/script/execute_daily_table_refresh_pkg.ksh
#	Author      :- TCS
#	Date        :- 15th January 2021
#	Scheduling  :- Crontab Schedule Daily at 00:30 BST
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
		TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND 
		FLAG_VALUE = 'PENDING' AND 
		SERVER_NAME IN ('MAIN1','MAIN2','MAIN3','MAIN4') AND 
		VIEW_DETAIL = 'Service View' ;

	EXIT
END`

	if [ "$FLAG_VALUE" -gt 3 ]
	then
		sleep 10m
                f_write_to_log "All Service View Export Completed Sucessfully"
		f_write_to_log "Daily Table Refresh package Will Be Triggered Now"
		${SQL}<<EOF 	

			T LONG 50000;
			set trimspool on;
			set trimout on;
			set headsep on;
			set linesize 32767;
			set feedback off;
			set echo off;
			
			DELETE FROM ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS 
			WHERE 
				VIEW_DETAIL='POPULATE ANNOTATION' AND 
				FLAG_VALUE='COMPLETED' AND 
				TRANSACTION_DATE=TO_CHAR(SYSDATE-1,'YYYY-MM-DD');
			COMMIT;

			UPDATE ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS SET 
				DETAIL = 'Service View Export' ,
				FLAG_VALUE = 'COMPLETED' ,
				VIEW_DETAIL = 'ONTOLOGY_SERVICEVIEW_EXPORT'
			WHERE 
				TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND 
				VIEW_DETAIL       ='Service View' AND 
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
				VIEW_DETAIL = 'ONTOLOGY_SERVICEVIEW_EXPORT' AND 
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
				VIEW_DETAIL = 'ONTOLOGY_SERVICEVIEW_EXPORT' AND 
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
				VIEW_DETAIL = 'ONTOLOGY_SERVICEVIEW_EXPORT' AND 
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
				VIEW_DETAIL = 'ONTOLOGY_SERVICEVIEW_EXPORT' AND 
				SERVER_NAME = 'MAIN4' AND 
				FLAG_VALUE = 'COMPLETED';
			COMMIT;
			
			INSERT INTO ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
				(
					TRANSACTION_DATE, DETAIL, FLAG_VALUE, TRANSACTION_TIME, JSON_START_DATE, JSON_END_DATE, SERVER_NAME, VIEW_DETAIL
				)
			SELECT 
				TO_CHAR(SYSDATE,'YYYY-MM-DD') AS TRANSACTION_DATE,
				'Datamart Creation' AS DETAIL,
				'STARTED' AS FLAG_VALUE,
				NULL AS TRANSACTION_TIME,
				TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS') AS JSON_START_DATE,
				NULL AS JSON_END_DATE,
				'DB_SERVER' AS SERVER_NAME,
				'DAILY_TABLE_REFRESH_PKG' AS VIEW_DETAIL 
			FROM DUAL;
			COMMIT;

			BEGIN
				DAILY_TABLE_REFRESH.RUN_ALL();
			END;
			/
EOF
		if [ $? -ne 0 ]
        then
            f_write_to_log "Error In Execution Of SQL Block. Terminating The Script"
            send_mail "SQL Block Failed On ${RUN_DATE}" "${CONFIG_DIR}/daily_table_refresh_pkg_script.html" "${TO_ADDR}" "${CC_ADDR}" "${FROM_ADDR}"
			sh -x /opt/ontology/scripts/gate22-csv-export/GenerateCSVFroGate22Services.sh &
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
                            VIEW_DETAIL = 'DAILY_TABLE_REFRESH_PKG' ;
                        EXIT
END`
			if [ "$FLAG_VALUE" -gt 0 ]
            then
				f_write_to_log "DAILY_TABLE_REFRESH package Execution Completed Sucessfully."
			else
				f_write_to_log "DAILY_TABLE_REFRESH package Execution Failed"
				send_mail "DAILY_TABLE_REFRESH Failed On ${RUN_DATE}" "${CONFIG_DIR}/daily_table_refresh_pkg_script_fail.html" "${TO_ADDR}" "${CC_ADDR}" "${FROM_ADDR}"
			fi

        fi
		f_write_to_log "calling script GenerateCSVFroGate22Services.sh"
		sh -x /opt/ontology/scripts/gate22-csv-export/GenerateCSVFroGate22Services.sh &
		exit 0

	else		
		COUNTER=`expr $COUNTER + 1`
		sleep 5m
		if [ "$COUNTER" -eq 120 ]
		then
			f_write_to_log "Ontology Transaction Is Not Completed In All Servers. Please Investigate"
			${SQL}<< EOF 	

			SET LONG 50000;
			set trimspool on;
			set trimout on;
			set headsep on;
			set linesize 32767;
			set feedback off;
			set echo off;

			UPDATE ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS SET 
				DETAIL = 'Service View Export' ,
				FLAG_VALUE = 'COMPLETED' ,
				VIEW_DETAIL = 'ONTOLOGY_SERVICEVIEW_EXPORT'
			WHERE 
				TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND 
				VIEW_DETAIL       ='Service View' AND 
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
				VIEW_DETAIL = 'ONTOLOGY_SERVICEVIEW_EXPORT' AND 
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
				VIEW_DETAIL = 'ONTOLOGY_SERVICEVIEW_EXPORT' AND 
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
				VIEW_DETAIL = 'ONTOLOGY_SERVICEVIEW_EXPORT' AND 
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
				VIEW_DETAIL = 'ONTOLOGY_SERVICEVIEW_EXPORT' AND 
				SERVER_NAME = 'MAIN4' AND 
				FLAG_VALUE = 'COMPLETED';
			COMMIT;
			EXIT
			
EOF
			FAILED_SERVER=`${SQL}<< END

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
                                        WHERE VIEW_DETAIL   ='ONTOLOGY_SERVICEVIEW_EXPORT'
                                        AND SERVER_NAME    IN ('S1','S2','S3','S4')
                                        AND FLAG_VALUE      ='COMPLETED'
                                        AND TRANSACTION_DATE=TO_CHAR(SYSDATE,'YYYY-MM-DD')
                                        )
                                ) ;
                                COMMIT;

                                EXIT;
END`	
			cat "${CONFIG_DIR}/serviceview_export_fail.html"|sed "s/V_SERVER_NAME/${FAILED_SERVER}/g"|sed "s/V_SERVER_1/${SERVER_1}/g"|sed "s/V_SERVER_2/${SERVER_2}/g"|sed "s/V_SERVER_3/${SERVER_3}/g"|sed "s/V_SERVER_4/${SERVER_4}/g" > "${CONFIG_DIR}/serviceview_export_fail_${RUN_DATE}.html"
			send_mail "Serviceview Export Transaction Failed On ${RUN_DATE}" "${CONFIG_DIR}/serviceview_export_fail_${RUN_DATE}.html" "${TO_ADDR}" "${CC_ADDR}" "${FROM_ADDR}"
			rm "${CONFIG_DIR}/serviceview_export_fail_${RUN_DATE}.html"
			exit 10
		fi
	fi
done
