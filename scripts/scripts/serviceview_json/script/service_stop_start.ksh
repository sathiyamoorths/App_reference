#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/serviceview_json/script"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="service_stop_start"
RUN_DATE=`date +%Y%m%d`
LOG_FILE=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}.log
MAIL="-r TCSEIMServiceSupport@cw.com lokesh.kumar@vodafone.com sathiyamoorthi.v@vodafone.com plielad.matlang@vodafone.com"
echo "Log File Name :  ${LOG_FILE}"
#PASS='Lodo/2021'
STATUS=''
STATUS_ONTO=''
STATUS_ZING=''
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
			FLAG_VALUE ='IN PROGRESS' AND 
			SERVER_NAME ='MAIN1' AND 
			VIEW_DETAIL = 'POPULATE ANNOTATION' ;
		EXIT
END`
#####################################################################################----if block
	if [ "$FLAG_VALUE" -eq 1 ] 
	then
		f_write_to_log "Export Annotation Completed. Service restart started"
                
                systemctl stop zingmem
                if [ "$?" -eq 0 ]
	        then
                f_write_to_log "Zingmem is stopped."
                else
                f_write_to_log "Not able to stop the Zingmem service"
                exit 10
                fi
                sleep 20

                STATUS=`systemctl status ontology|awk 'NR==3 {print $2}'`
                if [ "$STATUS" -eq 'failed' ]
                then
                f_write_to_log "Ontology is stopped."
                else
                f_write_to_log "Not able to stop the Ontology service"
                exit 10
                fi
                sleep 20

                systemctl start zingmem
                if [ "$?" -eq 0 ]
                then
                f_write_to_log "Zingmem is started."
                else
                f_write_to_log "Not able to start the Zingmem service"
                exit 10
                fi
                sleep 20

                systemctl start ontology
                if [ "$?" -eq 0 ]
                then
                f_write_to_log "Ontology is started."
                else
                f_write_to_log "Not able to start the Ontology service"
                exit 10
                fi
                
                f_write_to_log "Service restart completed"
                
                STATUS_ONTO=`systemctl status ontology|awk 'NR==3 {print $2}'`
                
                STATUS_ZING=`systemctl status zingmem|awk 'NR==3 {print $2}'`

                if [ "$STATUS_ONTO" -eq 'active' -a "$STATUS_ZING" -eq 'active' ]
                then
                echo -e "Hi Team, \n\n  Service restart completed,both services are active.\n\n Thanks\n EIM Team "| mailx -s "Kosmos Service restart" $MAIL
                else
                echo -e "Hi Team, \n\n  Service restart completed,both services are not active.\n\n\  Ontology - $STATUS_ONTO\n\n  Zingmem - $STATUS_ZING\n\n Thanks\n EIM Team "| mailx -s "Kosmos Service restart INCOMPLETE" $MAIL
                fi

     exit 0

#####################################################################################----else block
	else
        COUNTER=`expr ${COUNTER} + 1`
        f_write_to_log "waiting for export annotation transaction to complete, going for sleep ${COUNTER} Times"
	sleep 2m
	if [ "${COUNTER}" -eq 70 ]
	then
		f_write_to_log "Export Annotation did not complete Today. Hence service restart Is Not Completed"
		echo -e "Hi Team, \n\n  Export Annotation did not complete today,please investigate.\n\n Thanks\n EIM Team "| mailx -s "Service restart not started" $MAIL
                exit 10
	fi

     
#####################################################################################----else block
     fi

#####################################################################################----if block

done
