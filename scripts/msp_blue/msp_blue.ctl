OPTIONS(skip=1)
LOAD DATA 
			     
  APPEND INTO table  network_MSP_BLUE

  fields terminated by ","
  optionally enclosed by '"'   
  TRAILING NULLCOLS (
ROUTER,
PORT,
CUSTOMER,
ADMIN,
OPER,
DESCRIPTION,
UPLOAD_DATE "SYSDATE" )