#!/bin/ksh
{ set +x ;} 2> /dev/null
export APPLICATION_NAME=MAGUIRE
export APP_BASE_DIR="/opt/ontology/scripts/maguire"
export LOG_DIR="${APP_BASE_DIR}/log"
export INPUT_DIR="${APP_BASE_DIR}/input"
export OUTPUT_DIR="${APP_BASE_DIR}/output"
export SCRIPT_DIR="${APP_BASE_DIR}/script"
export CONFIG_DIR="${APP_BASE_DIR}/config"

export ORACLE_BASE="/opt/oracle"
export ORACLE_TERM="vt100"
export ORACLE_HOME="${ORACLE_BASE}/product/12.1.0.client"
export LD_LIBRARY_PATH="${LD_LIBRARY}:${ORACLE_HOME}/lib"
export PATH="$PATH:${ORACLE_HOME}/bin"
export ORACLE_SID="KONAP1"

export ORAHOST="KONAP1-DB.ad.plc.cwintra.com"
export ORAPORT="1521"
export ORASERVICE="KONAP1"
export ORAUSERPR="pr_user"
export ORAUSERON="ontology"
export ORAUSERDATA="dataanalyst"

ORAPASSPR=`${APP_BASE_DIR}/.store/orapasspr.ksh`
ORAPASSON=`${APP_BASE_DIR}/.store/orapasson.ksh`
ORAPASSDATA=`${APP_BASE_DIR}/.store/orapassdata.ksh`

export SQLONTO="$ORACLE_HOME/bin/sqlplus -s ${ORAUSERON}/${ORAPASSON}@${ORAHOST}:${ORAPORT}/${ORASERVICE}"
export SQLLOADONTO="$ORACLE_HOME/bin/sqlldr ${ORAUSERON}/${ORAPASSON}@${ORAHOST}:${ORAPORT}/${ORASERVICE}"

export SQLDA="$ORACLE_HOME/bin/sqlplus -s ${ORAUSERDATA}/${ORAPASSDATA}@${ORAHOST}:${ORAPORT}/${ORASERVICE}"
export SQLLOADDA="$ORACLE_HOME/bin/sqlldr ${ORAUSERDATA}/${ORAPASSDATA}@${ORAHOST}:${ORAPORT}/${ORASERVICE}"

export SQLPR="$ORACLE_HOME/bin/sqlplus -s ${ORAUSERPR}/${ORAPASSPR}@${ORAHOST}:${ORAPORT}/${ORASERVICE}"
export SQLLOADPR="$ORACLE_HOME/bin/sqlldr ${ORAUSERPR}/${ORAPASSPR}@${ORAHOST}:${ORAPORT}/${ORASERVICE}"


export SERVER_1="10.196.220.77"
export SERVER_2="10.196.156.53"
export SERVER_3="10.196.220.19"

f_write_to_log()
{
   	echo [`date +"%Y-%m-%d %H:%M:%S"`] "|" ${SCRIPTNAME} "|" $*  >> ${LOG_FILE}

}
