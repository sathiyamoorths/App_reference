#!/bin/ksh

export APP_BASE_DIR="/opt/ontology/scripts/maguire_manual_service_upload"
export SCRIPT_DIR="${APP_BASE_DIR}/script"
export SOURCE_DIR="${APP_BASE_DIR}/upload"
export PROCESS_DIR="${APP_BASE_DIR}/process"
export BACKUP_DIR="${APP_BASE_DIR}/backup"
export LOG_DIR="${APP_BASE_DIR}/log"
export HEADER="${APP_BASE_DIR}/header"


export ORACLE_BASE="/opt/oracle"
export ORACLE_TERM="vt100"
export ORACLE_HOME="${ORACLE_BASE}/product/12.1.0.client"

export LD_LIBRARY_PATH="${LD_LIBRARY}:${ORACLE_HOME}/lib"
export PATH="${PATH}:${ORACLE_HOME}/bin"
export ORACLE_SID="ONTYD2"
export TERM="vt100"
export EDITOR="/bin/vi"


SQL="${ORACLE_HOME}/bin/sqlplus -s ontology/onty7651@ONTYT1-DB.hosts.plc.cwintra.com:1521/ONTYT1"
SQL1="${ORACLE_HOME}/bin/sqlplus -s ontology/onty7651@ONTYT1-DB.hosts.plc.cwintra.com:1521/ONTYT1"
SQLLOAD1="${ORACLE_HOME}/bin/sqlldr ontology/onty7651@ONTYT1-DB.hosts.plc.cwintra.com:1521/ONTYT1"
SQLLOAD="${ORACLE_HOME}/bin/sqlldr ontology/onty7651@ONTYT1-DB.hosts.plc.cwintra.com:1521/ONTYT1"
SQLLOADPR="${ORACLE_HOME}/bin/sqlldr pr_user/moon55@ONTYT1-DB.hosts.plc.cwintra.com:1521/ONTYT1"
MODULE="OSN2"

export SQL SQL_LOAD EXCEL_DIR MODULE OSN2_HOME OSN2_KSH OSN2_LOG OSN2_IMPORT
