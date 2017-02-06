#! /usr/bin/env python3

import argparse
import datetime
#import requests
import os
import pandas as pd
#from io import StringIO
from influxdb import InfluxDBClient
from influxdb import SeriesHelper
from influxdb import DataFrameClient

# InfluxDB connections settings
ifxparm={
'host': 'localhost',
'port': 8086,
'user': '',
'password': '',
'db': 'csv2influx',
}

# work on a local copy of csvfiles from 
archiveDir = 'archive.luftdaten.info'
datafileext = '.csv'

# TODO: extend/do this for URLs

csvfilelist=[]
for dirpath, dirnames, files in os.walk(archiveDir):
    for name in files:
        if name.lower().endswith(datafileext):
            csvfilelist.append(os.path.join(dirpath, name))
            
data = pd.DataFrame()
for csvfile in csvfilelist[1:2]:
    print(csvfile)
    with open(csvfile,'r') as f:
        #sensor_id;sensor_type;location;lat;lon;timestamp;P1;durP1;ratioP1;P2;durP2;ratioP2
        #89;PPD42NS;47;48.827;9.129;2016-07-01T00:00:13.642743+00:00;24.59;13833;0.05;0.62;0;0.00
        #89;PPD42NS;47;48.827;9.129;2016-07-01T00:00:44.365802+00:00;114.12;65580;0.22;0.62;0;0.00
        data = pd.read_csv(f, delimiter=';')
        data.index=data.apply(lambda row: datetime.datetime.strptime(row.timestamp[:-6], "%Y-%m-%dT%H:%M:%S.%f"), axis=1)
        data=data.drop('timestamp',1)
        
        ifxc=DataFrameClient(ifxparm['host'],ifxparm['port'],ifxparm['user'],ifxparm['password'],ifxparm['db'])
        
        ifxc.write_points(data,'luftdaten.info',tags={'sensor_id':'0','sensor_type':0,'location':0})
        
        #write_points(dataframe, measurement, tags=None, time_precision=None, database=None, retention_policy=None, batch_size=None)
        
        #ifxc.create_database(ifxparm['db'])
        

#ldate = datetime.date.today() - datetime.timedelta(1)
    #for x in range(ndays):
        #dt = str(ldate - datetime.timedelta(x))
        #url = "http://archive.madflex.de/{dt}/{dt}_ppd42ns_sensor_{sensor_id}.csv".format(dt=dt, sensor_id=sensor_id)
        #print(url)
        #r = requests.get(url)
        #data = data.append(pd.read_csv(StringIO(r.text), delimiter=';'))

