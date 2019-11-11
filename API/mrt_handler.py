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
    if 'SW' in stn_stripped:
        print(stn)
        
#Get just the station name
def get_stn_name(array):
#    print(array)
    for string in array:
        if string.replace(" ","").strip().isalpha() and string != "" and string not in ['STC','PTC']:
            return string.strip()

def get_stn_name_frm_str(string):
    stn = string.split('\xa0')
#    stn_stripped = [re.sub(r'\d+', '', x) for x in stn]
#    print(stn_stripped)
    result = get_stn_name(stn)
    return result
    
print(get_stn_name_frm_str('SW8\xa0 Renjong'))


#Make the station list
def is_stn(string):
    if any(c.islower() for c in string) or string == "":
        return False
    else:
        return True

#Get all the stations
stations = set()
for stn in unique_stn_splt_ls:
    for string in stn:
#        print(string)
        if is_stn(string):
            stations.add(string)
            
#Make a dict for each Name letter number pair
stns_dict = {}
for stn in unique_stn_splt_ls:
    name = get_stn_name(stn)
#    name = name.strip()
    stns_dict[name]= []
    for string in stn:
        if is_stn(string):
            stns_dict[name].append(string)
            
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

#Make all the edges
for line_prefix in Available_lines:
    for i in range(0,100):
        current_line = line_prefix + str(i)
        #Check that the current line is in the stations
        if current_line in stations:
            #the current line is inside, find the next line that is inside
            for j in range(1,10):
                next_line = line_prefix + str(i + j)
                if next_line in stations:
                    links.append([current_line,next_line])
                    break
            continue

data['Station_start'] = data.progress_apply(lambda x: get_stn_name_frm_str(x['Station_start']), axis=1)
data['Station_end'] = data.progress_apply(lambda x: get_stn_name_frm_str(x['Station_end']), axis=1)

def create_inverse_dict(dct):
    new_dct = {}
    for key,value in dct.items():   
        for x in value:
            new_dct[x] = key
    return new_dct
            
inv_stn_dict = create_inverse_dict(stns_dict)
inv_stn_dict['CG'] = 'Tanah Merah'

converted_links = []
for link in links:
    converted_links.append([inv_stn_dict[link[0]],inv_stn_dict[link[1]]])
    

relevant_edges = [True if list(x) in converted_links else False for x in zip(data['Station_start'],data['Station_end'])]
data_only_edges = data[relevant_edges]

data_only_edges = data_only_edges.reset_index()
data_only_edges = data_only_edges.drop(columns = ['index'])
data_only_edges['Time'] = data_only_edges['Time']/60

data_only_edges.to_sql('mrt_map_edges',engine)
print('done!')
