#!/bin/sh

cd /opt/ontology/scripts/msp_blue/upload/

for audname in *.csv
do
	filename=($( echo $audname | sed 's/[0-9]//g' ))
	mv $audname $filename

done

##inlist_msp_uk_201809.csv