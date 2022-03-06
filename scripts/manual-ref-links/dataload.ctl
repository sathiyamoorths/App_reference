OPTIONS(skip=1)
LOAD DATA 
  infile               'CGFILENAME'          
  APPEND into table   MANUAL_SERVICE_MERGE
WHEN (PRIMARY_SERVICE_REF<> 'PRIMARY_SERVICE_REF')
  fields terminated by ","
  optionally enclosed by '"'   
  TRAILING NULLCOLS      
  (PRIMARY_SERVICE_REF,
SECONDARY_SERVICE_REF,
IGNORE,COMMENTS )