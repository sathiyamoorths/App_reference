#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/edw_olo_data_load/scripts"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="edw_olo_dataload"
RUN_DATE=`date +%Y%m%d`
LOG_FILE=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}.log
echo "Log File Name :  ${LOG_FILE}"

f_write_to_log "starting script ${SCRIPTNAME}"

cd /opt/ontology/interface/external/FinanceHub

var=`ls -1 | grep KONA_REPORT_01 | wc -l`

if [ $var -eq 0  ] 
then 

f_write_to_log "No KONA_REPORT_01_ file exists in /opt/ontology/interface/external/FinanceHub, so quit script"
exit 10

fi

mv KONA_REPORT_01_*.zip /opt/ontology/scripts/edw_olo_data_load/input

f_write_to_log "moving to input dir : ${INPUT_DIR}"

cd ${INPUT_DIR}
if [ $? -ne 0 ] 
then
f_write_to_log "No dir exists :${INPUT_DIR}, quit script"
exit 10
fi

mkdir ${PROCESS_DIR}/tempdir

for audname in KONA_REPORT_01_*.zip
do
f_write_to_log "unzip file $audname"
unzip $audname
var=`echo $audname| cut -d'.' -f 1`
finalfname=`echo $var.dat`

file_path="${INPUT_DIR}/${finalfname}"

f_write_to_log "loding file $finalfname"

${SQLLOADPR} CONTROL=/opt/ontology/scripts/edw_olo_data_load/scripts/dataload_ctl_fh_all.ctl ,DATA=${file_path},LOG=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}_${finalfname}_ctl.log ,BAD={LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}_${finalfname}_ctl.bad ,ERRORS=0
if [ $? -ne 0 ]
then
f_write_to_log "Error generate at the time of loading file : ${file_path}"

echo "Hi," > ${CONFIG_DIR}/${SCRIPTNAME}_${RUN_DATE}_error.txt
echo "There is a error in FH script please investigate" >> ${CONFIG_DIR}/${SCRIPTNAME}_${RUN_DATE}_error.txt
echo "From," >> ${CONFIG_DIR}/${SCRIPTNAME}_${RUN_DATE}_error.txt
echo "FH_OLO data loading" >> ${CONFIG_DIR}/${SCRIPTNAME}_${RUN_DATE}_error.txt

cat ${CONFIG_DIR}/${SCRIPTNAME}_${RUN_DATE}_error.txt| mailx -s "Error in FH script" lokesh.kumar@vodafone.com TCSEIMServiceSupport@cw.com Sathiyamoorthi.V@vodafone.com
rm ${CONFIG_DIR}/${SCRIPTNAME}_${RUN_DATE}_error.txt

exit 10
fi

f_write_to_log "remove file $finalfname"

rm ${INPUT_DIR}/$finalfname

f_write_to_log " moving file : ${audname} to ${PROCESS_DIR}"

mv $audname ${PROCESS_DIR}/tempdir
	
done

f_write_to_log "zipping files and taking backup in to : ${BACKUP_DIR}"

cd ${PROCESS_DIR}/tempdir
if [ $? -eq 0 ]
then

tar cvfj KONA_REPORT_01_${RUN_DATE}.tar.bz2 ${PROCESS_DIR}/tempdir/*.zip

mv KONA_REPORT_01_${RUN_DATE}.tar.bz2 ${BACKUP_DIR}
fi
cd ${PROCESS_DIR}
if [ $? -eq 0 ]

then
echo "Process"
rm -r ${PROCESS_DIR}/tempdir
fi
f_write_to_log "calling cas_supplier_script"

sh -x /opt/ontology/scripts/edw_olo_data_load/scripts/cas_supplier_dataload.sh &

f_write_to_log "calling FINANCE_HUB_LOAD"


${SQLPR} << EOF > ${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}_sql.log

WHENEVER SQLERROR EXIT sql.sqlcode;
set pagesize 0;
SET LONG 50000;
set trimspool on;
set trimout on;
set headsep on;
set linesize 32767;
set feedback off;
set echo off;

BEGIN
FH_CKT_SUMMARY_PACKAGE.RUN_ALL();
END;

/
EOF

f_write_to_log "end script ${SCRIPTNAME}"