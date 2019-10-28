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

G2 = G.subgraph(max(nx.connected_components(G), key=len))

nx.is_connected(G2)


#G3 = nx.Graph(G2)

#FUNCTION V3
def get_neighbors(Graph,node):
    neighbors = Graph.neighbors(node)
    neighbors_list = []
    for neighbor in neighbors:
        neighbors_list.append(neighbor)
    return neighbors_list

def bfs_small(graph, start, visited_nodes, touched_queue, group_size = 250):
    """
    Return visited_nodes, touched_queue, group_nodes ,True if the group size is 300
    Return visited_nodes, touched_queue, group_nodes ,False if the group size is less than 300
    """
    group_nodes = set()
    while touched_queue:
        #Get the next vertex to visit
        vertex = touched_queue.pop(0)
        #Add it to the set of visited nodes and group_nodes
        visited_nodes.add(vertex)
        group_nodes.add(vertex)
        #Get the next set of neighbors
        new_cases = set(get_neighbors(graph,vertex))
        #Extend the queue with unvisited neighbors
        touched_queue.extend(new_cases - visited_nodes)
        touched_queue = list(filter(lambda x: x not in visited_nodes, touched_queue))
        if len(group_nodes) >= group_size:
            return visited_nodes, touched_queue, group_nodes, True
    return visited_nodes,touched_queue,group_nodes,False

def add_stragglers(graph, visited_nodes, touched_queue, group_size = 250):
    stragglers = set()
    additional_starters = []
    new_visited_nodes = copy.deepcopy(visited_nodes)
    to_check_queue = [x for x in touched_queue]
    while to_check_queue:
        #Get the next vertex in touched to check
        vertex = to_check_queue.pop(0)
        #find the bfs small for just the current vertex
        new_visited_nodes,touched_queue_child,group_nodes,still_more = bfs_small(graph, vertex, new_visited_nodes, [vertex])
        #if there are still more than 300, record those which have been found
        if still_more:
            starter_dict = {'vertex':vertex,
                            'group_nodes':group_nodes,
                            'touched_queue_child':touched_queue_child}
            additional_starters.append(starter_dict)
        #if there are less than 300, add to the original group
        else:
            stragglers.update(group_nodes)
        #Make sure that the additional starters do not contain the stragglers
    #WHY DOES IT THOUGH
    for i in range(len(additional_starters)):     
        additional_starters[i]['group_nodes'] -= stragglers
    return stragglers, additional_starters, new_visited_nodes
        
        
def main():
    """
    run the actual grouping algorithm
    """
    number_of_nodes = len(G2.nodes)
    
    _start = 158094808
    _visited_nodes, _touched_queue, _results, _graph = set(), [_start], [], G2
    
    #run bfs on starting node
    _visited_nodes, _touched_queue, _group_nodes, _size = bfs_small(_graph, _start, _visited_nodes, _touched_queue)
    #find the stragglers, as well as additional starters
    _stragglers, _additional_starters, _visited_nodes = add_stragglers(G2, _visited_nodes, _touched_queue)
    #Add the stragglers to the group nodes
    _group_nodes.update(_stragglers)
    #Add the group nodes to the results
    _results.append(_group_nodes)
    
    #Create a queue for the additional starters
    _addit_starter_queue = copy.deepcopy(_additional_starters)
    
    while _addit_starter_queue:
        #Repeat with the additional starters
        current_starter = _addit_starter_queue.pop(0)
        _touched_queue = current_starter['touched_queue_child']
        #find the stragglers, as well as additional starters
        _stragglers, _additional_starters_2, _visited_nodes = add_stragglers(G2, _visited_nodes, _touched_queue)
        #Create the group by adding in the stragglers
        _group_nodes = current_starter['group_nodes'].union(_stragglers)
        #Append the current group to the results
        _results.append(_group_nodes)
        #Extend the addit starter queue
        _addit_starter_queue.extend(_additional_starters_2)
        print('Results are now',len(_results),'long, we have visited',len(_visited_nodes),'nodes of',number_of_nodes)
    
    return _results

#Upload the results to the database
results = main()
results_df = pd.DataFrame({'member_ids':[list(x) for x in results],
                           'cost_car':None,
                           'cost_public':None,
                           'cost_walking':None})
results_df.index.names = ['group_id']
results_df.head()
results_df.to_sql('node_groups', engine, if_exists='replace')

reverse_dict = {}

#Inverse the results to point from target node to group
for i in range(len(results)):
    for node in results[i]:
        reverse_dict[node] = i

#Assign the group numbers the dataframe
data['group_id'] = pd.Series(int(reverse_dict[x]) if x in reverse_dict.keys() else -1 for x in data['osm_target_id'])

temp_table = data[['osm_target_id','group_id']]

print("Connecting to the postgres server")
conn_string = "host="+ '127.0.0.1' +" port="+ "5432" +" dbname="+ 'gisdb' +" user=" + 'postgres' \
+" password="+ 'housepotato'
conn=psycopg2.connect(conn_string)
print("Connected!")
crsr = conn.cursor()

#Create the new column
#crsr.execute('alter table osm_2po_4pgr add column group_id smallint')
#conn.commit()

#Create a temp table
temp_table.to_sql('temp_table', engine, if_exists='replace')

#Update the column with the necessary details
crsr.execute('update osm_2po_4pgr set group_id = -1')
conn.commit()
crsr.execute('update osm_2po_4pgr \
set group_id = temp_table.group_id \
from temp_table \
where temp_table.osm_target_id = osm_2po_4pgr.osm_target_id')
conn.commit()

print('DONE!')
