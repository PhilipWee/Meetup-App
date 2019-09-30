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
#--------------------------------------REQUIREMENTS--------------------------------------

#--------------------------------------SETTINGS------------------------------------------
NUMBER_OF_RESULTS = 5

#--------------------------------------SETTINGS------------------------------------------

"""
API important links explanation:
/session/create (POST)
-> Generate session number, return the session number to user
-> Need key value for lat, long ,transport_mode, speed, quality
-> Generates lat, long, preferences and others and stores it in the database
-> Only for OAuth authenticated users

/session/<session_id> (POST)
-> Insert details for each particular user
-> Need key value for lat, long ,transport_mode, speed, quality

/session/<session_id> (GET)
-> Get all session details
-> Requires OAuth

/session/<session_id>/calculate (GET)
-> If OAuth is provided, run the calculation
-> Redirect to results page

/session/<session_id>/results (GET)
-> Use this page to show results to prevent lag
-> If OAuth is provided or IP address matches, show results

/session/<session_id>/get_details (GET)
-> Returns the website for friends to input details
"""

app = Flask(__name__)
CORS(app)

@app.route('/')
def index():
    return('Main Site Goes Here')

@app.route('/session/<session_id>/get_details')
def get_details(session_id):
    if request.method == "GET":
        return render_template('Geoloc2.html')
    

@app.route('/session/create', methods=['POST'])
def create_session():
    #Here we create the session

    ###Get session details from OAUTH
    username = 'username'

    #Check that a session for the user does not already exist
    crsr = conn.cursor()
    crsr.execute("SELECT username FROM sessions WHERE username = (%s) LIMIT 1;",(username,))
    exists = crsr.fetchone()
    if exists != None:
        return jsonify({'warning':'session already exists'})

    #Extract the post json details
    content = request.get_json()

    ###OAUTH REQUIRED HERE, ONLY REGISTERED USERS CAN MAKE SESSION

    ###Check that the lat and Long are valid

    #After checks, allow the creation of a session
    ###Generate Random Session ID:
    session_id = '123456'

    #Consolidate the session details
    host_user_details = {'username':username,
                        'lat':content.get('lat'),
                        'long':content.get('long'),
                        'transport_mode':content.get('transport_mode','public'),
                        'metrics':{
                            'speed':int(content.get('speed',5)),
                            'quality':int(content.get('quality',5))
                        }}

    details = {'users':[host_user_details]}
    json_details = json.dumps(details)
    print(json_details)

    #Upload the user's details
    crsr = conn.cursor()
    crsr.execute("INSERT INTO sessions (session_id, username, info) VALUES (%s,%s,%s);",(session_id,username,json_details))
    conn.commit()

    #Return the session id
    return jsonify({'session_id':session_id})

@app.route('/session/<session_id>', methods=['POST','GET'])
def manage_details(session_id):
    if request.method == 'POST':
        ###Ensure that we have not yet received a message from this ip
        identifier = 'identifier'

        #Get the content of the POST
        content_unparsed = request.get_json()
        content = {}
        for data_item in content_unparsed:
            content[data_item['name']] = data_item['value']
        print(content)

        ###Make sure the lat and long are provided and valid

        #Consolidate the session details
        new_user_details = {'identifier':identifier,
                            'lat':content.get('lat'),
                            'long':content.get('long'),
                            'transport_mode':content.get('transport_mode','public'),
                            'metrics':{
                                'speed':int(content.get('speed',5)),
                                'quality':int(content.get('quality',5))
                            }}

        #Get the current details of users
        crsr = conn.cursor()
        crsr.execute("SELECT info FROM sessions WHERE session_id = %s",(session_id,))
        info = crsr.fetchone()
        #The result is a tuple where the first value is the result in dictionary form alreadys
        if info is not None:
            info_dict = info[0]
            info_dict['users'].append(new_user_details)
            info = json.dumps(info_dict)
            #Upload the updated info into the tables
            crsr.execute("UPDATE sessions SET info=(%s) WHERE session_id = (%s)",(info,session_id))
            conn.commit()
            return jsonify({'updated_info_for_session_id':session_id})
        else:
            return jsonify({'error':'The specified session id does not yet exist'})

    elif request.method == 'GET':
        ###Check the OAuth details

        ###Extract the username
        username = 'username'

        #Get all the meetup details and return it to the user
        crsr = conn.cursor()
        crsr.execute("SELECT info FROM sessions WHERE session_id = %s and username = %s",(session_id,username))
        info = crsr.fetchone()
        if info != None:
            return jsonify(info[0])
        else:
            return jsonify({'error':'sesson_id or username is wrong'})

@app.route('/session/<session_id>/calculate', methods=['GET'])
def calculate(session_id):
    ###Check the OAuth details

    ###Extract the username
    username = 'username'

    #Get all the meetup details\
    section_start_time = time.time()

    crsr = conn.cursor()
    crsr.execute("SELECT info FROM sessions WHERE session_id = %s and username = %s",(session_id,username))
    info = crsr.fetchone()
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
        #Get route

        print('Get User Closest Node -', time.time() - section_start_time)
        section_start_time = time.time()

        results = pd.read_sql("with results as (\
                    select \
                        results.*,osm_2po_4pgr.geom_way,osm_2po_4pgr.x1,osm_2po_4pgr.y1\
                    from\
                            ((SELECT \
                                *				 \
                            FROM pgr_dijkstra(\
                            'SELECT osm_id as id, osm_source_id as source, osm_target_id as target, cost, reverse_cost FROM osm_2po_4pgr',\
                            "+user_array+",\
                            ARRAY(select nearest_road_neighbour_osm_id from singapore_restaurants_2)))\
                        as results\
                    join singapore_restaurants_2\
                        on results.end_vid = singapore_restaurants_2.nearest_road_neighbour_osm_id) as results\
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
            

        
        #Split dataframe by user
        
        results = json.dumps(results_dict)
        crsr = conn.cursor()
        crsr.execute("UPDATE sessions SET results=%s WHERE session_id =%s",(results,session_id))
        conn.commit()
        print('Update Tables, etc -', time.time() - section_start_time)
        return redirect("/session/"+session_id+"/results", code=302)
    else:
        return jsonify({'error':'sesson_id or username is wrong'})

@app.route('/session/<session_id>/results', methods=['GET'])
def results(session_id):
    #Get the session results from PGSQL
    crsr = conn.cursor()
    crsr.execute("SELECT results FROM sessions WHERE session_id=%s",(session_id,))
    results = crsr.fetchone()
    results = results[0]
    ### Check if the user is authorised to see the data

    #return the results
    return jsonify(results)




if __name__ == '__main__':

    #--------------------------------------CONNECT TO DATABASE-------------------------------
    # Set up a connection to the postgres server.
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

    #Check if the database exists. If not, create it
    current_tables = pd.read_sql("SELECT * FROM information_schema.tables",conn)
    exists = False
    for name in current_tables['table_name']:
        if name == 'sessions':
            exists = True
    if not exists:
        print('sessions do not exist, creating sessions table')
        crsr.execute('CREATE TABLE sessions (id SERIAL, session_id CHARACTER(255), username CHARACTER(255), info JSONB, results JSONB, PRIMARY KEY(id));')
        conn.commit()
        print('Done')
    else:
        print('table "sessions" already exist, moving on')

    #Run the App
    app.run(host='0.0.0.0', debug=True, use_reloader=False,port = 5000)
    # app.run(host='0.0.0.0', debug=True, use_reloader=False)
    crsr.close()
