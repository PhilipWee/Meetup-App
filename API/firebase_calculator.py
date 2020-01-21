

#--------------------------------------REQUIREMENTS--------------------------------------
from flask import Flask,jsonify,request,abort, redirect, url_for,render_template
from flask_dance.contrib.github import make_github_blueprint, github
from flask_cors import CORS
import psycopg2
import sys, os
import numpy as np
import pandas as pd
import credentials as creds
import pandas.io.sql as psql
import json
import time
import uuid
import datetime
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import pprint
#--------------------------------------REQUIREMENTS--------------------------------------

#--------------------------------------SETTINGS--------------------------------------
NUMBER_OF_RESULTS = 20
#--------------------------------------SETTINGS--------------------------------------

#--------------------------------------CONNECT TO FIREBASE-------------------------------
print('Connecting to firebase')
if (not len(firebase_admin._apps)):

    # Use the application default credentials
    # Use a service account
    cred = credentials.Certificate('D:/Documents/UROP WITH FRIENDS/Meetup App Confidential/meetup-mouse-265200-2bcf88fc79cc.json')
    firebase_admin.initialize_app(cred)
    db = firestore.client()
else:
    db = firestore.client()
print('Connected!')
#--------------------------------------CONNECT TO FIREBASE-------------------------------

#--------------------------------------CONNECT TO DATABASE-------------------------------
# Set up a connection to the postgres server.
try:
    print("Connecting to the postgres server")
    conn_string = "host="+ creds.PGHOST +" port="+ "5432" +" dbname="+ creds.PGDATABASE +" user=" + creds.PGUSER \
    +" password="+ creds.PGPASSWORD
    conn=psycopg2.connect(conn_string)
    print("Connected!")
    crsr = conn.cursor()
    #Set up a connection to gisdb, the routing database
    print("Connecting to routing database")
    conn_string = "host="+ creds.PGHOST +" port="+ "5432" +" dbname="+ creds.PGROUTINGDATABASE +" user=" + creds.PGUSER \
    +" password="+ creds.PGPASSWORD
    conn_gis=psycopg2.connect(conn_string)
    print("Connected!")
    crsr_gis = conn_gis.cursor()
except:
    creds.PGHOST = 'journey'
    print("Connecting to the postgres server")
    conn_string = "host="+ creds.PGHOST +" port="+ "5432" +" dbname="+ creds.PGDATABASE +" user=" + creds.PGUSER \
    +" password="+ creds.PGPASSWORD
    conn=psycopg2.connect(conn_string)
    print("Connected!")
    crsr = conn.cursor()
    #Set up a connection to gisdb, the routing database
    print("Connecting to routing database")
    conn_string = "host="+ creds.PGHOST +" port="+ "5432" +" dbname="+ creds.PGROUTINGDATABASE +" user=" + creds.PGUSER \
    +" password="+ creds.PGPASSWORD
    conn_gis=psycopg2.connect(conn_string)
    print("Connected!")
    crsr_gis = conn_gis.cursor()
#--------------------------------------CONNECT TO DATABASE-------------------------------

def get_doc_ref_for_id(session_id):
    session_id = str(session_id)
    return db.collection(u'sessions').document(session_id)

def insert_user_details(details,session_id):
    try:
        doc_ref = get_doc_ref_for_id(session_id)
        doc_dict = doc_ref.get().to_dict()
        doc_dict['info']['users'].append(details)
        doc_ref.set(doc_dict)
    except:
        print('Error inserting user details, does session id exist?')

def get_details_for_session_id(session_id):
    try:
        doc_ref = get_doc_ref_for_id(session_id)
        return doc_ref.get().to_dict()['info']
    except:
        print('Error getting user details, does session id exist?')
        return 'Error'

def check_requires_calculation():
    ids_that_need_calc = []
    for sess in db.collection(u'sessions').stream():
        try:
            if sess.get('calculate') == True or sess.get('calculate') == 'True':
                ids_that_need_calc.append(sess.id)
        except:
            continue
    return ids_that_need_calc


def check_calculate_done(session_id):
    try:
        doc_ref = get_doc_ref_for_id(session_id)
        doc_dict = doc_ref.get().to_dict()
        if doc_dict['calculate'] is not None:
            if doc_dict['calculate'] == 'Done':
                return True
            else:
                return False
        else:
            return 'not_started'
    except:
        return 'Error'

#The info is a dictionary
def calculate(sess_id,info):
    ###Check the OAuth details

    #Get all the meetup details\
    section_start_time = time.time()

    info = [info]

    if info != None:
        ###Calculate the best route for each person and return it
        user_osms = []
        user_identifiers = []
        user_details = {}
        quality_array = []
        speed_array = []
        price_array = []
        for user in info[0]['users']:
#            print(user)
            #Get the osm_id closest to the user's location
            crsr_gis.execute("SELECT osm_source_id as osm_id FROM osm_2po_4pgr\
                ORDER BY sqrt((x1-"+str(user['long'])+")^2 + (y1-"+str(user['lat'])+")^2) \
            LIMIT 1")
            osm_id = crsr_gis.fetchone()[0]
            user_details[osm_id] = {"latitude":user['lat'],"longtitude":user['long']}
            user_details[osm_id].update(user)
            user_osms.append(osm_id)
            user_identifiers.append(user.get('username',user.get('identifier','unknown user')))
            quality_array.append(user['metrics']['quality'])
            speed_array.append(user['metrics']['speed'])
            if 'price' in user['metrics'].keys():
                price_array.append(user['metrics']['price'])
        
        max_price = max(price_array, default = 5)
        min_price = min(price_array, default = 0)
        min_rating = np.mean(quality_array)
        max_travel_time_diff = (6 - np.mean(speed_array)) * 5/60
        
        pprint.pprint(user_details)
        
        #Get the user arrays
        user_public_osms = [user_detail_key for user_detail_key in user_details.keys() if user_details[user_detail_key]['transport_mode'] == 'Public Transit' or user_details[user_detail_key]['transport_mode'] == 'public']
        user_public_array = "ARRAY["+','.join(str(user_osm) for user_osm in user_public_osms)+"]::bigint[]"
        
        user_driving_osms = [user_detail_key for user_detail_key in user_details.keys() if user_details[user_detail_key]['transport_mode'] == 'Driving' or user_details[user_detail_key]['transport_mode'] == 'driving']
        user_driving_array = "ARRAY["+','.join(str(user_osm) for user_osm in user_driving_osms)+"]::bigint[]"
        
        user_walking_osms = [user_detail_key for user_detail_key in user_details.keys() if user_details[user_detail_key]['transport_mode'] == 'Walking' or user_details[user_detail_key]['transport_mode'] == 'walking' or user_details[user_detail_key]['transport_mode'] == 'Walk']
        user_walking_array = "ARRAY["+','.join(str(user_osm) for user_osm in user_walking_osms)+"]::bigint[]"
        
        # set the meeting type
        if info[0]['meeting_type'] == 'food':
            location_db = "singapore_restaurants_2"
        elif info[0]['meeting_type'] == 'outing':
            location_db = "outing_data"
        
        #Get the number of users
        number_of_users = len(info[0]['users'])

        #Get route

        print('Get User Closest Node -', time.time() - section_start_time)
        section_start_time = time.time()
        
        params_dict = {'max_price': max_price,
                       'min_price' : min_price,
                       'min_rating' : min_rating,
                       'max_travel_time_diff' : max_travel_time_diff,
                       'location_db' : location_db,
                       'user_public_array': user_public_array,
                       'user_driving_array':user_driving_array,
                       'user_walking_array': user_walking_array,
                       'number_of_results':NUMBER_OF_RESULTS,
                       'number_of_users':number_of_users}
        
        #Create the string for public, driving and walking
        dijkstra_string = ""
        if len(user_public_osms) > 0:
            dijkstra_string += """SELECT *,
                            {location_db}.cost AS price
                     FROM   (
                                   SELECT *
						 --public
                                   FROM   pgr_dijkstra( 'select id,source,target,x1,y1,x2,y2,cost,reverse_cost from public_edges', {user_public_array}, array
                                          (
                                                 SELECT nearest_road_neighbour_osm_id
                                                 FROM   {location_db}))) AS results
                     JOIN   {location_db}
                     ON     results.end_vid = {location_db}.nearest_road_neighbour_osm_id""".format(**params_dict)
        
        if len(user_public_osms) > 0 and len(user_driving_osms) > 0:
            dijkstra_string += " UNION \n"
            
        if len(user_driving_osms) > 0:
            dijkstra_string += """SELECT *,
                            {location_db}.cost AS price
                     FROM   (
                                   SELECT *
						 --driving
                                   FROM   pgr_dijkstra( 'SELECT  osm_id as id,osm_source_id as source, osm_target_id as target, cost, reverse_cost,x1,y1,x2,y2 FROM osm_2po_4pgr', {user_driving_array}, array
                                          (
                                                 SELECT nearest_road_neighbour_osm_id
                                                 FROM   {location_db}))) AS results
                     JOIN   {location_db}
                     ON     results.end_vid = {location_db}.nearest_road_neighbour_osm_id""".format(**params_dict)
        
        if len(user_driving_osms) > 0 and len(user_walking_osms) > 0:
            dijkstra_string += " UNION \n"
        
        if len(user_walking_osms) > 0:
            dijkstra_string += """SELECT *,
		   				--walking
                            {location_db}.cost AS price
                     FROM   (
                                   SELECT *
                                   FROM   pgr_dijkstra( 'SELECT  osm_id as id,osm_source_id as source, osm_target_id as target, cost*kmh/6.5 as cost, reverse_cost*kmh/5 as reverse_cost,x1,y1,x2,y2,closest_outing_node,closest_restaurant_node  FROM osm_2po_4pgr where clazz!=11', {user_walking_array}, array
                                          (
                                                 SELECT nearest_road_neighbour_osm_id
                                                 FROM   {location_db}))) AS results
                     JOIN   {location_db}
                     ON     results.end_vid = {location_db}.nearest_road_neighbour_osm_id""".format(**params_dict)
        
        params_dict['dijkstra_string'] = dijkstra_string
        
#        print("""WITH results AS
#(
#       SELECT results.*,
#              osm_2po_4pgr.geom_way,
#              osm_2po_4pgr.x1,
#              osm_2po_4pgr.y1
#       FROM   (
#                     {dijkstra_string}
#	   
#	   )
#	
#	AS results
#       JOIN   osm_2po_4pgr
#       ON     results.node = osm_2po_4pgr.osm_source_id ), best_places AS
#(
#         SELECT   *
#         FROM    (
#                         SELECT place_id,
#                                sum(agg_cost) OVER (partition BY end_vid) AS total_cost,
#                                max(agg_cost) OVER (partition BY end_vid) AS max_travel_time,
#                                min(agg_cost) OVER (partition BY end_vid) AS min_travel_time
#                         FROM   (
#                                       SELECT *
#                                       FROM   results
#                                       WHERE  price != 'None') results
#                         WHERE  edge = -1
#                         AND    cast (price AS integer) <= {max_price}
#                         AND    cast (price AS integer) >= {min_price}
#                         AND    rating > {min_rating} ) results
#         WHERE    max_travel_time   - min_travel_time < {max_travel_time_diff}
#         ORDER BY total_cost limit {number_of_results}*{number_of_users} )
#SELECT     path_seq,
#           results.start_vid AS start_user,
#           agg_cost          AS cost_for_user,
#           total_cost,
#           NAME,
#           results.end_vid,
#           geom_way  AS location,
#           x1        AS longtitude,
#           y1        AS latitude,
#           st_x(way) AS restaurant_x,
#           st_y(way) AS restaurant_y,
#           results.price,
#           results.rating,
#           results.place_id
#FROM       results
#INNER JOIN best_places
#ON		   results.place_id = best_places.place_id""".format(**params_dict))
        
        #Get the driving results
        results = pd.read_sql("""WITH results AS
(
       SELECT results.*,
              osm_2po_4pgr.geom_way,
              osm_2po_4pgr.x1,
              osm_2po_4pgr.y1
       FROM   (
                     {dijkstra_string}
	   
	   )
	
	AS results
       JOIN   osm_2po_4pgr
       ON     results.node = osm_2po_4pgr.osm_source_id ), best_places AS
(
         SELECT   *
         FROM    (
                         SELECT place_id,
                                sum(agg_cost) OVER (partition BY end_vid) AS total_cost,
                                max(agg_cost) OVER (partition BY end_vid) AS max_travel_time,
                                min(agg_cost) OVER (partition BY end_vid) AS min_travel_time
                         FROM   (
                                       SELECT *
                                       FROM   results
                                       WHERE  price != 'None') results
                         WHERE  edge = -1
                         AND    cast (price AS integer) <= {max_price}
                         AND    cast (price AS integer) >= {min_price}
                         AND    rating > {min_rating} ) results
         WHERE    max_travel_time   - min_travel_time < {max_travel_time_diff}
         ORDER BY total_cost limit {number_of_results}*{number_of_users} )
SELECT     path_seq,
           results.start_vid AS start_user,
           agg_cost          AS cost_for_user,
           total_cost,
           NAME,
           results.end_vid,
           geom_way  AS location,
           x1        AS longtitude,
           y1        AS latitude,
           st_x(way) AS restaurant_x,
           st_y(way) AS restaurant_y,
           results.price,
           results.rating,
           results.place_id
FROM       results
INNER JOIN best_places
ON		   results.place_id = best_places.place_id""".format(**params_dict),conn_gis)


        print('Perform optimisation -', time.time() - section_start_time)
        section_start_time = time.time()
        # print(results.columns)


        osm_id_to_name_dict = dict(zip(user_osms,user_identifiers))
        #Replace the osm ids in results with the user's names
        results['start_user_name'] = pd.Series(osm_id_to_name_dict[row['start_user']] for index,row in results.iterrows())
    
        #Format the results in dictionaries
        results_dict = {}
        results_dict['possible_locations'] = results.sort_values('total_cost')['name'].unique().tolist()
#        print(results_dict['possible_locations'])
        results_dict['users'] = user_details
        # print('results_dict:')
        # print(results_dict)
        # print('results:')
        # print(results)

        for location in results_dict['possible_locations']:
            results_dict[location] = {}
            for user in results_dict['users']:
                try:
                    # print('location:')
                    # print(location)
                    # print('user:')
                    # print(user)

                    relevant_df = results[results['start_user'] == user][results['name'] == location].set_index('path_seq')
                    relevant_df.sort_values('path_seq',inplace = True)

                    # print('relevant_df:')
                    # print(relevant_df)
                    
                    #Set the location information
                    results_dict[location]['price'] = str(relevant_df['price'].iloc[0])
                    results_dict[location]['rating'] = str(relevant_df['rating'].iloc[0])
                    results_dict[location]['place_id'] = str(relevant_df['place_id'].iloc[0])
                    results_dict[location]['total_cost'] = str(max([int(relevant_df['total_cost'].iloc[0] * 60),5*number_of_users]))
                    #Make a dictionary for each use
                
                    results_dict[location][user] = {}
                    results_dict[location][user]['cost_for_user'] = str(relevant_df['cost_for_user'].max() * 60)
                    results_dict[location][user]['latitude'] = relevant_df['latitude'].values.tolist()
                    results_dict[location][user]['longtitude'] = relevant_df['longtitude'].values.tolist()
                    # results_dict[location][user] = relevant_df[['latitude','longtitude']].to_dict()
                    
                    results_dict[location][user]['end_vid'] = str(relevant_df['end_vid'].iloc[0])
                    results_dict[location][user]['start_user'] = str(relevant_df['start_user'].iloc[0])
                    results_dict[location][user]['start_user_name'] = str(relevant_df['start_user_name'].iloc[0])
                    results_dict[location][user]['restaurant_x'] = relevant_df['restaurant_x'].iloc[0]
                    results_dict[location][user]['restaurant_y'] = relevant_df['restaurant_y'].iloc[0]
                    
                    
                except:
                    print('WARNING: exception on location',location,'user',user)

        return(results_dict)
    else:
        return 'Error' #Session id or username is wrong


def upload_calculated_route(sess_id,result):
#    try:
    doc_ref = get_doc_ref_for_id(sess_id)
    doc_dict = doc_ref.get().to_dict()
    doc_dict['results'] = json.dumps(result)
    doc_dict['calculate'] = 'done'
    doc_ref.set(doc_dict)
#    except:
#        print('Error inserting user details, does session id exist?')

#sess_id = 'f8893f7c-38fc-11ea-bf52-06b6ade4a06c'
#info = get_details_for_session_id(sess_id)
#results = calculate(sess_id,info)

while True:
    print('Checking')
    time.sleep(1)
    ids_that_need_calc = check_requires_calculation()
    for sess_id in ids_that_need_calc:
        info = get_details_for_session_id(sess_id)
        results = calculate(sess_id,info)
        upload_calculated_route(sess_id,results)
