#!/usr/bin/ksh

####################### start of the script #######################
DATETIME=`date '+%Y%m%d_%H%M%S'`
echo "Starting the script `date '+%Y%m%d_%H%M%S'`"

## BASE_PATH should have 3 folder i.e. ksh, data, processed.
## data folder should have raw data of Green DMS

BASE_PATH=/opt/ontology/scripts/G9
SWITCH_LIST=$BASE_PATH/script/switch_list.txt
DATA_PATH=$BASE_PATH/input/DMS_Data
PROCESSED_PATH=$BASE_PATH/processed
SCRIPT_PATH=$BASE_PATH/script

####################### loading ENV file #######################
. $SCRIPT_PATH/python_db_config.env

####################### extracting from CLLI files #######################
while read line  || [ -n "$line" ];
do
        echo "CLLI files: $line"
        CLLI_FILE=$DATA_PATH/$line"_clli.cap"
        CLLI_FILE_PROCESSED=$PROCESSED_PATH/$line"_CLLI_PROCESSED"

        awk -F' ' '{ if (length($1)==12) print $1"|"$4}' $CLLI_FILE > $CLLI_FILE_PROCESSED

done < $SWITCH_LIST

####################### extracting from TRKGRP files #######################
while read line  || [ -n "$line" ];
do
        echo "TRKGRP files : $line"
        switch=`echo $line`

        TRKGRP_FILE=$DATA_PATH/$line"_trkgr.cap"
        TRKGRP_FILE_PROCESSED=$PROCESSED_PATH/$line"_TRKGRP_PROCESSED"
        CLLI_FILE_PROCESSED=$PROCESSED_PATH/$line"_CLLI_PROCESSED"
        TRKSGRP_FILE=$DATA_PATH/$line"_trksg.cap"

        rm $TRKGRP_FILE_PROCESSED
        for CLLI_LINE in `cat $CLLI_FILE_PROCESSED`
        do
                clli_ref=($(echo $CLLI_LINE|cut -d '|' -f 1))
                billing_number=`grep -w $clli_ref $TRKGRP_FILE| cut -d' ' -f 7 | head -1`
                signalling=`grep -w $clli_ref $TRKSGRP_FILE| cut -d' ' -f 4 | head -1`

                echo $switch"|"$CLLI_LINE"|"$billing_number"|"$signalling >> $TRKGRP_FILE_PROCESSED
        done

done < $SWITCH_LIST

####################### merging ALL SUPERTKG files #######################
ALL_SUPERTKG_MERGED=$PROCESSED_PATH/ALL_SWITCH_SUPERTKG_MERGED

rm $ALL_SUPERTKG_MERGED
cd $DATA_PATH
for supertkg_file in `ls -1 *_super.cap`
do
        sed '/\$/a \$\@' $supertkg_file | sed '/\-\-/,$!d' |sed 's/-//g' | awk '/\$\@/ {if (NR!=1)print "";next}{printf "%s ",$0}END{print "";}' |sed 's/^ *//' >> $ALL_SUPERTKG_MERGED
done

####################### merging ALL OFCRTE and OFCCODE files #######################
ALL_OFCRTE_MERGED=$PROCESSED_PATH/ALL_SWITCH_OFCRTE_MERGED

rm $ALL_OFCRTE_MERGED
cd $DATA_PATH

for ofcrte_file in `ls -1 *_ofrte.cap`
do
        sed '/\$/a \$\@' $ofcrte_file | sed '/\-\-/,$!d' |sed 's/-//g' | awk '/\$\@/ {if (NR!=1)print "";next}{printf "%s ",$0}END{print "";}' |sed 's/^ *//' > $PROCESSED_PATH/$ofcrte_file"_TEMP"
done

for ftrte_file in `ls -1 *_ftrte.cap`
do
        sed '/\$/a \$\@' $ftrte_file | sed '/\-\-/,$!d' |sed 's/-//g' | awk '/\$\@/ {if (NR!=1)print "";next}{printf "%s ",$0}END{print "";}' |sed 's/^ *//' > $PROCESSED_PATH/$ftrte_file"_TEMP"
done


cd $PROCESSED_PATH
awk '{print substr(FILENAME,1, 2) " " $LINE}' *_ofrte.cap_TEMP >> $ALL_OFCRTE_MERGED
rm *_ofrte.cap_TEMP

cd $PROCESSED_PATH
awk '{print substr(FILENAME,1, 2) " " $LINE}' *_ftrte.cap_TEMP >> $ALL_OFCRTE_MERGED
rm *_ftrte.cap_TEMP

ALL_OFCCODE_MERGED=$PROCESSED_PATH/ALL_SWITCH_RTE_OFCCODE_MERGED

rm $ALL_OFCCODE_MERGED

cd $DATA_PATH

awk '{print substr(FILENAME,1, 2) " " $LINE}' *_ofcde.cap >> $ALL_OFCCODE_MERGED

cd $DATA_PATH

awk '/OFCXLA/{print substr(FILENAME,1, 2) " " $LINE}' *_o2cde.cap >> $ALL_OFCCODE_MERGED

cd $DATA_PATH

awk '/DTSADXLA/{print substr(FILENAME,1, 2) " " $LINE}' *_ftcde.cap >> $ALL_OFCCODE_MERGED

cd $DATA_PATH

awk '{print substr(FILENAME,1, 2) " " $LINE}' *_c2cde.cap >> $ALL_OFCCODE_MERGED

cd $DATA_PATH

awk '{print substr(FILENAME,1, 2) " " $LINE}' *_p2cde.cap >> $ALL_OFCCODE_MERGED


####################### extracting from SUPERTKG files #######################
cd $PROCESSED_PATH

ALL_SUPERTKG_PROCESSED=$PROCESSED_PATH/ALL_SUPERTKG_PROCESSED
rm $ALL_SUPERTKG_PROCESSED

while read line  || [ -n "$line" ];
do
        echo "SUPERTKG files : $line"
        switch=`echo $line`

        TRKGRP_FILE_PROCESSED=$PROCESSED_PATH/$line"_TRKGRP_PROCESSED"

        for TRKGRP_LINE in `cat $TRKGRP_FILE_PROCESSED`
        do
                clli_ref=($(echo $TRKGRP_LINE|cut -d '|' -f 2))
                awk -v var="$TRKGRP_LINE" -v p1="$clli_ref" '$0~p1 {print var"|"$1}' $ALL_SUPERTKG_MERGED >> $ALL_SUPERTKG_PROCESSED
        done
done < $SWITCH_LIST

####################### extracting from OFCRTE files for TRKGRP_FILE_PROCESSED #######################
cd $PROCESSED_PATH

ALL_OFCRTE_PROCESSED=$PROCESSED_PATH/ALL_OFCRTE_PROCESSED
rm $ALL_OFCRTE_PROCESSED

while read line  || [ -n "$line" ];
do
        echo "OFCRTE files for TRKGRP_FILE_PROCESSED: $line"
        switch=`echo $line`

        TRKGRP_FILE_PROCESSED=$PROCESSED_PATH/$line"_TRKGRP_PROCESSED"

        for TRKGRP_LINE in `cat $TRKGRP_FILE_PROCESSED`
        do
                clli_ref=($(echo $TRKGRP_LINE|cut -d '|' -f 2))
                awk -v var="$TRKGRP_LINE" -v p1="$clli_ref" '$0~p1 {print var"|"$1"|"$2"|"$3}' $ALL_OFCRTE_MERGED >> $ALL_OFCRTE_PROCESSED
        done
done < $SWITCH_LIST

####################### extracting from OFCRTE files for ALL_SUPERTKG_PROCESSED #######################
cd $PROCESSED_PATH

echo "OFCRTE files for ALL_SUPERTKG_PROCESSED"
for SUPERTKG_LINE in `cat $ALL_SUPERTKG_PROCESSED`
do
        TRKGRP_LINE=($(echo $SUPERTKG_LINE|cut -d '|' -f 1-5))
        supertrunk_ref=($(echo $SUPERTKG_LINE|cut -d '|' -f 6))
        awk -v var="$TRKGRP_LINE" -v p1="$supertrunk_ref" '$0~p1 {print var"|"$1"|"$2"|"$3}' $ALL_OFCRTE_MERGED >> $ALL_OFCRTE_PROCESSED
done

####################### extracting from OFCCODE files #######################
cd $PROCESSED_PATH

ALL_OFCCODE_PROCESSED=$PROCESSED_PATH/ALL_OFCCODE_PROCESSED
rm $ALL_OFCCODE_PROCESSED
echo "OFCCODE files"

for OFCRTE_LINE in `cat $ALL_OFCRTE_PROCESSED`
do
        target_switch=($(echo $OFCRTE_LINE|cut -d '|' -f 6))
        translator=($(echo $OFCRTE_LINE|cut -d '|' -f 7))
        lookup_index=($(echo $OFCRTE_LINE|cut -d '|' -f 8))
        awk -v var="$OFCRTE_LINE" -v p1="$target_switch" -v p2="$translator" -v p3="DEST $lookup_index)" '$1~p1 && $0~p2 && $0~p3  {print var"|"$3"|"$4}' $ALL_OFCCODE_MERGED >> $ALL_OFCCODE_PROCESSED
done

####################### logic to retrieve not found CLLI and add into final result #######################
cd $PROCESSED_PATH

cat *_TRKGRP_PROCESSED > $PROCESSED_PATH/ALL_TRKGRP_PROCESSED_MERGED_TEMP
cat $ALL_OFCCODE_PROCESSED | cut -d'|' -f1-5 > $PROCESSED_PATH/ALL_OFCCODE_PROCESSED_TEMP

sort -k1,1 -k2,2 -u ALL_TRKGRP_PROCESSED_MERGED_TEMP > ALL_TRKGRP_PROCESSED_MERGED_SORTED_TEMP
sort -k1,1 -k2,2 -u ALL_OFCCODE_PROCESSED_TEMP > ALL_OFCCODE_PROCESSED_SORTED_TEMP

comm -23 ALL_TRKGRP_PROCESSED_MERGED_SORTED_TEMP ALL_OFCCODE_PROCESSED_SORTED_TEMP > FINAL_RANGE_NOT_FOUND

rm ALL_TRKGRP_PROCESSED_MERGED_TEMP
rm ALL_OFCCODE_PROCESSED_TEMP
rm ALL_TRKGRP_PROCESSED_MERGED_SORTED_TEMP
rm ALL_OFCCODE_PROCESSED_SORTED_TEMP

FINAL_RESULT=$PROCESSED_PATH/FINAL_RESULT.pipe

cat $ALL_OFCCODE_PROCESSED > $FINAL_RESULT
awk '{print $LINE"|||||"}' FINAL_RANGE_NOT_FOUND >> $FINAL_RESULT

####################### Load final result to database #######################
cd $BASE_PATH/script

${SQLLOAD} data=$FINAL_RESULT, control=G9_ddi_range_extract.ctl, LOG=load_final_result.log, ERRORS=100
