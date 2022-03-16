BASE_PATH=/opt/ontology/scripts/G9
SCRIPT_PATH=$BASE_PATH/script
INPUT_PATH_PORTS=$BASE_PATH/input/DMS_Ports
INPUT_PATH_DATA=$BASE_PATH/input/DMS_Data
LOG_PATH=$BASE_PATH/log

. $SCRIPT_PATH/python_db_config.env

rm $INPUT_PATH_PORTS/*.csv
rm $INPUT_PATH_DATA/*.cap

lftp sftp://sftpuser1:Q8j%26Ii%5EX8L@GBVWS-AS009 << EOF >$LOG_PATH/G9_load.log
cd "DMS Downloads"
cd "Ports"
lcd "/opt/ontology/scripts/G9/input/DMS_Ports"
mget  ZY1_port2.csv
mget ZY2_port2.csv
mget ZZ5_port2.csv
mget ZZ6_port2.csv
mget ZZ7_port2.csv
mget ZZ8_port2.csv
mget ZZ9_port2.csv

cd ..
cd "Data"
lcd "/opt/ontology/scripts/G9/input/DMS_Data"
mget Y1_clli.cap
mget Y2_clli.cap
mget Z5_clli.cap
mget Z6_clli.cap
mget Z7_clli.cap
mget Z8_clli.cap
mget Z9_clli.cap

bye
EOF

dos2unix $INPUT_PATH_PORTS/*
dos2unix $INPUT_PATH_DATA/*

chmod -R 777 $INPUT_PATH_PORTS
chmod -R 777 $INPUT_PATH_DATA

file_count=($( ls * | wc -l ))
if [ $file_count -eq 0 ]
then
        exit
else

scp $INPUT_PATH_PORTS/* ontology@${SERVER_1}:/opt/ontology/scripts/G9/input/DMS_Ports/
scp $INPUT_PATH_DATA/* ontology@${SERVER_1}:/opt/ontology/scripts/G9/input/DMS_Data/
fi


#python3 $SCRIPT_PATH/G9_load.py

ssh ontology@10.196.208.157 sh /opt/ontology/scripts/G9/script/G9_load.sh

