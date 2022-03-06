OPTIONS(skip=1)
LOAD DATA 
  infile               '/opt/ontology/input/Filter-View-Upload/upload/*.csv'          
  APPEND into table   service_view_filter
WHEN (SERVICEID<> 'SERVICE_ID')
  fields terminated by ","
  optionally enclosed by '"'   
  TRAILING NULLCOLS      
  (SERVICEID,
FILTER,
USERS,
INSERTION_DATE "SYSTIMESTAMP")