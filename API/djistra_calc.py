# -*- coding: utf-8 -*-
"""
Created on Tue Oct 29 10:40:58 2019

@author: Philip
"""
import numpy as np
import pandas as pd
#import credentials as creds
import networkx as nx
import time
import copy
import psycopg2


from sqlalchemy import create_engine
engine = create_engine('postgresql://postgres:housepotato@localhost:5432/gisdb')

dfl = []

for chunk in pd.read_sql("select * from osm_2po_4pgr where ST_Within(ST_Transform(geom_way,4326), ST_SetSRID(ST_BuildArea(ST_GeomFromText('LINESTRING(103.747899 1.448418,\
	103.717000 1.455884,\
	103.672316 1.428042,\
	103.567125 1.208307,\
	103.645382 1.191688,\
	104.035741 1.280736,\
	104.049487 1.353505,\
	103.984832 1.401563,\
	103.948364 1.391565,\
	103.915053 1.425629,\
	103.878286 1.435270,\
	103.829075 1.477364,\
	103.747899 1.448418)')),4326))", engine, chunksize = 20000):
    dfl.append(chunk)

data = pd.concat(dfl, ignore_index = True)
head = data.head()
print(data.head())


#Creating the networkx graph
G = nx.from_pandas_edgelist(data, 'osm_source_id', 'osm_target_id',['cost','reverse_cost'])

nx.single_source_dijkstra(G, 242589896, 2966738136, weight='cost')[0]

bus_stop_data = pd.read_sql('select * from bus_routes_locations',engine)

test = bus_stop_data.head()

from tqdm import tqdm, tqdm_notebook
tqdm_notebook().pandas()

def calculate_dij(start_node,end_node):
    return nx.single_source_dijkstra(G, start_node, end_node, weight='cost')[0]

test['test'] = test.progress_apply(lambda x: calculate_dij(x['osm_source_id'],x['osm_target_id']), axis=1)

bus_stop_data['cost'] = bus_stop_data.progress_apply(lambda x: calculate_dij(x['osm_source_id'],x['osm_target_id']), axis=1)

#data_array_str = "'{"+','.join(str(cost) for cost in bus_stop_data['cost'])+"}'"
#
# #Set up a connection to gisdb, the routing database
#print("Connecting to routing database")
#conn_string = "host="+ "127.0.0.1" +" port="+ "5432" +" dbname="+ "gisdb" +" user=" + "postgres" \
#+" password="+ "housepotato"
#conn_gis=psycopg2.connect(conn_string)
#print("Connected!")
#crsr_gis = conn_gis.cursor()
#
#
#crsr_gis.execute("UPDATE bus_routes_locations SET cost "+data_array_str)
#conn.commit()
#conn.close()

bus_stop_data.to_sql('temp1',engine)
print('done!')
