#--------------------------------------REQUIREMENTS--------------------------------------


from flask import jsonify
import psycopg2
import pandas as pd
import json
import time
from heapq import heappush, heappop
from networkx import NetworkXError
from itertools import count
import seaborn as sns
import matplotlib.pyplot as plt
import networkx as nx
from operator import add

#--------------------------------------REQUIREMENTS--------------------------------------

PGHOST='127.0.0.1'
PGDATABASE='session_info'
PGROUTINGDATABASE='gisdb'
PGUSER='postgres'
PGPASSWORD='housepotato'


#--------------------------------------CONNECT TO DATABASE-------------------------------
# Set up a connection to the postgres server.
print("Connecting to the postgres server")
conn_string = "host="+ PGHOST +" port="+ "5432" +" dbname="+ PGDATABASE +" user=" + PGUSER \
+" password="+ PGPASSWORD
conn=psycopg2.connect(conn_string)
print("Connected!")
crsr = conn.cursor()
#Set up a connection to gisdb, the routing database
print("Connecting to routing database")
conn_string = "host="+ PGHOST +" port="+ "5432" +" dbname="+ PGROUTINGDATABASE +" user=" + PGUSER \
+" password="+ PGPASSWORD
conn_gis=psycopg2.connect(conn_string)
print("Connected!")
crsr_gis = conn_gis.cursor()

from sqlalchemy import create_engine
engine = create_engine('postgresql+psycopg2://'+PGUSER+':'+PGPASSWORD+'@'+PGHOST+':5432/'+PGROUTINGDATABASE)
#--------------------------------------CONNECT TO DATABASE-------------------------------

print('Getting Databases')
public_xy_id = pd.read_sql('select DISTINCT(source),x1,y1 from public_edges',conn_gis)
driving_xy_id = pd.read_sql('select DISTINCT(osm_source_id) as source,x1,y1 from osm_2po_4pgr', conn_gis)
walking_xy_id = pd.read_sql('SELECT  DISTINCT(osm_source_id) as source,x1,y1 FROM osm_2po_4pgr where clazz!=11', conn_gis)

public = pd.read_sql('select source,target,x1,y1,x2,y2,cost,reverse_cost from public_edges',conn_gis)
driving = pd.read_sql('SELECT  osm_source_id as source, osm_target_id as target, cost, reverse_cost,x1,y1,x2,y2 FROM osm_2po_4pgr',conn_gis)
walking = pd.read_sql('SELECT  osm_source_id as source, osm_target_id as target, cost*kmh/5 as cost, reverse_cost*kmh/5 as reverse_cost,x1,y1,x2,y2,closest_outing_node,closest_restaurant_node  FROM osm_2po_4pgr where clazz!=11',conn_gis)
print('Done!')

G_public = nx.from_pandas_edgelist(public,edge_attr=True)
G_driving = nx.from_pandas_edgelist(driving,edge_attr=True)
G_walking = nx.from_pandas_edgelist(walking,edge_attr=True)

#Get the outing data and restaurant data tables
outing_data = pd.read_sql('select cost,lat,long,name,rating,nearest_road_neighbour_osm_id from outing_data',conn_gis)
restaurant_data = pd.read_sql('select cost,lat,long,name,rating,nearest_road_neighbour_osm_id from singapore_restaurants_2',conn_gis)

#Get a set of end restaurant nodes and outing nodes
end_restaurant_nodes = set(restaurant_data['nearest_road_neighbour_osm_id'].unique())
end_outing_nodes = set(outing_data['nearest_road_neighbour_osm_id'].unique())

def check_if_still_filled(arr):
    arr = [bool(x) for x in arr]
    return True in arr

def convert_path_to_details(G,path):
    
    result = {'latitude':[],
              'longtitude':[]}
    for i in range(len(path)-1):
        result['latitude'].append(G[path[i]][path[i+1]]['x1'])
        result['longtitude'].append(G[path[i]][path[i+1]]['y1'])
    result['latitude'].append(G[path[-2]][path[-1]]['x2'])
    result['longtitude'].append(G[path[-2]][path[-1]]['y2'])
    
    return result

def check_if_valid_endpoint(meeting_type,end_osm_id):
    if meeting_type == 'Recreation' or meeting_type == 'Meeting':
        table = end_outing_nodes
    elif meeting_type == 'Food':
        table = end_restaurant_nodes
    if end_osm_id in table:
        return True
    else:
        return False
    
def check_in_all_sub_arr(arr,item):
    arr = [item in sub_arr for sub_arr in arr]
    return False not in arr


#Parameters
graphs = [G_public,G_walking,G_driving]
sources = [778256788,1118372124,1239287126]
weight = 'weight'
meeting_type = 'Recreation'

def get_edge_weight(v,u,e):
    return e['cost']



def find_central(graphs,sources,weight,cutoff=None,paths=None,pred=None):
    G_succs = [G._succ if G.is_directed() else G._adj for G in graphs]

    push = heappush
    pop = heappop
    dists = [{} for x in sources]  # dictionary of final distances
    seens = [{} for x in sources]
    paths = [{} for x in sources]
    # fringe is heapq with 3-tuples (distance,c,node)
    # use the count c to avoid comparing nodes (may not be able to)
    c = count()
    fringes = [[] for x in sources]
    for G,source,seen,fringe,path in zip(graphs,sources,seens,fringes,paths):
        if source not in G:
            raise nx.NodeNotFound("Source {} not in G".format(source))
        seen[source] = 0
        path[source] = [source]
        push(fringe, (0, next(c), source))
    while True:
        for i,(G_succ,fringe,dist,seen,path) in enumerate(zip(G_succs,fringes,dists,seens,paths)):
            (d, _, v) = pop(fringe)
            if v in dist:
                continue  # already searched this node.
            dist[v] = d
            other_dists = dists[:i] + dists[i+1 :]
            found = True
            for other_dist in other_dists:
                if v not in other_dist.keys():
                    found = False
                    continue
            if found:
                returned_seens = {}
                returned_paths = {}
                for counter,source in enumerate(sources):
#                    print(counter)
#                    print(source)
                    returned_seens[source] = seens[counter]
                    returned_paths[source] = paths[counter]
                return v,returned_seens,returned_paths
                
            for u, e in G_succ[v].items():
                cost = weight(v, u, e)
                if cost is None:
                    continue
                vu_dist = dist[v] + cost
                if cutoff is not None:
                    if vu_dist > cutoff:
                        continue
                if u in dist:
                    if vu_dist < dist[u]:
                        raise ValueError('Contradictory paths found:',
                                         'negative weights?')
                elif u not in seen or vu_dist < seen[u]:
                    seen[u] = vu_dist
                    push(fringe, (vu_dist, next(c), u))
                    if paths is not None:
                        paths[i][u] = paths[i][v] + [u]
                    if pred is not None:
                        pred[u] = [v]
                elif vu_dist == seen[u]:
                    if pred is not None:
                        pred[u].append(v)

    # The optional predecessor and path dictionaries can be accessed
    # by the caller via the pred and paths objects passed as arguments.
    
    
central_point,original_seens,original_paths = find_central(graphs,sources,get_edge_weight)
#Central point is 566720733

def closest_restaurant(G, sources, weight, pred=None, paths = None,
                          cutoff=None, meeting_type = 'Recreation'):

    G_succ = G._succ if G.is_directed() else G._adj
    
    push = heappush
    pop = heappop
    dist = {}  # dictionary of final distances
    seen = {}
    closest_5 = []
#    paths = {source: [source] for source in sources}
    # fringe is heapq with 3-tuples (distance,c,node)
    # use the count c to avoid comparing nodes (may not be able to)
    c = count()
    fringe = []
    for source in sources:
        if source not in G:
            raise nx.NodeNotFound("Source {} not in G".format(source))
        seen[source] = 0
        push(fringe, (0, next(c), source))
    while fringe:
        (d, _, v) = pop(fringe)
        if v in dist:
            continue  # already searched this node.
        dist[v] = d
        if check_if_valid_endpoint(meeting_type,v):
            closest_5.append(v)
            if len(closest_5)>=5:
                break
        for u, e in G_succ[v].items():
            cost = weight(v, u, e)
            if cost is None:
                continue
            vu_dist = dist[v] + cost
            if cutoff is not None:
                if vu_dist > cutoff:
                    continue
            if u in dist:
                if vu_dist < dist[u]:
                    raise ValueError('Contradictory paths found:',
                                     'negative weights?')
            elif u not in seen or vu_dist < seen[u]:
                seen[u] = vu_dist
                push(fringe, (vu_dist, next(c), u))
                if paths is not None:
                    paths[u] = paths[v] + [u]
                if pred is not None:
                    pred[u] = [v]
            elif vu_dist == seen[u]:
                if pred is not None:
                    pred[u].append(v)

    # The optional predecessor and path dictionaries can be accessed
    # by the caller via the pred and paths objects passed as arguments.
    return closest_5

start_time = time.time()
closest_restaurant(G_walking,[566720733],weight=get_edge_weight)
time_elapsed = time.time() - start_time
print(time_elapsed)



sources = [778256788,1118372124,1239287126]
restaurants = [2598017481, 5097279855, 1110900252, 5681549971, 4740582463]
start_time = time.time()
for source in sources:
    for restaurant in restaurants:
        nx.bidirectional_shortest_path(G_public,source,restaurant)
time_elapsed = time.time() - start_time
print(time_elapsed)

def get_routes(graphs,sources,weight,meeting_type,cutoff=None,paths=None,pred=None):
    start_time = time.time()
    central_point,original_seens,original_paths = find_central(graphs,sources,weight,cutoff,paths,pred)
    print('time taken for finding central point:',time.time()-start_time)
    start_time = time.time()
    closest_5 = closest_restaurant(G_public,[central_point],weight)
    print('time taken for finding closest 5:',time.time()-start_time)
    start_time = time.time()
    results = {restaurant:{} for restaurant in closest_5}
    for graph,source in zip(graphs,sources):
        for restaurant in closest_5:
            results[restaurant][source] = nx.bidirectional_shortest_path(graph,source,restaurant)
    print('time taken for results:',time.time()-start_time)
    return results
            
    
    
routes = get_routes([G_public,G_walking,G_driving],[778256788,1118372124,1239287126],get_edge_weight,'food')
