#!/bin/sh

. /opt/ontology/scripts/Annotations-dataload/ontydp.env

target=/opt/ontology/input/Annoations-File-Upload/upload/
output="/opt/ontology/input/Annoations-File-Upload/upload/output.csv"
output1="/opt/ontology/input/Annoations-File-Upload/upload/output1.csv"

DATETIME=`date '+%Y%m%d'`


if test "$(ls -A "$target")"; then 
    echo not empty,starting script >> /opt/ontology/scripts/Annotations-dataload/Annotations-load.txt
 dos2unix /opt/ontology/input/Annoations-File-Upload/upload/*.csv 


cd $target

for audname in *.csv
do


		ls -l "$audname" > $output
		echo $output
		time=($(awk  '{print $6"/"$7"/"$8}' $output ))	 	
		echo $time 
		sed "s|$|,${time}|" "$audname" | sed "s|$|,${audname}|" >> $output1
		${SQLLOAD1} control=/opt/ontology/scripts/Annotations-dataload/dataload.ctl,LOG=/opt/ontology/scripts/Annotations-dataload/Annotations-load.log,ERRORS=100
		
		#zip "${audname}_${DATETIME}.zip" "$audname" output1.csv
		#mv "${audname}_${DATETIME}.zip" /opt/ontology/input/Annotations-dataload/upload_zipfiles/
		#mv "${audname}_${DATETIME}.zip" /opt/ontology/input/Annotations-dataload/upload_zipfiles/
		gzip -c  /opt/ontology/input/Annoations-File-Upload/upload/"$audname" >  /opt/ontology/input/Annoations-File-Upload/upload_zipfiles/$audname"_"$DATETIME.gz
		rm "${audname}"
		rm output.csv
		rm $output1
		rm "${audname}_${DATETIME}.zip"
		rm "*.csv_${DATETIME}.zip"



 ${SQL1} << EOF  > /opt/ontology/scripts/Annotations-dataload/sql_output.log 
       
        WHENEVER SQLERROR EXIT sql.sqlcode;

        SET ECHO OFF 

        SET HEADING OFF
        SET HEADING OFF
 --INSERT INTO PRT_U_ANNOTATION_TRACKING ( FILENAME,USERNAME, MODIFIED_TIME , VALIDATION )
--values ( '$audname' , '${time}' , SYSDATE , 'PENDING' ,  '0' , '0' , '0' , '0' , '0' ) ; 
 
--INSERT INTO PRT_U_ANNOTATION_TRACKING ( FILENAME,USERNAME, MODIFIED_TIME , VALIDATION )
  --SELECT distinct '$audname' ,USER_NAME,'${time}' , 'PENDING' from ANNOTATION_VALIDATION_TEMP WHERE USER_NAME IS NOT NULL and FILENAME = '$audname'  ;

  --UPDATE PRT_U_ANNOTATION_TRACKING t SET VALIDATION = 'PENDING' where t.FILENAME = ( select distinct (a.FILENAME ) FROM ANNOTATION_VALIDATION_TEMP a  ) ;
								

INSERT INTO PRT_U_ANNOTATION_TRACKING ( FILENAME,USERNAME, MODIFIED_TIME , VALIDATION
,SEQUENCE_NO )
SELECT File_name ,USER_NAME, time_stamp , status, Annotation_sequence.nextval from (
  SELECT distinct '$audname' File_name ,USER_NAME,'${time}' time_stamp , 'PENDING' status from ANNOTATION_VALIDATION_TEMP WHERE USER_NAME IS NOT NULL and FILENAME = '$audname' ) ;

COMMIT;


update ANNOTATION_VALIDATION_TEMP temp set SEQUENCE_NO =(select distinct trac1.SEQUENCE_NO from PRT_U_ANNOTATION_TRACKING trac1,ANNOTATION_VALIDATION_TEMP t1 where trac1.FILENAME = t1.Filename  and trac1.MODIFIED_TIME = t1.MODIFIED_TIME and trac1.FILENAME = temp.Filename  and trac1.MODIFIED_TIME = temp.MODIFIED_TIME)where exists (select 'x' from PRT_U_ANNOTATION_TRACKING trac1,ANNOTATION_VALIDATION_TEMP t1 where trac1.FILENAME = t1.Filename and trac1.MODIFIED_TIME = t1.MODIFIED_TIME and trac1.FILENAME = temp.Filename and trac1.MODIFIED_TIME = temp.MODIFIED_TIME);		
COMMIT;

EOF
 
${SQL1} << EOF >  /opt/ontology/scripts/Annotations-dataload/proc.log

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
MANUAL_ANNOTATION_VALIDATION.ANNOTATION_VALIDATION;
END; 
/
EOF
done


else
    echo The directory $target is empty '(or non-existent)' >> /opt/ontology/scripts/Annotations-dataload/Annotations-load.txt
fi 


find /opt/ontology/input/Annoations-File-Upload/upload_zipfiles/*.gz -mtime +180 -delete






