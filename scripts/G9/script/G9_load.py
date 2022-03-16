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
import datetime

connection = None
logFile = '/opt/ontology/scripts/G9/log/G9_load.log'
dir_path = '/opt/ontology/scripts/G9/input/'
arc_path = '/opt/ontology/scripts/G9/Archive'

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
		cur.execute("TRUNCATE TABLE NETWORK_C20_CLLI")
		cur.execute("TRUNCATE TABLE NETWORK_C20_PORTS")
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
		
		for file_name in glob.glob(dir_path+'DMS_Ports/*.csv'):
			#print(file_name)
			with open(file_name,'r') as uz_file:
				#print(dir_path+file_name)
				file_reader=pd.read_csv(uz_file,delimiter=',')
				#file_reader=csv.reader(uz_file, delimiter=',')
				l=file_reader.fillna('null').values.tolist()
				#l=list(file_reader)
				cur.bindarraysize = len(l)
				cur.setinputsizes (int, 1000)
				#print(len(l))
				cur.executemany("INSERT INTO NETWORK_C20_PORTS (switch_code, field2, field3, field4, CLLI, field6, status,signalling) VALUES (:1, :2, :3, :4, :5, :6, :7, :8 )",l, batcherrors = True)
				
				for error in cur.getbatcherrors():
					print("Row", error.offset, "has error", error.message)
				connection.commit()
				#print("Rows inserted = {}".format(cur.rowcount))
				Logger.log_write(logFile, Logger.formatLog, "Record Insertion into DB completed", logging.INFO)
		cur.execute('update NETWORK_C20_PORTS set field4=null where field4=:nm',nm="null")
		connection.commit()
		
		for file_name in glob.glob(dir_path+'DMS_Data/*.cap'):
			#print(file_name)
			with open(file_name,'r') as uz_file:
				#print(dir_path+file_name)
				file_reader=pd.read_csv(uz_file,skiprows=1,delimiter=',')
				#file_reader=csv.reader(uz_file, delimiter=',')
				lines=[]
				switch_code = file_name.split('/')[-1].split('_')[0]
				i=0
				for key,value in file_reader.iterrows():
					l=[]
					l.insert(0,switch_code)
					l.insert(1," ".join(map(str, value)))
					l.insert(2,datetime.datetime.now().strftime("%d-%b-%y"))
					lines.append(l)
					
				cur.bindarraysize = len(lines)
				cur.setinputsizes (int, 1000)
				cur.executemany("INSERT INTO network_c20_clli (switch_code, TXT, UPLOAD_TIMESTAMP) VALUES (:1, :2, :3 )",lines, batcherrors = True)
				
				for error in cur.getbatcherrors():
					print("Row", error.offset, "has error", error.message)
				connection.commit()
				#print("Rows inserted = {}".format(cur.rowcount))
				Logger.log_write(logFile, Logger.formatLog, "Record Insertion into DB completed", logging.INFO)
		#cur.execute('update network_c20_clli set field4=null')
		#connection.commit()
	except Exception as error:
		#print("lines: "+lines)
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
		
	
