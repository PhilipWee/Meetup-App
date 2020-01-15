

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
#--------------------------------------REQUIREMENTS--------------------------------------

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
        for user in info[0]['users']:
            print(user)
            #Get the osm_id closest to the user's location
            crsr_gis.execute("SELECT osm_source_id as osm_id FROM osm_2po_4pgr\
                ORDER BY sqrt((x1-"+str(user['long'])+")^2 + (y1-"+str(user['lat'])+")^2) \
            LIMIT 1")
            osm_id = crsr_gis.fetchone()[0]
            user_details[osm_id] = {"latitude":user['lat'],"longtitude":user['long']}
            user_osms.append(osm_id)
            user_identifiers.append(user.get('username',user.get('identifier','unknown user')))
        # print(user_osms)
        user_array = "ARRAY["+','.join(str(user_osm) for user_osm in user_osms)+"]::bigint[]"
        # set the meeting type
        if info[0]['meeting_type'] == 'food':
            location_db = "singapore_restaurants_2"
        elif info[0]['meeting_type'] == 'outing':
            location_db = "outing_data"

        #Get route

        print('Get User Closest Node -', time.time() - section_start_time)
        section_start_time = time.time()

        #Get the driving results
        results = pd.read_sql("with results as (\
                    select \
                        results.*,osm_2po_4pgr.geom_way,osm_2po_4pgr.x1,osm_2po_4pgr.y1\
                    from\
                            ((SELECT \
                                *				 \
                            FROM pgr_dijkstra(\
                            'select * from public_edges',\
                            "+user_array+",\
                            ARRAY(select nearest_road_neighbour_osm_id from "+location_db+")))\
                        as results\
                    join "+location_db+"\
                        on results.end_vid = "+location_db+".nearest_road_neighbour_osm_id) as results\
                    join\
                        osm_2po_4pgr on results.node = osm_2po_4pgr.osm_source_id\
                ), best_places as (\
                    select start_vid,end_vid,sum(agg_cost) over (partition by end_vid) as total_cost from results where edge = -1 order by total_cost limit 5*cardinality("+user_array+")\
                )\
\
                select \
                    path_seq,\
                    results.start_vid as start_user,\
                    agg_cost as cost_for_user,\
                    total_cost,\
                    name,\
                    results.end_vid,\
                    x1 as longtitude,\
                    y1 as latitude,\
                    ST_X(way) as restaurant_x,\
                    ST_Y(way) as restaurant_y\
                from\
                    results\
                    inner join\
                    best_places\
                    on results.end_vid = best_places.end_vid and results.start_vid = best_places.start_vid",conn_gis)

        print('Perform optimisation -', time.time() - section_start_time)
        section_start_time = time.time()


        osm_id_to_name_dict = dict(zip(user_osms,user_identifiers))
        #Replace the osm ids in results with the user's names
        results['start_user_name'] = pd.Series(osm_id_to_name_dict[row['start_user']] for index,row in results.iterrows())
        #Format the results in dictionaries
        results_dict = {}
        results_dict['possible_locations'] = results['name'].unique().tolist()
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


                    #Make a dictionary for each use
                    results_dict[location][user] = {}
                    results_dict[location][user]['latitude'] = relevant_df['latitude'].values.tolist()
                    results_dict[location][user]['longtitude'] = relevant_df['longtitude'].values.tolist()
                    # results_dict[location][user] = relevant_df[['latitude','longtitude']].to_dict()
                    results_dict[location][user]['total_cost'] = str(relevant_df['total_cost'].iloc[0])
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

while True:
    print('Checking')
    time.sleep(1)
    ids_that_need_calc = check_requires_calculation()
    for sess_id in ids_that_need_calc:
        info = get_details_for_session_id(sess_id)
        results = calculate(sess_id,info)
        upload_calculated_route(sess_id,results)
