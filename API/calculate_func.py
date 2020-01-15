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

#def calculate(session_id):
#    ###Check the OAuth details
#
#    #Get all the meetup details\
#    section_start_time = time.time()
#
#    crsr = conn.cursor()
#    crsr.execute("SELECT info FROM sessions WHERE session_id = '{}'".format(session_id))
#    info = crsr.fetchone()
#    if info != None:
#        ###Calculate the best route for each person and return it
#        user_osms = []
#        user_identifiers = []
#        user_details = {}
#        for user in info[0]['users']:
#            print(user)
#            #Get the osm_id closest to the user's location
#            crsr_gis.execute("SELECT osm_source_id as osm_id FROM osm_2po_4pgr\
#                ORDER BY sqrt((x1-"+str(user['long'])+")^2 + (y1-"+str(user['lat'])+")^2) \
#            LIMIT 1")
#            osm_id = crsr_gis.fetchone()[0]
#            user_details[osm_id] = {"latitude":user['lat'],"longtitude":user['long']}
#            user_osms.append(osm_id)
#            user_identifiers.append(user.get('username',user.get('identifier','unknown user')))
#        # print(user_osms)
#        user_array = "ARRAY["+','.join(str(user_osm) for user_osm in user_osms)+"]::bigint[]"
#        # set the meeting type
#        if info[0]['meeting_type'] == 'food':
#            location_db = "singapore_restaurants_2"
#        elif info[0]['meeting_type'] == 'outing':
#            location_db = "outing_data"
#
#        #Get route
#
#        print('Get User Closest Node -', time.time() - section_start_time)
#        section_start_time = time.time()
#
#        #Get the driving results
#        results = pd.read_sql("with results as (\
#                    select \
#                        results.*,osm_2po_4pgr.geom_way,osm_2po_4pgr.x1,osm_2po_4pgr.y1\
#                    from\
#                            ((SELECT \
#                                *				 \
#                            FROM pgr_dijkstra(\
#                            'select * from public_edges',\
#                            "+user_array+",\
#                            ARRAY(select nearest_road_neighbour_osm_id from "+location_db+")))\
#                        as results\
#                    join "+location_db+"\
#                        on results.end_vid = "+location_db+".nearest_road_neighbour_osm_id) as results\
#                    join\
#                        osm_2po_4pgr on results.node = osm_2po_4pgr.osm_source_id\
#                ), best_places as (\
#                    select start_vid,end_vid,sum(agg_cost) over (partition by end_vid) as total_cost from results where edge = -1 order by total_cost limit 5*cardinality("+user_array+")\
#                )\
#\
#                select \
#                    path_seq,\
#                    results.start_vid as start_user,\
#                    agg_cost as cost_for_user,\
#                    total_cost,\
#                    name,\
#                    results.end_vid,\
#                    x1 as longtitude,\
#                    y1 as latitude,\
#                    ST_X(way) as restaurant_x,\
#                    ST_Y(way) as restaurant_y\
#                from\
#                    results\
#                    inner join\
#                    best_places\
#                    on results.end_vid = best_places.end_vid and results.start_vid = best_places.start_vid",conn_gis)
#
#        print('Perform optimisation -', time.time() - section_start_time)
#        section_start_time = time.time()
#
#
#        osm_id_to_name_dict = dict(zip(user_osms,user_identifiers))
#        #Replace the osm ids in results with the user's names
#        results['start_user_name'] = pd.Series(osm_id_to_name_dict[row['start_user']] for index,row in results.iterrows())
#        #Format the results in dictionaries
#        results_dict = {}
#        results_dict['possible_locations'] = results['name'].unique().tolist()
#        results_dict['users'] = user_details
#        # print('results_dict:')
#        # print(results_dict)
#        # print('results:')
#        # print(results)
#
#        for location in results_dict['possible_locations']:
#            results_dict[location] = {}
#            for user in results_dict['users']:
#                try:
#                    # print('location:')
#                    # print(location)
#                    # print('user:')
#                    # print(user)
#
#                    relevant_df = results[results['start_user'] == user][results['name'] == location].set_index('path_seq')
#                    relevant_df.sort_values('path_seq',inplace = True)
#
#                    # print('relevant_df:')
#                    # print(relevant_df)
#
#
#                    #Make a dictionary for each use
#                    results_dict[location][user] = {}
#                    results_dict[location][user]['latitude'] = relevant_df['latitude'].values.tolist()
#                    results_dict[location][user]['longtitude'] = relevant_df['longtitude'].values.tolist()
#                    # results_dict[location][user] = relevant_df[['latitude','longtitude']].to_dict()
#                    results_dict[location][user]['total_cost'] = str(relevant_df['total_cost'].iloc[0])
#                    results_dict[location][user]['end_vid'] = str(relevant_df['end_vid'].iloc[0])
#                    results_dict[location][user]['start_user'] = str(relevant_df['start_user'].iloc[0])
#                    results_dict[location][user]['start_user_name'] = str(relevant_df['start_user_name'].iloc[0])
#                    results_dict[location][user]['restaurant_x'] = relevant_df['restaurant_x'].iloc[0]
#                    results_dict[location][user]['restaurant_y'] = relevant_df['restaurant_y'].iloc[0]
#                except:
#                    print('WARNING: exception on location',location,'user',user)
#            
#
#        
#        #Split dataframe by user
#        
#        results = json.dumps(results_dict)
#        crsr = conn.cursor()
#        crsr.execute("UPDATE sessions SET results=%s WHERE session_id =%s",(results,session_id))
#        conn.commit()
#        print('Update Tables, etc -', time.time() - section_start_time)
#        return results
#    else:
#        return jsonify({'error':'sesson_id or username is wrong'})
    


#calculate('c72c7d0c-0661-11ea-bd0a-b4d5bde4ce00') #12+19 seconds
print('Getting Databases')
public_xy_id = pd.read_sql('select DISTINCT(source),x1,y1 from public_edges',conn_gis)
driving_xy_id = pd.read_sql('select DISTINCT(osm_source_id) as source,x1,y1 from osm_2po_4pgr', conn_gis)
walking_xy_id = pd.read_sql('SELECT  DISTINCT(osm_source_id) as source,x1,y1 FROM osm_2po_4pgr where clazz!=11', conn_gis)

public = pd.read_sql('select source,target,x1,y1,x2,y2,cost,reverse_cost from public_edges',conn_gis)
driving = pd.read_sql('SELECT  osm_source_id as source, osm_target_id as target, cost, reverse_cost,x1,y1,x2,y2 FROM osm_2po_4pgr',conn_gis)
walking = pd.read_sql('SELECT  osm_source_id as source, osm_target_id as target, cost*kmh/5 as cost, reverse_cost*kmh/5 as reverse_cost,x1,y1,x2,y2,closest_outing_node,closest_restaurant_node  FROM osm_2po_4pgr where clazz!=11',conn_gis)
print('Done!')

public['transport_type'] = 'public'
driving['transport_type'] = 'driving'
walking['transport_type'] = 'walking'

#Lets use networkx like normal human beings
import networkx as nx
G_public = nx.from_pandas_edgelist(public,edge_attr=True)
G_driving = nx.from_pandas_edgelist(driving,edge_attr=True)
G_walking = nx.from_pandas_edgelist(walking,edge_attr=True)

def get_closest_node_v2(ref_df,long,lat,x1_name='x1',y1_name='y1'):
    closeness_df = pd.DataFrame({'node':public_xy_id['source']})
    x_diff = ref_df[x1_name] - float(long)
    y_diff = ref_df[y1_name] - float(lat)
    closeness_df['node_distances'] = x_diff.pow(2) + y_diff.pow(2)
    return(closeness_df[closeness_df['node_distances'] == closeness_df['node_distances'].min()]['node'].values[0])


def get_closest_node(transport_mode,long,lat):
    if transport_mode == 'Public Transit':
        ref_df = public_xy_id
    elif transport_mode == 'Walk':
        ref_df = walking_xy_id
    elif transport_mode == 'Driving':
        ref_df = driving_xy_id
    return get_closest_node_v2(ref_df,long,lat)   
   

def heuristic(G, u, v):
    #Get current x1 y1
    targ = next(iter(G[u].values()))
    dest = next(iter(G[v].values()))
    
    return ((targ['x2']-dest['x2'])**2 + (targ['y2']-dest['y2'])**2)**0.5

def heuristic2(u,v):
    (x1,y1) = u
    (x2,y2) = v
    return (x1-x2)**2+(y1+y2)**2

def astar_path(G, source, target, heuristic=None, weight='weight'):
    if G.is_multigraph():
        raise NetworkXError("astar_path() not implemented for Multi(Di)Graphs")

    if heuristic is None:
        # The default heuristic is h=0 - same as Dijkstra's algorithm
        def heuristic(G, u, v):
            return 0

    push = heappush
    pop = heappop

    # The queue stores priority, node, cost to reach, and parent.
    # Uses Python heapq to keep in priority order.
    # Add a counter to the queue to prevent the underlying heap from
    # attempting to compare the nodes themselves. The hash breaks ties in the
    # priority and is guarenteed unique for all nodes in the graph.
    c = count()
    queue = [(0, next(c), source, 0, None)]

    # Maps enqueued nodes to distance of discovered paths and the
    # computed heuristics to target. We avoid computing the heuristics
    # more than once and inserting the node into the queue too many times.
    enqueued = {}
    # Maps explored nodes to parent closest to the source.
    explored = {}
    loops = 0
    while queue:
        loops += 1
        # Pop the smallest item from queue.
        _, __, curnode, dist, parent = pop(queue)

        if curnode == target:
            path = [curnode]
            node = parent
            while node is not None:
                path.append(node)
                node = explored[node]
            path.reverse()
            print('algorithm did',loops,'loops')
            return path

        if curnode in explored:
            continue

        explored[curnode] = parent

        for neighbor, w in G[curnode].items():
            if neighbor in explored:
                continue
            ncost = dist + w.get(weight, 1)
            if neighbor in enqueued:
                qcost, h = enqueued[neighbor]
                # if qcost < ncost, a longer path to neighbor remains
                # enqueued. Removing it would need to filter the whole
                # queue, it's better just to leave it there and ignore
                # it when we visit the node a second time.
                if qcost <= ncost:
                    continue
            else:
                h = heuristic(G, neighbor, target)
            enqueued[neighbor] = ncost, h
            push(queue, (ncost + h, next(c), neighbor, ncost, curnode))

    raise nx.NetworkXNoPath("Node %s not reachable from %s" % (source, target))
    
def convert_path_to_details(G,path):
    
    result = {'latitude':[],
              'longtitude':[]}
    for i in range(len(path)-1):
        result['latitude'].append(G[path[i]][path[i+1]]['x1'])
        result['longtitude'].append(G[path[i]][path[i+1]]['y1'])
    result['latitude'].append(G[path[-2]][path[-1]]['x2'])
    result['longtitude'].append(G[path[-2]][path[-1]]['y2'])
    
    return result

#Get the outing data and restaurant data tables
outing_data = pd.read_sql('select cost,lat,long,name,rating,nearest_road_neighbour_osm_id from outing_data',conn_gis)
restaurant_data = pd.read_sql('select cost,lat,long,name,rating,nearest_road_neighbour_osm_id from singapore_restaurants_2',conn_gis)

from tqdm import tqdm
tqdm.pandas()

import os
os.chdir('D:/Documents/UROP WITH FRIENDS/Meetup App/API')

def get_closest_nodes():
    #Make outing data column for closest node based on lat and long
    closest_outing_node = walking.progress_apply(lambda x: get_closest_node_v2(outing_data,x['x2'],x['y2'],x1_name='long',y1_name='lat'), axis=1)
    closest_outing_node.to_csv('closest_outing_node.csv')
    closest_restaurant_node = walking.progress_apply(lambda x: get_closest_node_v2(restaurant_data,x['x2'],x['y2'],x1_name='long',y1_name='lat'), axis=1)
    closest_restaurant_node.to_csv('closest_restaurant_node.csv')
    
    walking['closest_outing_node'] = closest_outing_node
    walking['closest_restaurant_node'] = closest_restaurant_node
    
    closest_nodes_df = walking[['closest_outing_node','closest_restaurant_node','target']]
    closest_nodes_df = closest_nodes_df.drop_duplicates()
    
    closest_nodes_df.to_sql('closest_outing_rest_nodes',engine)

#Import the closest outing nodes table
closest_nodes_df = pd.read_sql('select * from closest_outing_rest_nodes',conn_gis)

#Get a set of end restaurant nodes and outing nodes
end_restaurant_nodes = set(restaurant_data['nearest_road_neighbour_osm_id'].unique())
end_outing_nodes = set(outing_data['nearest_road_neighbour_osm_id'].unique())

def get_closest_valid_node(meeting_type,v):
    result_df = closest_nodes_df[closest_nodes_df['target'] == v]
    if meeting_type == 'Recreation' or meeting_type == 'Meeting':
        slice_string = 'closest_outing_node'
    elif meeting_type == 'Food':
        slice_string = 'closest_restuarant_node'
    return result_df[slice_string].iloc[0]
        
sns.set()
Vsout = []

def multi_start_point_dijkstra(graphs, sources, weight = 'weight',meeting_type = 'Recreation'):
    #Make the functions for pushing and popping onto the ordered array
    
    push = heappush
    pop = heappop
    visited_counter = {}
    dists = [{} for source in sources] #Distance from source to that node
    paths = [{source : [source]} for source in sources] #sequence of steps of start to that node
    fringe = [[] for source in sources]
    seen = [{source: 0} for source in sources]
    #Get the 5 best results
    top_5 = []
#    current_endnodes = []
    
    c = count()
    #Initialise fringe heap
    for i,source in enumerate(sources):
        push(fringe[i],(0,next(c),source))
    #neighs for extracting correct neighbor information
    neighs = [G.neighbors for G,source in zip(graphs,sources)]
    finaldist = 1e30000
    finalpath = [[] for source in sources]
    loops = 0
    while check_if_still_filled(fringe):
        loops+=1
        if loops%100 == 0:
            print(loops)
        #Choose a node to continue from
        for dir in range(len(sources)):
            G = graphs[dir]
            #extract closest to expand
            (dist, _, v) = pop(fringe[dir])
            if v not in visited_counter:
                visited_counter[v] = 1
            else:
                visited_counter[v] += 1
            if visited_counter[v] == 3:
#                return(finaldist,finalpath)
                #Check if the point found is a meeting point
#                endpoint_checks += 1
#                print(endpoint_checks)
#                if check_if_valid_endpoint(meeting_type,v):
                    #Convert it to the correct format
#                new_end_node = get_closest_valid_node(meeting_type,v)
#                print(new_end_node)
#                print(v)
#                    current_endnodes.append(get_closest_valid_node(meeting_type,v))
                points_dict = {path[0]:convert_path_to_details(G,path) for G,path in zip(graphs,finalpath)}
                top_5.append((finaldist,points_dict))
                if len(top_5) >= 5:
                    return top_5
            if v in dists[dir]:
                #shortest path to v has already been found
                continue
            #update distance
            dists[dir][v] = dist
            
            
            for w in neighs[dir](v):
                if G.is_multigraph():
                    minweight = min((dd.get(weight,1)
                                for k, dd in G[v][w].items()))
                else:
                    minweight = G[v][w].get(weight,1)
                    
                vwLength = dists[dir][v] + minweight
                
                if w in dists[dir]:
                    if vwLength < dists[dir][w]:
                        raise ValueError(
                                "Contradictory paths found: negative weights?")
                
                elif w not in seen[dir] or vwLength < seen[dir][w]:
                    #relaxing
                    seen[dir][w] = vwLength
                    push(fringe[dir],(vwLength,next(c),w))
                    paths[dir][w] = paths[dir][v] + [w]
                    if check_in_all_sub_arr(seen,w):
                        #See if this path is better than the already discovered 
                        #shortest path
                        totaldist = sum(seen[i][w] for i,_ in enumerate(sources))
                        if finalpath == [] or finaldist > totaldist:
                            finaldist = totaldist
                            finalpath = [paths[i][w] for i,_ in enumerate(sources)]
    raise nx.NetworkXNoPath("No meeting point found")
    


                        
def check_if_valid_endpoint(meeting_type,end_osm_id):
    if meeting_type == 'Recreation' or meeting_type == 'Meeting' or meeting_type == 'recreation' or meeting_type == 'meeting':
        table = end_outing_nodes
    elif meeting_type == 'Food' or meeting_type == 'food':
        table = end_restaurant_nodes
    if end_osm_id in table:
        return True
    else:
        return False
            
    
def check_if_still_filled(arr):
    arr = [bool(x) for x in arr]
    return True in arr

def check_in_all_sub_arr(arr,item):
    arr = [item in sub_arr for sub_arr in arr]
    return False not in arr

def check_in_except_index(arr,item,idx):
    for i, sub_arr in enumerate(arr):
        if i == idx:
            continue
        if item in sub_arr:
            return True
    return False

def closest_relevant(G, sources, weight, pred=None, paths = None,
                          cutoff=None, meeting_type = 'food'):

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

def get_routes(graphs,sources,weight,meeting_type,cutoff=None,paths=None,pred=None):
    start_time = time.time()
    central_point,original_seens,original_paths = find_central(graphs,sources,weight,cutoff,paths,pred)
    print('time taken for finding central point:',time.time()-start_time)
    start_time = time.time()
    closest_5 = closest_relevant(G_public,[central_point],weight,meeting_type = meeting_type)
    print('time taken for finding closest 5:',time.time()-start_time)
    start_time = time.time()
    results = {restaurant:{} for restaurant in closest_5}
    for graph,source in zip(graphs,sources):
        for restaurant in closest_5:
            results[restaurant][source] = nx.bidirectional_shortest_path(graph,source,restaurant)
    print('time taken for results:',time.time()-start_time)
    return results

def get_relevant_graph(transport_mode):
    if transport_mode == 'Public Transit':
        G = G_public
    elif transport_mode == 'Walk':
        G = G_walking
    elif transport_mode == 'Driving':
        G = G_driving
    return G

def get_restaurant_name_from_node(node_id):
    return restaurant_data[restaurant_data['nearest_road_neighbour_osm_id'] == node_id]['name'].unique()

import numpy as np

def get_lat_long_from_id_array(id_array):
    latlongs = np.transpose([driving[driving['source'] == id][['x1','y1']].values[0] for id in id_array])
    return latlongs



def calculate_v2(session_id):
    ###Check the OAuth details

    #Get all the meetup details\
    section_start_time = time.time()

    crsr = conn.cursor()
    crsr.execute("SELECT info FROM sessions WHERE session_id = '{}'".format(session_id))
    info = crsr.fetchone()
    if info != None:
        function_start = time.time()
        ###Calculate the best route for each person and return it
        user_osms = []
        user_identifiers = []
        user_details = {}
        users = info[0]['users']
        for user in users:
            #Get the closest node using the closest node function
            osm_id = get_closest_node(user['transport_mode'],user['long'],user['lat'])
            user_details[osm_id] = {"latitude":user['lat'],"longtitude":user['long']}
            user_osms.append(osm_id)
            user_identifiers.append(user.get('username',user.get('identifier','unknown user')))
        # set the meeting type
        meeting_type = info[0]['meeting_type']
        if meeting_type == 'food':
            location_db = "singapore_restaurants_2"
        elif meeting_type == 'outing':
            location_db = "outing_data"
        print('Get User Closest Node -', time.time() - section_start_time)
        #Get route
        routes = get_routes([get_relevant_graph(user['transport_mode']) for user in users],user_osms,get_edge_weight,meeting_type)
        results = {}
        for restaurant,user_routes in routes.items():
            for user, route in user_routes.items():
                restaurant_names = get_restaurant_name_from_node(restaurant)
                if restaurant_names is None:
                    print('Warning: No restaurant at node',restaurant)
                    continue
                user_osm = user
                end_vid = restaurant
                lat,long = get_lat_long_from_id_array(route)
                for restaurant_name in restaurant_names:
                    if restaurant_name not in results:
                        results[str(restaurant_name)] = {}
                    results[restaurant_name][int(user_osm)] = {}
                    results[restaurant_name][int(user_osm)]['end_vid'] = str(end_vid)
                    results[restaurant_name][int(user_osm)]['latitude'] = list(lat)
                    results[restaurant_name][int(user_osm)]['longtitude'] = list(long)
        print('Total time elapsed', time.time() - function_start)
        return json.dumps(results)
        


results = calculate_v2('c72c7d0c-0661-11ea-bd0a-b4d5bde4ce00') #0.1585+19 seconds

#start = time.time()
#print(astar_path(G_public,778256788,1118372124,heuristic = heuristic))
#print('took',time.time()-start)
#start = time.time()
#print(astar_path(G_public,778256788,1118372124,heuristic = None))
#print('took',time.time()-start)

print(check_if_valid_endpoint("Recreation",6480133490))
x = multi_start_point_dijkstra([G_public,G_walking,G_driving], [778256788,1118372124,1239287126], weight = 'weight', meeting_type = 'Food')

recreation_and_visited = end_outing_nodes.intersection(visited_counter.keys())
visited_3_times = []
for key in recreation_and_visited:
    if visited_counter[key] == 3:
        visited_3_times.append(key)


print(5798036017 in Vsout)
