OPTIONS(skip=1)
LOAD DATA 
  infile               '/opt/ontology/scripts/blue_frame_atm/upload/output.csv'          
  TRUNCATE into table  NETWORK_FRAME_BLUE_TEMP
  fields terminated by ","
  optionally enclosed by '"'   
  TRAILING NULLCOLS      
  (
NODE ,
FRUNI,
UNLCK,
ENA,
LMI_STATUS1,
LMI_STATUS2,
ANSI,
FIELD1,
FIELD2,
PORT,
SBEARER,
Nx64K,
COMMENTS,
JASON_ACTION
)

