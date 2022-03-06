#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/serviceview_json/script"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="serviceview_json_create"
RUN_DATE=`date +%Y%m%d`
start_time=`date '+%Y%m%d %H:%M:%S'`
LOG_FILE=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}.log
echo "Log File Name :  ${LOG_FILE}"

f_write_to_log "Script Execution Started"
COUNTER=0

while [ 1 ]
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
				FLAG_VALUE = 'COMPLETED' AND 
				SERVER_NAME = 'DB_SERVER' AND 
				VIEW_DETAIL = 'DAILY_TABLE_REFRESH_PKG';
        
		EXIT

END`

    if [ "$FLAG_VALUE" -gt 0 ]
    then

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

                spool ${CONFIG_DIR}/jsonNameList.txt

                    SELECT 
						TRIM(JSON_NAME) JSON_NAME
					FROM 
						ONTOLOGY.SERVICEVIEW_JSON_CONFIG 
					WHERE 
						INCLUDE_YN='Y' AND 
						SERVER_NAME='S1'
					ORDER BY 
						JSON_SIZE DESC;

                spool off
				
            EXIT
END
		if [ -f ${CONFIG_DIR}/jsonNameList.txt ]
		then
			f_write_to_log "Spool File Created Sucessfully"
		else
			f_write_to_log "Unable To Create Spool File !!! Terminating The Process !!!"
			exit 10
		fi
        
		${SQL}<<EOF

            WHENEVER SQLERROR EXIT sql.sqlcode;
            SET ECHO OFF
            SET HEADING OFF

                INSERT INTO ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
                (
                                TRANSACTION_DATE, DETAIL, FLAG_VALUE, TRANSACTION_TIME, JSON_START_DATE, JSON_END_DATE, SERVER_NAME, VIEW_DETAIL
                )
                SELECT
                    TO_CHAR(SYSDATE,'YYYY-MM-DD')  AS TRANSACTION_DATE,
                    'JSON Creation'  AS DETAIL,
                    'STARTED'  AS FLAG_VALUE,
                    NULL AS TRANSACTION_TIME,
                    TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS') AS JSON_START_DATE,
                    NULL  AS JSON_END_DATE,
                    'S1'  AS SERVER_NAME,
                    'JSON_CREATION_S1' AS VIEW_DETAIL
                FROM
                    DUAL;
                COMMIT;
EOF
		f_write_to_log "JSON Execution Log Inserted Into DB"
        while read JSON_NAME ;
        do

            FORMATED_JSON_NAME="$(echo -e "${JSON_NAME}" | tr -d '[[:space:]]' | tr -d '\015' | tr -d '\n' )"
			f_write_to_log "Starting JSON ${FORMATED_JSON_NAME}"
            ksh -x /opt/ontology/scripts/serviceview_json/script/serviceview_json_from_db.ksh ${FORMATED_JSON_NAME} &
            sleep 30

        done < ${CONFIG_DIR}/jsonNameList.txt
        wait

        f_write_to_log "All Json creation completed"

        cd ${CONFIG_DIR}
        if [ $? -eq 0 ]
        then
            rm ${CONFIG_DIR}/jsonNameList.txt
			f_write_to_log "Temporary File ${CONFIG_DIR}/jsonNameList.txt Deleted"
        fi
        
		${SQL}<<EOF

            WHENEVER SQLERROR EXIT sql.sqlcode;
            SET ECHO OFF
            SET HEADING OFF

                UPDATE ONTOLOGY.PRT_U_VIEW_TRANSACTION_STATUS
                SET
                    TRANSACTION_TIME=F_GET_DATE_DIFF(TO_DATE( JSON_START_DATE,'DD-MM-YYYY HH24:MI:SS'),TO_DATE(TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS'),'DD-MM-YYYY HH24:MI:SS')),
                    JSON_END_DATE=TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS'),
                    FLAG_VALUE='COMPLETED'
                WHERE
                    TRANSACTION_DATE= TO_CHAR(SYSDATE,'YYYY-MM-DD') AND
                    FLAG_VALUE        ='STARTED' AND
                    SERVER_NAME       = 'S1' AND
                    VIEW_DETAIL       = 'JSON_CREATION_S1';
                COMMIT;

EOF
		
		f_write_to_log "JSON Execution Log Updated In DB"
        f_write_to_log "Script Execution Completed"
        exit 0

    else

        COUNTER=`expr $COUNTER + 1`
        f_write_to_log "waiting for DAILY_TABLE_REFRESH to complete, going for sleep ${COUNTER} Times"
        sleep 5m
        if [ "$COUNTER" -eq 90 ]
        then
            f_write_to_log "DAILY_TABLE_REFRESH didn'n ran. So, quit script"
			f_write_to_log "Mail Must Have Been Triggered From DAILY_TABLE_REFRESH Execution Script. Hence Not Required Here."
            exit 10
        fi
    fi

done
