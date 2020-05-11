#--------------------------------------REQUIREMENTS--------------------------------------
from flask import Flask,jsonify,request,abort, redirect, url_for,render_template
from flask_dance.contrib.github import make_github_blueprint, github
from flask_cors import CORS
from flask_socketio import SocketIO

#import psycopg2
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

#The secret key is necessary for session to work
app.secret_key = 'super dsagbrjuyki64y5tg4fd key'

@app.route('/', methods=['POST', 'GET'])
def index():
    #A placeholder to check if the website is working
    if request.method == 'GET':
        return render_template('mainpage.html')
    if request.method == 'POST':
        content = request.get_json()

        send_bug_report(content)
        return "SENT!"

@app.route('/session/<session_id>/get_details')
def get_details(session_id):
    if request.method == "GET":
        return render_template('joinMeetupPage.html', session_id = session_id)
    
@app.route('/loginPage')
def login():
    if request.method == "GET":
        return render_template('loginPage.html')
    
@app.route('/swipe')
def swipe():
    if request.method == "GET":
        return render_template('cardSwipe.html')

@app.route('/session/<session_id>/results_display')
def results_display(session_id):
    checkHost = request.args['isHost']
    if checkHost == 'true':
        return render_template('Geoloc.html', session_id = session_id, ifHost=True)
    else:
        return render_template('Geoloc.html', session_id = session_id, ifHost=False)

@app.route('/session/create', methods=['POST', 'GET'])
def create_session():
    #Here we create the session
    if request.method == "GET":
        return render_template('createMeetupPage.html')
    if request.method == "POST":
        content_unparsed = request.get_json()

        # Sort between web content and mobile content
        if isinstance(content_unparsed, list):
            content = {}
            #print(content_unparsed)
            for dic in content_unparsed:
                content[dic['name']] = dic['value']
        else:
            content = content_unparsed

        # Retrieve username and meeting_type, set both if none
        if content.get('username') is not None:
            username = content.get('username')
        else:
            username = "username"

        #Set the meeting type
        if content.get('meeting_type') is not None:
            meeting_type = content.get('meeting_type')
        else:
            meeting_type = "food"

        # Create new firebase document for new meeting
        session_id = create_firebase_session(content,meeting_type,username)

        response = jsonify({'session_id':session_id})

        return response

@app.route('/session/<session_id>', methods=['POST','GET'])
def manage_details(session_id):
    if request.method == 'POST':
        ###Ensure that we have not yet received a message from this ip
        identifier = 'identifier'

        #Get the content of the POST
        content_unparsed = request.get_json()
        # Sort between web content and mobile content
        if isinstance(content_unparsed, list):
            content = {}
            #print(content_unparsed)
            for dic in content_unparsed:
                content[dic['name']] = dic['value']
        else:
            content = content_unparsed


        ###Make sure the lat and long are provided and valid

        #Consolidate new user details
        new_user_details = {'identifier':identifier,
                            'lat':content.get('lat'),
                            'long':content.get('long'),
                            'transport_mode':content.get('transport_mode','public'),
                            'metrics':{
                                'speed':int(content.get('speed',5)),
                                'quality':int(content.get('quality',5)),
                                'price':int(content.get('price', 0))
                            }}

        #Upload the details of the new user
        insert_user_details(new_user_details,session_id)
        return jsonify({'updated_info_for_session_id':session_id})

    elif request.method == 'GET':

        #Get all the meetup details and return it to the user
        info = get_details_for_session_id(session_id)
        if info != 'Error':
            return jsonify(info)
        else:
            return jsonify({'error':'sesson_id or username is wrong'})

@app.route('/session/<session_id>/calculate', methods=['GET'])
def calculate(session_id):
    ###Check the OAuth details

    #Get all the meetup details
    result = set_calculate_flag(session_id)
    if result != 'Error':
        return redirect("/session/"+session_id+"/results", code=302)
    else:
        return jsonify({'error':'sesson_id or username is wrong'})

@app.route('/session/<session_id>/results', methods=['GET'])
def results(session_id):
    result = check_calculate_done(session_id)
    if result == True:
        data = get_calculate_done_details(session_id)
        return data
        #Run calculation done code
    elif result == False:
        return jsonify({'info': 'session exists but calculation not done'})
    elif result == 'Error':
        return jsonify({'error':'sesson_id or username is wrong'})
    elif result == 'not_started':
        return jsonify({'info': 'session exists but calculation not started'})

def create_firebase_session(content,meeting_type,username):
    # Consolidate the session details
    host_user_details = {'username':username,
                        'lat':content.get('lat'),
                        'long':content.get('long'),
                        'transport_mode':content.get('transport_mode','public'),
                        'metrics':{
                            'speed':int(content.get('speed',5)),
                            'quality':int(content.get('quality',5)),
                            'price':int(content.get('price', 0))
                        },
                        'time_created':str(datetime.datetime.now())}

    details = {'users':[host_user_details],'meeting_type':meeting_type}

    #Generate session id
    session_id = str(uuid.uuid1())

    #Upload the user's details
    doc_ref = get_doc_ref_for_id(session_id)
    doc_ref.set({'info':details})

    #Return the session id
    return session_id

def insert_user_details(details,session_id):
    try:
        doc_ref = get_doc_ref_for_id(session_id)
        doc_dict = doc_ref.get().to_dict()
        doc_dict['info']['users'].append(details)
        doc_ref.set(doc_dict)
    except:
        print('Error inserting user details, does session id exist?')

def set_calculate_flag(session_id):
#    try:
    doc_ref = get_doc_ref_for_id(session_id)
    doc_dict = doc_ref.get().to_dict()
    if 'calculate' not in doc_dict.keys():
        doc_dict['calculate'] = 'True'
        doc_ref.set(doc_dict)
        return 'Calculating'
    else:
        return 'Error'

def check_calculate_done(session_id):
    try:
        doc_ref = get_doc_ref_for_id(session_id)
        doc_dict = doc_ref.get().to_dict()
        if doc_dict['calculate'] is not None:
            if doc_dict['calculate'] == 'done':
                return True
            else:
                return False
        else:
            return 'not_started'
    except:
        return 'Error'

def get_calculate_done_details(session_id):
    try:
        doc_ref = get_doc_ref_for_id(session_id)
        doc_dict = doc_ref.get().to_dict()
        if doc_dict['results'] is not None:
            return doc_dict['results']
        else:
            return 'no_results'
    except:
        return 'Error'

def get_details_for_session_id(session_id):
    try:
        doc_ref = get_doc_ref_for_id(session_id)
        return doc_ref.get().to_dict()['info']
    except:
        print('Error getting user details, does session id exist?')
        return 'Error'

def get_doc_ref_for_id(session_id):
    session_id = str(session_id)
    return db.collection(u'sessions').document(session_id)

# Function to send bug reports to firebase
def send_bug_report(content):
    report = {
        u'content': content,
        u'timestamp': firestore.SERVER_TIMESTAMP
    }
    database = firestore.client()
    database.collection(u'bugReports').add(report)



if __name__ == '__main__':
    #--------------------------------------CONNECT TO FIREBASE-------------------------------
    print('Connecting to firebase')
    if (not len(firebase_admin._apps)):

        # Use the application default credentials
        # Use a service account
        cred = credentials.Certificate('C:/Users/fanda/Documents/SUTD SOAR/Meetup Mouse/meetup-mouse-265200-2bcf88fc79cc.json')
        firebase_admin.initialize_app(cred)
        db = firestore.client()
    else:
        db = firestore.client()
    print('Connected!')
    #--------------------------------------CONNECT TO FIREBASE-------------------------------

# #--------------------------------------CONNECT TO DATABASE-------------------------------
#Run the App
app.run(host='0.0.0.0', debug=True, use_reloader=False,port = 5000)
# app.run(host='0.0.0.0', debug=True, use_reloader=False)
crsr.close()
