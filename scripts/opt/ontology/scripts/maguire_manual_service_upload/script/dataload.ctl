OPTIONS(skip=1)
LOAD DATA 
  infile               '/opt/ontology/scripts/maguire_manual_service_upload/upload/rmvNewline.csv'          
  TRUNCATE into table  MAGUIRE_TEMP_MANUAL_SERVICE
  fields terminated by ","
  optionally enclosed by '"'   
  TRAILING NULLCOLS      
  (Sequence_no CHAR "TRIM(:Sequence_no)",
Service_ID CHAR "TRIM(:Service_ID)",
Nominated_Party CHAR "TRIM(:Nominated_Party)",
Contractual_Customer CHAR "TRIM(:Contractual_Customer)",
Billing_Customer CHAR "TRIM(:Billing_Customer)",
Project_Id CHAR "TRIM(:Project_Id)",
PID CHAR "TRIM(:PID)",
NPID CHAR "TRIM(:NPID)",
Batch_ID CHAR "TRIM(:Batch_ID)",
Maguire_Status CHAR "TRIM(:Maguire_Status)",
Action_Owner CHAR "TRIM(:Action_Owner)",
Sub_Group CHAR "TRIM(:Sub_Group)",
Company_Reg_No CHAR "TRIM(:Company_Reg_No)",
Market CHAR "TRIM(:Market)",
Segment CHAR "TRIM(:Segment)",
Channel CHAR "TRIM(:Channel)",
Product_Name CHAR "TRIM(:Product_Name)",
Products_Comments CHAR "TRIM(:Products_Comments)",
Billing_Ops_Comments CHAR "TRIM(:Billing_Ops_Comments)",
Margin_Max_Comments CHAR "TRIM(:Margin_Max_Comments)",
Analysis_Comments CHAR "TRIM(:Analysis_Comments)",
Root_Cause CHAR "TRIM(:Root_Cause)",
Prov_System CHAR "TRIM(:Prov_System)",
Provisioning_Status CHAR "TRIM(:Provisioning_Status)",
Olo_Status CHAR "TRIM(:Olo_Status)",
Billing_Status CHAR "TRIM(:Billing_Status)",
Customer_Circuit_Ref CHAR "TRIM(:Customer_Circuit_Ref)",
Prov_Start_Date CHAR "TRIM(:Prov_Start_Date)",
Prov_Cease_Date CHAR "TRIM(:Prov_Cease_Date)",
Service_Age CHAR "TRIM(:Service_Age)",
Billing_System CHAR "TRIM(:Billing_System)",
Billing_Account_Number CHAR "TRIM(:Billing_Account_Number)",
Erasable_Account CHAR "TRIM(:Erasable_Account)",
First_Billed_Date CHAR "TRIM(:First_Billed_Date)",
Latest_Billed_Date CHAR "TRIM(:Latest_Billed_Date)",
Latest_Billed_Amount CHAR "TRIM(:Latest_Billed_Amount)",
Price CHAR "TRIM(:Price)",
One_Off_Charge CHAR "TRIM(:One_Off_Charge)",
Total_Billed_Amount CHAR "TRIM(:Total_Billed_Amount)",
Equipment_Details CHAR "TRIM(:Equipment_Details)",
DDI CHAR "TRIM(:DDI)",
Olo_Tail CHAR "TRIM(:Olo_Tail)",
Olo_Provider CHAR "TRIM(:Olo_Provider)",
Olo_First_Invoiced_Date CHAR "TRIM(:Olo_First_Invoiced_Date)",
Olo_Lastest_Invoiced_Date CHAR "TRIM(:Olo_Lastest_Invoiced_Date)",
Olo_Latest_Invoiced_Amount CHAR "TRIM(:Olo_Latest_Invoiced_Amount)",
Olo_Total_Invoiced_Amount CHAR "TRIM(:Olo_Total_Invoiced_Amount)",
Underbill CHAR "TRIM(:Underbill)",
Underbill_Capped_36 CHAR "TRIM(:Underbill_Capped_36)",
Overbill CHAR "TRIM(:Overbill)",
Overbill_Capped_36 CHAR "TRIM(:Overbill_Capped_36)",
Undercost CHAR "TRIM(:Undercost)",
Undercost_Capped_36 CHAR "TRIM(:Undercost_Capped_36)",
Overcost CHAR "TRIM(:Overcost)",
Overcost_Capped_36 CHAR "TRIM(:Overcost_Capped_36)",
Recovery_Amount CHAR "TRIM(:Recovery_Amount)",
Recovery_Date CHAR "TRIM(:Recovery_Date)",
Provide_Order CHAR "TRIM(:Provide_Order)",
Cease_Order CHAR "TRIM(:Cease_Order)",
Associated_Orders CHAR "TRIM(:Associated_Orders)",
Site_Address_2 CHAR "TRIM(:Site_Address_2)",
Site_Address_1 CHAR "TRIM(:Site_Address_1)",
Incident CHAR "TRIM(:Incident)",
Debt_Status CHAR "TRIM(:Debt_Status)")



















































