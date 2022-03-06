#!/bin/ksh
{ set +x ;} 2> /dev/null

export APPLICATION_NAME="SERVICEVIEW_JSON"
export APP_BASE_DIR="/opt/ontology/scripts/serviceview_json"
export LOG_DIR="${APP_BASE_DIR}/log"
export INPUT_DIR="${APP_BASE_DIR}/input"
export OUTPUT_DIR="${APP_BASE_DIR}/output"
export SCRIPT_DIR="${APP_BASE_DIR}/script"
export CONFIG_DIR="${APP_BASE_DIR}/config"
export BACKUP_DIR="${APP_BASE_DIR}/backup"

export ORACLE_BASE="/opt/oracle"
export ORACLE_TERM="vt100"
export ORACLE_HOME="${ORACLE_BASE}/product/12.1.0.client"

export LD_LIBRARY_PATH="${LD_LIBRARY}:${ORACLE_HOME}/lib"
export PATH="${PATH}:${ORACLE_HOME}/bin"
export ORACLE_SID="KONAP1"
export TERM="vt100"
export EDITOR="/bin/vi"

export FROM_ADDR="KOSMOS Team"
export TO_ADDR="lokesh.kumar@vodafone.com;plielad.matlang@vodafone.com;amarender.gunda@vodafone.com;sathiyamoorthi.v@vodafone.com;"
export CC_ADDR="deepesh.singh1@vodafone.com;subhrajyoti.basak@vodafone.com;sagnik.sarkar@vodafone.com;"

export WIDE_TO_ADDR="deepesh.singh1@vodafone.com;subhrajyoti.basak@vodafone.com;"
export WIDE_CC_ADDR="deepesh.singh1@vodafone.com;subhrajyoti.basak@vodafone.com;"

SQL="${ORACLE_HOME}/bin/sqlplus -s ontology/ontology01@KONAP1-DB.ad.plc.cwintra.com:1521/KONAP1"
SQLLOAD="${ORACLE_HOME}/bin/sqlldr ontology/ontology01@KONAP1-DB.ad.plc.cwintra.com:1521/KONAP1"


export SERVER_1="10.196.208.157"
export SERVER_2="10.196.156.54"
export SERVER_3="10.196.216.33"
export SERVER_4="10.196.216.79"

export SERVER1_MAIN_TIME="23:00:00"
export SERVER2_MAIN_TIME="23:45:00"
export SERVER3_MAIN_TIME="23:45:00"
export SERVER4_MAIN_TIME="23:15:00"
export SERVER2_DATALOAD_TIME="11:30:00"

export URL="http://${SERVER_1}:8443/ontoscope/login"
export URL_CHECK=`python3 ${SCRIPT_DIR}/url_check.py ${URL}`

alias send_mail="python3 ${SCRIPT_DIR}/send_mail.py"

f_write_to_log()
{
   	echo [`date +"%Y-%m-%d %H:%M:%S"`] "|" ${SCRIPTNAME} "|" $*  >> ${LOG_FILE}

}
