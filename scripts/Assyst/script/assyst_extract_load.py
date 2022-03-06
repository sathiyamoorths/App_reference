import os
import cx_Oracle
import user_config as config
import pandas as pd
import logging
import Logger
import csv
import zipfile
import shutil
import glob

connection = None
logFile = '/opt/ontology/scripts/Assyst/log/Assyst_load.log'
dir_path = '/opt/ontology/scripts/Assyst/input/'
arc_path = '/opt/ontology/scripts/Assyst/Archive'

# remove previous run's log file

if os.path.exists(logFile):
	os.remove(logFile)
else:
	pass

try:
	
	Logger.log_write(logFile, Logger.formatLog, "Connecting to Database ...", logging.INFO)
	connection = cx_Oracle.connect(
	config.pr_username,
	config.pr_password,
	config.dsn,
	encoding=config.encoding)

    # show the version of the Oracle Database
	Logger.log_write(logFile, Logger.formatLog, "Connecting to Database: " + config.dsn, logging.INFO)
	Logger.log_write(logFile, Logger.formatLog, "Database Version: " + connection.version, logging.INFO)
	Logger.log_write(logFile, Logger.formatLog, "Connection to Database successful", logging.INFO)
	connection.autocommit = True
	cur = connection.cursor()
	
	os.chdir(dir_path)
		

	try:
		Logger.log_write(logFile, Logger.formatLog, "Reading the files", logging.INFO)
		cur.execute("TRUNCATE TABLE T_ASSYST_EXTRACT")
		cur.execute("TRUNCATE TABLE ASSYST_EXTRACT")
		
		file_name=''
		DIR = os.listdir()
		for file in DIR:
			if file.endswith('.csv'):
				file_name=file
		
		
		csv.register_dialect(
		'mydialect',
		delimiter = '|',
		skipinitialspace = True,
		lineterminator = '\r\n',
		quoting = csv.QUOTE_NONE)
		with open(dir_path+'Assyst_extract_final.csv','r', encoding='utf-8',errors='ignore') as uz_file:
			file_reader=pd.read_csv(uz_file, skiprows=1,delimiter='|')
			l=file_reader.fillna('null').values.tolist()
			cur.executemany("INSERT INTO T_ASSYST_EXTRACT (CUSTOMER, ASSYST_REF, HOSTNAME, DEVICE_TYPE, PRODUCT, SERIAL, STATUS, SERVICE_DEPARTMENT, SLA, BUILDING, CABINET, RELATIONSHIP, OPERATING_SYSTEM, DATE_ACQUIRED, INSTALLATION_DATE) VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15 )",l, batcherrors = True)
			for error in cur.getbatcherrors():
				print("Row", error.offset, "has error", error.message)
			connection.commit()
			#print("Rows inserted = {}".format(cur.rowcount))
			cur.callproc("LOAD_ASSYST_EXTRACT")
			Logger.log_write(logFile, Logger.formatLog, "Record Insertion into DB completed", logging.INFO)
	except Exception as error:
		#print("lines: "+lines)
		Logger.log_write(logFile, Logger.formatLog, error, logging.ERROR)
		print(error)
		Logger.log_write(logFile, Logger.formatLog, error, logging.ERROR)
	finally:
		if cur:
			cur.close()

except cx_Oracle.DatabaseError as error:
	Logger.log_write(logFile, Logger.formatLog, error, logging.ERROR)
	Logger.log_write(logFile, Logger.formatLog, "Connection to Database Failed ... check the connection settings", logging.ERROR)
finally:
    # release the connection
	if connection:
		
		connection.close()
		Logger.log_write(logFile, Logger.formatLog, "Closing the Connections ... Exiting from script...", logging.INFO)
		
	
