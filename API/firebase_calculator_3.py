

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
import copy
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import socketio
import pprint
import threading
#--------------------------------------REQUIREMENTS--------------------------------------

#--------------------------------------SETTINGS--------------------------------------
NUMBER_OF_RESULTS = 20
#--------------------------------------SETTINGS--------------------------------------

#--------------------------------------CONNECT TO FIREBASE-------------------------------
print('Connecting to firebase')
if (not len(firebase_admin._apps)):

    # Use the application default credentials
    # Use a service account
    #cred = credentials.Certificate('C:/Users/Philip Wee/Documents/MeetupAppConfidential/meetup-mouse-265200-2bcf88fc79cc.json')
    cred = credentials.Certificate('/home/ubuntu/Meetup App Confidential/meetup-mouse-265200-2bcf88fc79cc.json')
    # cred = credentials.Certificate('C:/Users/fanda/Documents/SUTD SOAR/Meetup Mouse/meetup-mouse-265200-2bcf88fc79cc.json')
    firebase_admin.initialize_app(cred)
    db = firestore.client()
else:
    db = firestore.client()
print('Connected!')
#--------------------------------------CONNECT TO FIREBASE-------------------------------

#--------------------------------------CONNECT TO DATABASE-------------------------------
# Set up a connection to the postgres server.
#try:
#    print("Connecting to the postgres server")
#    conn_string = "host="+ creds.PGHOST +" port="+ "5432" +" dbname="+ creds.PGDATABASE +" user=" + creds.PGUSER \
#    +" password="+ creds.PGPASSWORD
#    conn=psycopg2.connect(conn_string)
#    print("Connected!")
#    crsr = conn.cursor()
#    #Set up a connection to gisdb, the routing database
#    print("Connecting to routing database")
#    conn_string = "host="+ creds.PGHOST +" port="+ "5432" +" dbname="+ creds.PGROUTINGDATABASE +" user=" + creds.PGUSER \
#    +" password="+ creds.PGPASSWORD
#    conn_gis=psycopg2.connect(conn_string)
#    print("Connected!")
#    crsr_gis = conn_gis.cursor()
#except:
#    creds.PGHOST = 'journey'
#    print("Connecting to the postgres server")
#    conn_string = "host="+ creds.PGHOST +" port="+ "5432" +" dbname="+ creds.PGDATABASE +" user=" + creds.PGUSER \
#    +" password="+ creds.PGPASSWORD
#    conn=psycopg2.connect(conn_string)
#    print("Connected!")
#    crsr = conn.cursor()
    #Set up a connection to gisdb, the routing database
#    print("Connecting to routing database")
#    conn_string = "host="+ creds.PGHOST +" port="+ "5432" +" dbname="+ creds.PGROUTINGDATABASE +" user=" + creds.PGUSER \
#    +" password="+ creds.PGPASSWORD
#    conn_gis=psycopg2.connect(conn_string)
#    print("Connected!")
#    crsr_gis = conn_gis.cursor()
try:
    print("Connecting to the data database")
    conn_string = "host="+ creds.PGHOST +" port="+ "5432" +" dbname="+ creds.PGDATADATABASE +" user=" + creds.PGUSER \
    +" password="+ creds.PGPASSWORD
    data_conn=psycopg2.connect(conn_string)
    print("Connected!")
    data_crsr = data_conn.cursor()
except:
    try:
        #We may be on the server, try connecting to that instead
        conn_string = "host="+ creds.PGAWSHOST +" port="+ "5432" +" dbname="+ creds.PGDATADATABASE +" user=" + creds.PGUSER \
        +" password="+ creds.PGPASSWORD
        data_conn=psycopg2.connect(conn_string)
        print("Connected!")
        data_crsr = data_conn.cursor()
    except:
        raise Exception("Unable to connect to the food blog data database, check postgres is running and IP address is correct")
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
    print("Calculating for sess_id:",sess_id)
    ###Check the OAuth details

    #Get all the meetup details\
    section_start_time = time.time()

    info = [info]

    if info != None:
        ###Calculate the best route for each person and return it
        user_identifiers = []
        user_details = {}
        quality_array = []
        speed_array = []
        price_array = []
        results_df = None
        results_dict ={}
        for user_id,user in enumerate(info[0]['users']):
            # print("User Details:")
            # print(user)
            #Get the osm_id closest to the user's location

            if results_df is None:
                sql_string = "SELECT *,sqrt((long- "+str(user['long'])+")^2 + (lat- "+str(user['lat'])+")^2) as distance FROM food_blog_places_clean_2\
                ORDER BY distance"
    #           print(sql_string)
                original_df = pd.read_sql(sql_string,data_conn)
                results_df = copy.deepcopy(original_df)
                # print(results_df)
                results_df = results_df[['id','distance']]
                # print(results_df)
                # print(original_df)

            else:
                sql_string = "SELECT id,sqrt((long- "+str(user['long'])+")^2 + (lat- "+str(user['lat'])+")^2) as distance FROM food_blog_places_clean_2\
                ORDER BY distance"
                table = pd.read_sql(sql_string,data_conn)
                results_df = pd.concat([results_df,table]).groupby('id').sum().reset_index()
                # print(results_df)

            user_details[user_id] = {"latitude":user['lat'],"longtitude":user['long']}
            user_details[user_id].update(user)
            user_identifiers.append(user.get('username',user.get('identifier','unknown user')))
            quality_array.append(user['metrics']['quality'])
            speed_array.append(user['metrics']['speed'])
            if 'price' in user['metrics'].keys():
                price_array.append(user['metrics']['price'])

        original_df = original_df.drop('distance',axis=1)
        results_df = pd.merge(original_df,results_df,on='id')

        #Sort the values in order
        results_df = results_df.sort_values(by='distance')



        max_price = max(price_array, default = 5)
        min_price = min(price_array, default = 0)
        min_rating = np.mean(quality_array)
        max_travel_time_diff = (6 - np.mean(speed_array)) * 5/60

        results_df = results_df[results_df['rating']>=min_rating]
        # results_df = results_df[results_df['min_price']>=min_price*10]
        results_df = results_df[results_df['min_price']<=max_price*10]
        # return results_df

        # pprint.pprint(user_details)


        #Get the user arrays
        user_public_ids = [user_detail_key for user_detail_key in user_details.keys() if user_details[user_detail_key]['transport_mode'] == 'Public Transit' or user_details[user_detail_key]['transport_mode'] == 'public']
        user_driving_ids = [user_detail_key for user_detail_key in user_details.keys() if user_details[user_detail_key]['transport_mode'] == 'Driving' or user_details[user_detail_key]['transport_mode'] == 'driving']
        user_walking_ids = [user_detail_key for user_detail_key in user_details.keys() if user_details[user_detail_key]['transport_mode'] == 'Walking' or user_details[user_detail_key]['transport_mode'] == 'walking' or user_details[user_detail_key]['transport_mode'] == 'Walk']


        # set the meeting type
        meeting_type = info[0]['meeting_type']

        #Get the number of users
        number_of_users = len(info[0]['users'])

        #Do a return if all the arrays are empty
        # if len(user_public_ids)==0 and len(user_driving_ids)==0 and len(user_walking_ids)==0:
        #     return {'Error':'No users could be found on the map (No user osms)'}

        params_dict = {'max_price': max_price,
                       'min_price' : min_price,
                       'min_rating' : min_rating,
                       'max_travel_time_diff' : max_travel_time_diff,
                       'meeting_type' : meeting_type,
                       'user_public_array': user_public_ids,
                       'user_driving_array':user_driving_ids,
                       'user_walking_array': user_walking_ids,
                       'number_of_results':NUMBER_OF_RESULTS,
                       'number_of_users':number_of_users}

        results_dict['possible_locations'] = list(results_df['name'])[:20]

        results_dict['users'] = list(user_details.keys())


        for location in results_dict['possible_locations']:
            results_dict[location] = {}
            for user in results_dict['users']:

                # print('location:')
                # print(location)
                # print('user:')
                # print(user)


                # print('relevant_df:')
                # print(relevant_df)

                #Set the location information
#                    print(relevant_df.columns)
                # print(results_dict[location])
                results_dict[location]['price'] = str(results_df[results_df['name']==location]['cost_per_pax'].values[0])
                # print(results_dict[location]['price'])
                results_dict[location]['rating'] = str(results_df[results_df['name']==location]['rating'].values[0])
                results_dict[location]['place_id'] = "NA"
                results_dict[location]['total_cost'] = "NA"
                #New location details
                results_dict[location]['address'] = str(results_df[results_df['name']==location]['address'].values[0])
                results_dict[location]['postal_code'] = str(results_df[results_df['name']==location]['postal_code'].values[0])
                results_dict[location]['operating_hours'] = str(results_df[results_df['name']==location]['operating_hours'].values[0])
                pictures_unparsed = results_df[results_df['name']==location]['pictures_url'].values[0]

                results_dict[location]['pictures'] = pictures_unparsed[1:-1].split(',')[:3]
                # print(results_dict[location]['pictures'])
                results_dict[location]['writeup'] = str(results_df[results_df['name']==location]['writeup'].values[0])

                #Make a dictionary for each use

                results_dict[location][user] = {}
                results_dict[location][user]['cost_for_user'] = "NA"
                results_dict[location][user]['latitude'] = "NA"
                results_dict[location][user]['longtitude'] = "NA"
                results_dict[location][user]['transport_type'] = "NA"
                results_dict[location][user]['transport_type_id'] = "NA"
                results_dict[location][user]['node'] = "NA"
                results_dict[location][user]['start_vid'] = "NA"
                # results_dict[location][user] = relevant_df[['latitude','longtitude']].to_dict()

                results_dict[location][user]['end_vid'] = "NA"
                results_dict[location][user]['start_user'] = user
                try:
                    results_dict[location][user]['start_user_name'] = user_details[user]['username']
                except:
                    results_dict[location][user]['start_user_name'] = "Anonymouse"
                results_dict[location][user]['restaurant_x'] = str(results_df[results_df['name']==location]['long'].values[0])
                results_dict[location][user]['restaurant_y'] = str(results_df[results_df['name']==location]['lat'].values[0])

                #Possible transport types are:




        return(results_dict)
    else:
        return 'Error' #Session id or username is wrong


def upload_calculated_route(sess_id,result):
    doc_ref = get_doc_ref_for_id(sess_id)
    doc_dict = doc_ref.get().to_dict()
    doc_dict['results'] = json.dumps(result)
    doc_dict['calculate'] = 'done'
    doc_ref.set(doc_dict)


# while True:
#     print('Checking')
#     time.sleep(1)
#     ids_that_need_calc = check_requires_calculation()
#     for sess_id in ids_that_need_calc:
#         info = get_details_for_session_id(sess_id)
#         results = calculate(sess_id,info)
#         upload_calculated_route(sess_id,results)

sio = socketio.Client()
if len(sys.argv) >1:
    print(sys.argv[1])
    sio.connect(sys.argv[1])
else:
    sio.connect('3.23.239.59:5000')



info = get_details_for_session_id('000000')
pprint.pprint(info)
results = calculate('000000',info)
# upload_calculated_route('000000',results)


# Create a callback on_snapshot function to capture changes
def on_snapshot(col_snapshot, changes, read_time):
    print(u'Callback received query snapshot.')
    for change in changes:
        if change.type.name == 'ADDED':
            print(u'Requires calculation: {}'.format(change.document.id))
            sess_id = change.document.id
            info = get_details_for_session_id(sess_id)
            results = calculate(sess_id,info)
            upload_calculated_route(sess_id,results)
            #Send a message to the server saying that the calculation is done
            sio.emit('calculation_done',{'session_id':sess_id})
        elif change.type.name == 'MODIFIED':
            print(u'Modification Made: {}'.format(change.document.id))
        elif change.type.name == 'REMOVED':
            print(u'No Longer Needs calculation: {}'.format(change.document.id))

col_query = db.collection(u'sessions').where(u'calculate', u'==', u'True')

# Watch the collection query
query_watch = col_query.on_snapshot(on_snapshot)

if __name__ == '__main__':
    while True:
        time.sleep(2)
