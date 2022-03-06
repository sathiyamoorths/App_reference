#!/bin/ksh
{ set +x ;} 2> /dev/null
DIRNAME="/opt/ontology/scripts/edw_olo_data_load/scripts"
. ${DIRNAME}/setenv.ksh
SCRIPTNAME="cas_supplier_dataload"
RUN_DATE=`date +%Y%m%d`
LOG_FILE=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}.log
echo "Log File Name :  ${LOG_FILE}"

f_write_to_log "starting script ${SCRIPTNAME}"

cd /opt/ontology/interface/external/FinanceHub

var=`ls -1 | grep KONA_REPORT_02 | wc -l`

if [ $var -eq 0  ] 
then 

f_write_to_log "No KONA_REPORT_02_* file exists in /opt/ontology/interface/external/FinanceHub, so quit script"
exit 10

fi

mv KONA_REPORT_02_*.zip /opt/ontology/scripts/edw_olo_data_load/input

f_write_to_log "moving to input dir : ${INPUT_DIR}"

cd ${INPUT_DIR}
if [ $? -ne 0 ] 
then
f_write_to_log "No dir exists :${INPUT_DIR}, quit script"
exit 10
fi

mkdir ${PROCESS_DIR}/tempdir1

for audname in KONA_REPORT_02_*.zip
do
	f_write_to_log "unzip file $audname"
	unzip $audname
	var=`echo $audname| cut -d'.' -f 1`
	finalfname=`echo $var.dat`
	
	file_path="${INPUT_DIR}/${finalfname}"
	
	f_write_to_log "loding file $finalfname"
	
	${SQLLOADPR} CONTROL=/opt/ontology/scripts/edw_olo_data_load/scripts/dataload_ctl_cas_supplier.ctl ,DATA=${file_path},LOG=${LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}_${finalfname}_ctl.log ,BAD={LOG_DIR}/${SCRIPTNAME}_${RUN_DATE}_${finalfname}_ctl.bad ,ERRORS=1000
	
	f_write_to_log "remove file $finalfname"
	
	rm ${INPUT_DIR}/$finalfname
	
	f_write_to_log " moving file : ${audname} to ${PROCESS_DIR}"
	
	mv $audname ${PROCESS_DIR}/tempdir1
	
done

f_write_to_log "zipping files and taking backup in to : ${BACKUP_DIR}"

cd ${PROCESS_DIR}/tempdir1
if [ $? -eq 0 ]
then

tar cvfj KONA_REPORT_02_${RUN_DATE}.tar.bz2 ${PROCESS_DIR}/tempdir/*.zip

mv KONA_REPORT_02_${RUN_DATE}.tar.bz2 ${BACKUP_DIR}

cd ${PROCESS_DIR}
if [ $? -eq 0 ]
then
rm -r ${PROCESS_DIR}/tempdir1
fi
fi
