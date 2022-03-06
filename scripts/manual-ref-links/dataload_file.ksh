#!/bin/sh
. /opt/ontology/scripts/manual-ref-links/ontyd2.env

DATETIME=`date '+%Y%m%d'`

dos2unix /opt/ontology/input/Manual-Ref-Links-Upload/upload/*.csv


for audname in *.csv
do

echo $audname


DESTINATION='/opt/ontology/input/Manual-Ref-Links-Upload/upload/'
PAT_FIL="$DESTINATION/$audname"	
  sed 's|CGFILENAME|'$PAT_FIL'|g' /opt/ontology/scripts/manual-ref-links/dataload.ctl > /opt/ontology/scripts/manual-ref-links/dataload_temp.ctl

${SQLLOAD1} control=/opt/ontology/scripts/manual-ref-links/dataload_temp.ctl,LOG=/opt/ontology/scripts/manual-ref-links/filter_view_load.log,ERRORS=100

done
gzip -c /opt/ontology/input/Manual-Ref-Links-Upload/upload/*.csv > /opt/ontology/input/Manual-Ref-Links-Upload/upload_zip/upload$DATETIME.gz
     rm /opt/ontology/input/Manual-Ref-Links-Upload/upload/*.csv


if [ $? -eq 0 ] 
    then
        echo "Successfully run ctl file"

    else
    
 echo "Failed to run ctl file"


   fi




 ${SQL1} << EOF 
       
        WHENEVER SQLERROR EXIT sql.sqlcode;

        SET ECHO OFF 

        SET HEADING OFF

EOF