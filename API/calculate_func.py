#--------------------------------------REQUIREMENTS--------------------------------------


from flask import jsonify
import psycopg2
import pandas as pd
import json
import time
from heapq import heappush, heappop
from networkx import NetworkXError
from itertools import count

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
public_xy_id = pd.read_sql('select DISTINCT(source),x1,y1 from public_edges',conn_gis)
driving_xy_id = pd.read_sql('select DISTINCT(osm_source_id) as source,x1,y1 from osm_2po_4pgr', conn_gis)
walking_xy_id = pd.read_sql('SELECT  DISTINCT(osm_source_id) as source,x1,y1 FROM osm_2po_4pgr where clazz!=11', conn_gis)

public = pd.read_sql('select source,target,x1,y1,x2,y2,cost,reverse_cost from public_edges',conn_gis)
driving = pd.read_sql('SELECT  osm_source_id as source, osm_target_id as target, cost, reverse_cost,x1,y1,x2,y2 FROM osm_2po_4pgr',conn_gis)
walking = pd.read_sql('SELECT  osm_source_id as source, osm_target_id as target, cost*kmh/5 as cost, reverse_cost*kmh/5 as reverse_cost,x1,y1,x2,y2 FROM osm_2po_4pgr where clazz!=11',conn_gis)
public['transport_type'] = 'public'
driving['transport_type'] = 'driving'
walking['transport_type'] = 'walking'

#Lets use networkx like normal human beings
import networkx as nx
G_public = nx.from_pandas_edgelist(public,edge_attr=True)
G_driving = nx.from_pandas_edgelist(driving,edge_attr=True)
G_walking = nx.from_pandas_edgelist(walking,edge_attr=True)

    

def get_closest_node(transport_mode,long,lat):
    if transport_mode == 'Public Transit':
        ref_df = public_xy_id
        closeness_df = pd.DataFrame({'node':public_xy_id['source']})
    elif transport_mode == 'Walk':
        ref_df = walking_xy_id
        closeness_df = pd.DataFrame({'node':public_xy_id['source']})
    elif transport_mode == 'Driving':
        ref_df = driving_xy_id
        closeness_df = pd.DataFrame({'node':public_xy_id['source']})
    x_diff = ref_df['x1'] - float(long)
    y_diff = ref_df['y1'] - float(lat)
    closeness_df['node_distances'] = x_diff.pow(2) + y_diff.pow(2)
    return(closeness_df[closeness_df['node_distances'] == closeness_df['node_distances'].min()]['node'].values[0])

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

def check_if_valid_endpoint(meeting_type,end_osm_id):
    if meeting_type == 'Recreation' or meeting_type == 'Meeting':
        table = outing_data
    elif meeting_type == 'Food':
        table = restaurant_data
    if end_osm_id in table['nearest_road_neighbour_osm_id']:
        return True
    else:
        return False
        
    
    
def multi_start_point_dijkstra(graphs, sources, weight = 'weight',meeting_type = 'Recreation'):
    #Make the functions for pushing and popping onto the ordered array
    push = heappush
    pop = heappop
    dists = [{} for source in sources] #Distance from source to that node
    paths = [{source : [source]} for source in sources] #sequence of steps of start to that node
    fringe = [[] for source in sources]
    seen = [{source: 0} for source in sources]
    #Get the 5 best results
    top_5 = []
    
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
        #Choose a node to continue from
        for dir in range(len(sources)):
            G = graphs[dir]
            #extract closest to expand
            (dist, _, v) = pop(fringe[dir])
            if v in dists[dir]:
                #shortest path to v has already been found
                continue
            #update distance
            dists[dir][v] = dist
            if check_in_all_sub_arr(dists,v):
                #Check if the point found is a meeting point
                if check_if_valid_endpoint(meeting_type,v):
                    #Convert it to the correct format
                    points_dict = {path[0]:convert_path_to_details(G,path) for G,path in zip(graphs,finalpath)}
                    top_5.append((finaldist,points_dict))
                    if len(top_5) >= 5:
                        return top_5
            
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

def calculate_v2(session_id):
    ###Check the OAuth details

    #Get all the meetup details\
    section_start_time = time.time()

    crsr = conn.cursor()
    crsr.execute("SELECT info FROM sessions WHERE session_id = '{}'".format(session_id))
    info = crsr.fetchone()
    if info != None:
        ###Calculate the best route for each person and return it
        user_osms = []
        user_identifiers = []
        user_details = {}
        for user in info[0]['users']:
            #Get the closest node using the closest node function
            osm_id = get_closest_node(user['transport_mode'],user['long'],user['lat'])
            user_details[osm_id] = {"latitude":user['lat'],"longtitude":user['long']}
            user_osms.append(osm_id)
            user_identifiers.append(user.get('username',user.get('identifier','unknown user')))
        # print(user_osms
        user_array = "ARRAY["+','.join(str(user_osm) for user_osm in user_osms)+"]::bigint[]"
        # set the meeting type
        if info[0]['meeting_type'] == 'food':
            location_db = "singapore_restaurants_2"
        elif info[0]['meeting_type'] == 'outing':
            location_db = "outing_data"

        #Get route

        print('Get User Closest Node -', time.time() - section_start_time)
        
        

calculate_v2('c72c7d0c-0661-11ea-bd0a-b4d5bde4ce00') #0.1585+19 seconds

start = time.time()
print(astar_path(G_public,778256788,1118372124,heuristic = heuristic))
print('took',time.time()-start)
start = time.time()
print(astar_path(G_public,778256788,1118372124,heuristic = None))
print('took',time.time()-start)
x = multi_start_point_dijkstra([G_public,G_walking,G_driving], [778256788,1118372124,1239287126], weight = 'weight')




