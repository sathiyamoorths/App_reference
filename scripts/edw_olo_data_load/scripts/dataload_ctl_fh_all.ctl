OPTIONS(skip=1)
LOAD DATA 
           
  APPEND INTO TABLE FINANCE_HUB_DATA_LOAD_TEMP
  fields terminated by "|"
  optionally enclosed by '"'   
  TRAILING NULLCOLS
  
(SUMMARY_CREATED CHAR "TRIM(:SUMMARY_CREATED)",
FILE_ID CHAR "TRIM(:FILE_ID)",
PRODUCT CHAR "TRIM(:PRODUCT)",
ACCOUNT_REF CHAR "TRIM(:ACCOUNT_REF)",
INVOICE_REF CHAR "TRIM(:INVOICE_REF)",
BILL_TAX_DATE CHAR "TRIM(:BILL_TAX_DATE)",
NET_TOTAL_BILL_CHARGES CHAR "TRIM(:NET_TOTAL_BILL_CHARGES)",
TOTAL_VAT CHAR "TRIM(:TOTAL_VAT)",
TOTAL_NOT_SUBJECT_VAT CHAR "TRIM(:TOTAL_NOT_SUBJECT_VAT)",
INV_TOTAL_WITH_VAT CHAR "TRIM(:INV_TOTAL_WITH_VAT)",
REVISED_HEADER CHAR "TRIM(:REVISED_HEADER)",
COST_SOURCE CHAR "TRIM(:COST_SOURCE)",
ITEM_ID CHAR "TRIM(:ITEM_ID)",
SUMMARY_ID CHAR "TRIM(:SUMMARY_ID)",
CREATED_DATE CHAR "TRIM(:CREATED_DATE)",
UPDATED_DATE CHAR "TRIM(:UPDATED_DATE)",
ROW_NUMBER CHAR "TRIM(:ROW_NUMBER)",
REC_TYPE CHAR "TRIM(:REC_TYPE)",
PROD_DESC CHAR "TRIM(:PROD_DESC)",
PROD_TARIFF_NAME CHAR "TRIM(:PROD_TARIFF_NAME)",
PROD_LABEL CHAR "TRIM(:PROD_LABEL)",
CHARGE_DESC CHAR "TRIM(:CHARGE_DESC)",
CHARGE_REASON CHAR "TRIM(:CHARGE_REASON)",
START_DATE CHAR "TRIM(:START_DATE)",
END_DATE CHAR "TRIM(:END_DATE)",
ADDR_LINE_1 CHAR "TRIM(:ADDR_LINE_1)",
POSTCODE CHAR "TRIM(:POSTCODE)",
CSS_SEIBEL_JOBNO CHAR "TRIM(:CSS_SEIBEL_JOBNO)",
ORDER_NO CHAR "TRIM(:ORDER_NO)",
SPARE CHAR "TRIM(:SPARE)",
QTY CHAR "TRIM(:QTY)",
UNITS CHAR "TRIM(:UNITS)",
UNIT_RATE CHAR "TRIM(:UNIT_RATE)",
AMOUNT CHAR "TRIM(:AMOUNT)",
VAT_STATUS CHAR "TRIM(:VAT_STATUS)",
CSS_ACC_NO CHAR "TRIM(:CSS_ACC_NO)",
PROD_TYPE CHAR "TRIM(:PROD_TYPE)",
OR_SERVICE_ID CHAR "TRIM(:OR_SERVICE_ID)",
CIRCUIT_ID CHAR "TRIM(:CIRCUIT_ID)",
MDF_SITE CHAR "TRIM(:MDF_SITE)",
ROOM_ID CHAR "TRIM(:ROOM_ID)",
SERVICE_ID CHAR "TRIM(:SERVICE_ID)",
EVENT_CLASS CHAR "TRIM(:EVENT_CLASS)",
EVENT_NAME CHAR "TRIM(:EVENT_NAME)",
CBUK_REF CHAR "TRIM(:CBUK_REF)",
CLI CHAR "TRIM(:CLI)",
MAC_CODE CHAR "TRIM(:MAC_CODE)",
FREE_TXT CHAR "TRIM(:FREE_TXT)",
TRC_START CHAR "TRIM(:TRC_START)",
CLEAR_CODE CHAR "TRIM(:CLEAR_CODE)",
TRC_DESC CHAR "TRIM(:TRC_DESC)",
PRICE_LIST_REF CHAR "TRIM(:PRICE_LIST_REF)",
PRICE_LIST_DESC CHAR "TRIM(:PRICE_LIST_DESC)",
PERIOD CHAR "TRIM(:PERIOD)",
BILLING_ACCOUNT_NUM CHAR "TRIM(:BILLING_ACCOUNT_NUM)",
PRIME_PRODUCT CHAR "TRIM(:PRIME_PRODUCT)",
EQUIP_CODE CHAR "TRIM(:EQUIP_CODE)",
OBN_FLAG CHAR "TRIM(:OBN_FLAG)",
OBN_FLAG_CONF CHAR "TRIM(:OBN_FLAG_CONF)",
OBN_SCENARIO CHAR "TRIM(:OBN_SCENARIO)",
S16_FLAG CHAR "TRIM(:S16_FLAG)",
DEPARTMENT CHAR "TRIM(:DEPARTMENT)",
DEPARTMENT_CODE CHAR "TRIM(:DEPARTMENT_CODE)",
PROCESSED CHAR "TRIM(:PROCESSED)",
PROCESSED_ERROR CHAR "TRIM(:PROCESSED_ERROR)",
CHARGE_TYPE CHAR "TRIM(:CHARGE_TYPE)",
SUNDRY_CODE CHAR "TRIM(:SUNDRY_CODE)",
XRF_VAL CHAR "TRIM(:XRF_VAL)",
ONWARD_BILLING_REPORT CHAR "TRIM(:ONWARD_BILLING_REPORT)",
ONWARD_BILLING_ACCOUNT CHAR "TRIM(:ONWARD_BILLING_ACCOUNT)",
REVENUE_TYPE CHAR "TRIM(:REVENUE_TYPE)",
SOURCE_SYSTEM CHAR "TRIM(:SOURCE_SYSTEM)",
T3RD_PARTY_SERVICE_REF CHAR "TRIM(:T3RD_PARTY_SERVICE_REF)",
VF_SERVICE_ID CHAR "TRIM(:VF_SERVICE_ID)",
VF_ORDER_REF CHAR "TRIM(:VF_ORDER_REF)",
T3RD_PARTY_ORDER_REF CHAR "TRIM(:T3RD_PARTY_ORDER_REF)",
T3RD_PARTY_SERVICE_ID CHAR "TRIM(:T3RD_PARTY_SERVICE_ID)",
ENRICHED_BY CHAR "TRIM(:ENRICHED_BY)",
BILLING_SYSTEM CHAR "TRIM(:BILLING_SYSTEM)",
EDGE_BILLING_ACC_NO CHAR "TRIM(:EDGE_BILLING_ACC_NO)",
ONWARD_BILLING_CHUNK CHAR "TRIM(:ONWARD_BILLING_CHUNK)",
ORDER_SUFFIX CHAR "TRIM(:ORDER_SUFFIX)",
RESELLER_ID CHAR "TRIM(:RESELLER_ID)",
ORDER_TYPE CHAR "TRIM(:ORDER_TYPE)",
ENRICHED_BY_ROWID CHAR "TRIM(:ENRICHED_BY_ROWID)",
RESELLER_FLAG CHAR "TRIM(:RESELLER_FLAG)",
CPS_WLR_FLAG CHAR "TRIM(:CPS_WLR_FLAG)",
SUSPENSE_CODES CHAR "TRIM(:SUSPENSE_CODES)",
ITEM_ID_SRC CHAR "TRIM(:ITEM_ID_SRC)",
PID CHAR "TRIM(:PID)",
PID_NAME CHAR "TRIM(:PID_NAME)",
NPID CHAR "TRIM(:NPID)",
NPID_NAME CHAR "TRIM(:NPID_NAME)",
HPID CHAR "TRIM(:HPID)",
HPID_NAME CHAR "TRIM(:HPID_NAME)",
EX_SC_CODE CHAR "TRIM(:EX_SC_CODE)",
EX_SC_NAME CHAR "TRIM(:EX_SC_NAME)",
ITEM_SPLIT CHAR "TRIM(:ITEM_SPLIT)",
COST_TYPE CHAR "TRIM(:COST_TYPE)",
COST_CENTRE CHAR "TRIM(:COST_CENTRE)",
MAN_RELEASE CHAR "TRIM(:MAN_RELEASE)",
NO_DATES CHAR "TRIM(:NO_DATES)",
CORRECTED_BY CHAR "TRIM(:CORRECTED_BY)",
CORRECTION_DATE CHAR "TRIM(:CORRECTION_DATE)",
SUSPENSE_DESCRIP CHAR "TRIM(:SUSPENSE_DESCRIP)",
BT_INVOICE_EXPORT CHAR "TRIM(:BT_INVOICE_EXPORT)",
BT_INVOICE_ID CHAR "TRIM(:BT_INVOICE_ID)")