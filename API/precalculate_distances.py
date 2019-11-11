# -*- coding: utf-8 -*-
"""
Created on Sat Oct 12 20:43:22 2019

@author: Philip
"""

import numpy as np
import pandas as pd
#import credentials as creds
import networkx as nx
import time
import copy
import psycopg2
import time

from sqlalchemy import create_engine
engine = create_engine('postgresql://postgres:housepotato@localhost:5432/gisdb')

#get a node from each group

sql = """WITH summary AS (
    SELECT p.group_id, 
           p.osm_target_id,
		   ROW_NUMBER() OVER(PARTITION BY p.group_id) AS rk
      FROM osm_2po_4pgr p)
SELECT s.*
  FROM summary s
 WHERE s.rk = 1"""

node_groups = pd.read_sql(sql, engine)

#Convert to an array
node_groups_list = node_groups['osm_target_id'].values[1:]
node_to_group_dict = {node_groups_list[i]:i for i in range(len(node_groups_list))}
results = []
max_value = len(node_groups_list)-1

#For each group, get time taken to all other groups
for i in range(len(node_groups_list)):
    start_time = time.time()
    group_id = i
    starting_node = node_groups_list[i]
#    print(starting_node)
    #Create array for every other node
    remaining_nodes = node_groups_list[i+1:]
#    print(remaining_nodes)
    remaining_nodes_array = "ARRAY["+','.join(str(node) for node in remaining_nodes)+"]::bigint[]"
    if i != len(node_groups_list-1):
        sql = "SELECT * FROM pgr_dijkstra( \
        'SELECT osm_id as id, osm_source_id as source, osm_target_id as target, cost, reverse_cost FROM osm_2po_4pgr', \
        "+str(starting_node)+","+ remaining_nodes_array+") where edge = -1;"
        results_df = pd.read_sql(sql,engine)
        #Add the groups
        results_df['group'] = pd.Series(node_to_group_dict[node] for node in results_df['end_vid'])
        #Make it into a dict
        results_dict = {int(row['group']):row['agg_cost'] for index,row in results_df.iterrows()}
        results_dict[i] = 0
        #Add all the missing values based on what is already in the results
    for j in range(i):
        results_dict[j] = results[j][i]
    #Convert the dictionary to a list
    results_list = [results_dict[k] for k in range(max_value+1)]
    results.append(results_list)
    print('Completed for group',i,'took',time.time()-start_time,'seconds')

collated_results_df = pd.DataFrame({'car_cost':['{'+str(result)[1:-2]+'}' for result in results]})
collated_results_df.to_sql('group_times_matrix',engine,if_exists='replace')

sql = """
update group_times_matrix
set car_cost = cast(car_cost as double precision[])
"""
    
print("Connecting to the postgres server")
conn_string = "host="+ '127.0.0.1' +" port="+ "5432" +" dbname="+ 'gisdb' +" user=" + 'postgres' \
+" password="+ 'housepotato'
conn=psycopg2.connect(conn_string)
print("Connected!")
crsr = conn.cursor()

crsr.execute(sql)
conn.commit()
    
    
    
    
    
    
    
    
    
    