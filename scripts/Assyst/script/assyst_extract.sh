

BASE_PATH=/opt/ontology/scripts/Assyst
SCRIPT_PATH=$BASE_PATH/script
INPUT_PATH=$BASE_PATH/input
LOG_PATH=$BASE_PATH/log
TEMP_FILE=$INPUT_PATH/Assyst_extract_final.csv
DATETIME=`echo $(date '+%b_%Y')`

. $SCRIPT_PATH/python_db_config.env

rm $INPUT_PATH/*.csv

lftp sftp://sftpuser1:Q8j%26Ii%5EX8L@UKSDM1VW << EOF >$LOG_PATH/Assyst_load.log
cd "Assyst_Extract"
lcd "/opt/ontology/scripts/Assyst/input"
mget Assyst_${DATETIME}.csv

bye
EOF

dos2unix $INPUT_PATH/*

chmod -R 777 $INPUT_PATH

sed -r 's/([^,"]*|"[^"]*")/"\1"/g' $INPUT_PATH/Assyst_${DATETIME}.csv | sed 's/","/"|"/g' | sed 's/"//g' > $TEMP_FILE

chmod 775 $TEMP_FILE

cd $INPUT_PATH
file_count=($( ls * | wc -l ))
if [ $file_count -eq 0 ]
then
        exit
else

#scp $TEMP_FILE ontology@${SERVER_1}:/opt/ontology/scripts/Assyst/input/Assyst_extract_final.csv
echo 'Comented'
fi

python3 $SCRIPT_PATH/assyst_extract_load.py
