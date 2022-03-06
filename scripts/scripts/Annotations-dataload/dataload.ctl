OPTIONS(skip=1)
LOAD DATA 
  infile               '/opt/ontology/input/Annoations-File-Upload/upload/output1.csv'          
  APPEND into table  annotation_validation_temp
WHEN (PRIMARY_ID<> 'PRIMARY_ID')
  fields terminated by ","
  optionally enclosed by '"'   
  TRAILING NULLCOLS      
  (PRIMARY_ATTRIBUTE,
PRIMARY_ID CHAR "TRIM(:PRIMARY_ID)",
ATTRIBUTE_NAME CHAR "TRIM(:ATTRIBUTE_NAME)",
NEW_VALUE  char(4000),
USER_NAME CHAR "TRIM(:USER_NAME)",
MODIFIED_TIME "TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI')",
FILENAME,
INSERTION_TIME "SYSTIMESTAMP")
