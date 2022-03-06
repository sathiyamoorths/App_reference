#!/bin/sh
. /opt/ontology/scripts/Filter_view_dataload/ontyd2.env

DATETIME=`date '+%Y%m%d'`

dos2unix /opt/ontology/input/Filter-View-Upload/upload/*.csv
DESTINATION='/opt/ontology/input/Filter-View-Upload/upload'
cd $DESTINATION
for audname in *.csv
do

echo $audname

PAT_FIL="$DESTINATION/$audname"	
  sed 's|CGFILENAME|'$PAT_FIL'|g' /opt/ontology/scripts/Filter_view_dataload/dataload.ctl > /opt/ontology/scripts/Filter_view_dataload/dataload_temp.ctl

${SQLLOAD1} control=/opt/ontology/scripts/Filter_view_dataload/dataload_temp.ctl,LOG=/opt/ontology/scripts/Filter_view_dataload/filter_view_load.log,ERRORS=100

done



     gzip -c /opt/ontology/input/Filter-View-Upload/upload/*.csv > /opt/ontology/input/Filter-View-Upload/uplod_zipfiles/upload$DATETIME.gz
     rm /opt/ontology/input/Filter-View-Upload/upload/*.csv

   
 ${SQL1} << EOF 
       
        WHENEVER SQLERROR EXIT sql.sqlcode;

        SET ECHO OFF 

        SET HEADING OFF

insert  into  service_view_filter_archieve(serviceid,filter,USERS, INSERTION_DATE) (select serviceid,filter, USERS ,INSERTION_DATE from service_view_filter where INSERTION_DATE <= sysdate -4);
 
 delete from service_view_filter where INSERTION_DATE <= sysdate -4;
commit;


EOF