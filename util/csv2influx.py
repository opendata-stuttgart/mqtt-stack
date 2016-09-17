#! /usr/bin/env python3

import datetime
#import requests
import os
import pandas as pd
#from io import StringIO
from influxdb import InfluxDBClient
from influxdb import SeriesHelper

# InfluxDB connections settings
ifxconnset={
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
        data = pd.read_csv(f, delimiter=';')
        data.index=data.apply(lambda row: datetime.datetime.strptime(row.timestamp[:-6], "%Y-%m-%dT%H:%M:%S.%f"), axis=1)
        data=data.drop('timestamp',1)
        
        ifxc=DataFrameClient(ifxconnset['host'],ifxconnset['port'],ifxconnset['user'],ifxconnset['password'],ifxconnset['db'])
        #ifxc.create_database(ifxconnset['db'])
        

#ldate = datetime.date.today() - datetime.timedelta(1)
    #for x in range(ndays):
        #dt = str(ldate - datetime.timedelta(x))
        #url = "http://archive.madflex.de/{dt}/{dt}_ppd42ns_sensor_{sensor_id}.csv".format(dt=dt, sensor_id=sensor_id)
        #print(url)
        #r = requests.get(url)
        #data = data.append(pd.read_csv(StringIO(r.text), delimiter=';'))

