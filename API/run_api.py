#--------------------------------------REQUIREMENTS--------------------------------------
from flask import Flask,jsonify,request,abort, redirect, url_for
from flask_dance.contrib.github import make_github_blueprint, github
import psycopg2
import sys, os
import numpy as np
import pandas as pd
import credentials as creds
import pandas.io.sql as psql
import json
#--------------------------------------REQUIREMENTS--------------------------------------

"""
API important links explanation:
/session/create (POST)
-> Generate session number, return the session number to user
-> Need key value for lat, long ,transport_mode, speed, quality
-> Generates lat, long, preferences and others and stores it in the database
-> Only for OAuth authenticated users

/session/<session_id> (PUT)
-> Insert details for each particular user
-> Need key value for lat, long ,transport_mode, speed, quality

/session/<session_id> (GET)
-> Get all session details
-> Requires OAuth

/session/<session_id>/calculate (GET)
-> If OAuth is provided, run the calculation
-> Redirect to results page

/session/<session_id>/results (GET)
-> If OAuth is provided or IP address matches, show results

"""

app = Flask(__name__)

@app.route('/')
def index():
    return('Main Site Goes Here')


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

@app.route('/session/<session_id>', methods=['PUT','GET'])
def manage_details(session_id):
    if request.method == 'PUT':
        ###Ensure that we have not yet received a message from this ip
        identifier = 'identifier'

        #Get the content of the PUT
        content = request.get_json()

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
        info_dict = info[0]
        info_dict['users'].append(new_user_details)
        info = json.dumps(info_dict)
        #Upload the updated info into the tables
        crsr.execute("UPDATE sessions SET info=(%s) WHERE session_id = (%s)",(info,session_id))
        conn.commit()
        return jsonify({'updated_info_for_session_id':session_id})

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

    #Get all the meetup details
    crsr = conn.cursor()
    crsr.execute("SELECT info FROM sessions WHERE session_id = %s and username = %s",(session_id,username))
    info = crsr.fetchone()
    if info != None:
        best_routes = {
                        'users':{},
                        'destinations':[{'name':'SIMPANG!?!?!??!?!',
                                        'lat':'1.3312',
                                        'long':'103.9475',
                                        'rating':9}]
                        }
        ###Calculate the best route for each person and return it
        for user in info[0]['users']:
            print(user)
            #user is a dictionary containing the details of each user
            user_info = {'route':[{
                                'lat':'0392302932',
                                'long':'3209430'
                                },{
                                'lat':'03dsd2932',
                                'long':'3209332430'
                                },{
                                'lat':'03925454932',
                                'long':'323232230'
                                },{
                                'lat':'03977762932',
                                'long':'3203232230'
                                },
                                ]}
            #username is the username of the person in question
            #Try to get the username, if unable to get the identifier, if unable to just label as unknown
            best_routes['users'][user.get('username',user.get('identifier','unknown user'))] = user_info
        #Upload the results to PGSQL
        results = json.dumps(best_routes)
        crsr = conn.cursor()
        crsr.execute("UPDATE sessions SET results=%s WHERE session_id =%s",(json.dumps(best_routes),session_id))
        conn.commit()
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
    app.run(debug=True, use_reloader=False)
    crsr.close()
