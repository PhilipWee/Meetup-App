import pandas as pd
#import credentials as creds
import psycopg2

from sqlalchemy import create_engine
engine = create_engine('postgresql://postgres:housepotato@localhost:5432/gisdb')

print("Connecting to routing database")
conn_string = "host="+ "127.0.0.1" +" port="+ "5432" +" dbname="+ "gisdb" +" user=" + "postgres" \
+" password="+ "housepotato"
conn_gis=psycopg2.connect(conn_string)
print("Connected!")
crsr_gis = conn_gis.cursor()

# data = pd.read_csv('D:/restaurant_data.csv')
# print(data.head())

# data.to_sql('singapore_restaurants_2',engine)
# print('done!')

# data = pd.read_csv('D:/outing_data.csv')
# print(data.head())

# data.to_sql('outing_data',engine)
# print('done!')

#data = pd.read_csv('D:/WELLDONEJULIA.csv')
#print(data.head())
#
#data.to_sql('bus_routes_locations',engine)
#print('done!')

data = pd.read_csv('D:/mrtfaretime.csv',encoding = 'unicode_escape')
print(data.head())
print(data['Station_start'].unique())
unique_stations = data['Station_start'].unique()
unique_stn_splt_ls = []
for station in unique_stations:
    unique_stn_splt_ls.append(station.split('\xa0'))

import re

Available_lines = ['BP','CC','CE','CG','DT','EW','NE','NS','PE','PW','SE','SW']
for stn in unique_stn_splt_ls:
    stn_stripped = [re.sub(r'\d+', '', x) for x in stn]
    if 'DT' in stn_stripped:
        print(stn)
        
#Make some hardcoded links for some station connections
links = [['STC','SE1'],
['STC','SE5'],
['STC','SW1'],
['STC','SW8'],
['PTC','PW1'],
['PTC','PW7'],
['PTC','PE1'],
['PTC','PE7'],
['CC4','CE1'],
['CC4','CE1'],
['CG1','CG']]

#Make the station list

