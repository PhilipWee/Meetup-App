#--------------------------------------REQUIREMENTS--------------------------------------
from flask import Flask,jsonify,request,abort, redirect, url_for,render_template
from flask_dance.contrib.github import make_github_blueprint, github
from flask_cors import CORS
from flask_socketio import SocketIO
from flask_socketio import emit, send
from flask_socketio import join_room, leave_room
from schema import Schema, SchemaError, And, Use
import sys, os
import numpy as np
import pandas as pd
import pandas.io.sql as psql
import json
import time
import uuid
import datetime
import firebase_admin
import random
from distutils.util import strtobool
from firebase_admin import credentials
from firebase_admin import firestore
#--------------------------------------REQUIREMENTS--------------------------------------

#--------------------------------------SETTINGS------------------------------------------
NUMBER_OF_RESULTS = 20
#--------------------------------------SETTINGS------------------------------------------

#--------------------------------------CONNECT TO FIREBASE-------------------------------
print('Connecting to firebase')
if (not len(firebase_admin._apps)):

    # Use the application default credentials
    # Use a service account
    # cred = credentials.Certificate('/Users/vedaalexandra/Desktop/meetup-mouse-265200-2bcf88fc79cc.json')
    # cred = credentials.Certificate('C:/Users/Omnif/Documents/meetup-mouse-265200-2bcf88fc79cc.json')
    # cred = credentials.Certificate('/home/ubuntu/Meetup App Confidential/meetup-mouse-265200-2bcf88fc79cc.json')
    #cred = credentials.Certificate('C:/Users/Philip Wee/Documents/MeetupAppConfidential/meetup-mouse-265200-2bcf88fc79cc.json')
    cred = credentials.Certificate('C:/Users/fanda/Documents/SUTD SOAR/Meetup Mouse/meetup-mouse-265200-2bcf88fc79cc.json')
    firebase_admin.initialize_app(cred)
    db = firestore.client()
else:
    db = firestore.client()
print('Connected!')
#--------------------------------------CONNECT TO FIREBASE-------------------------------

app = Flask(__name__)
socketio = SocketIO(app)

#The secret key is necessary for session to work
app.secret_key = 'super dsagbrjuyki64y5tg4fd key'

"""
API important links explanation:
/session/create (POST)
-> Generate session number, return the session number to user
-> Sample Data:
    {
        "meetup_name":str,
        "lat":float,
        "long":float,
        "transport_mode": lambda x: x in ["public","driving","walking"],
        "metrics":{
            "speed":int,
            "quality":int,
            "price":int},
        "username":str,
        "uuid":str,
        "meeting_type" : lambda x: x in ["food","outing","meeting"]
    }
-> Generates lat, long, preferences and others and stores it in the database
-> Only for OAuth authenticated users

/session/<session_id> (POST)
-> Insert details for each particular user
-> Sample Data:
    {
        "lat":float,
        "long":float,
        "transport_mode": lambda x: x in ["public","driving","walking"],
        "metrics":{
            "speed":int,
            "quality":int,
            "price":int},
        "username":str,
        "uuid":str
    }

/session/<session_id> (GET)
-> Get all session details
-> PLEASE USE THE SOCKET CONNECTION INSTEAD UNLESS FIRST PULL OF DATA
-> Sample Data:
    { "session_status": "pending_members",
      "meeting_type": "food",
      "meetup_name": "hi",
      "time_created": "2020-05-13 12:46:57.370295",
      "host_uuid": "8319hfbicyvsug21obhvyduiew"
      "users": [
        {
          "lat": 103.3,
          "long": 1.2,
          "metrics": {
            "price": 4,
            "quality": 3,
            "speed": 2
          },
          "transport_mode": "public",
          "username": "Philip",
          "uuid": "8319hfbicyvsug21obhvyduiew"
        },
        {
          "lat": 103.3,
          "long": 1.2,
          "metrics": {
            "price": 4,
            "quality": 3,
            "speed": 2
          },
          "transport_mode": "public",
          "username": "Philip",
          "uuid": "8319hfbicyvsug21obhvyduiew"
        }
      ]
    }
-> Requires OAuth

/session/<session_id>/calculate (GET)
-> If OAuth is provided, run the calculation
-> Redirect to results page

/session/<session_id>/results (GET)
-> Use this page to show results to prevent lag
-> If OAuth is provided or IP address matches, show results
-> Sample data provided in SampleResultsJSON.json

/session/<session_id>/get_details (GET)\
-> Returns the website for friends to input details

SocketIO important stuff explanation:
Namespace: '/'
Room: sessionID


Server Emitted Events:

-> Event:'user_joined_room'
Sample Data: {'identifier':identifier,
            'lat':content.get('lat'),
            'long':content.get('long'),
            'transport_mode':content.get('transport_mode','public'),
            'metrics':{
                'speed':int(content.get('speed',5)),
                'quality':int(content.get('quality',5)),
                'price':int(content.get('price', 0))
            }}
Use case: Will be emitted whenever a new user joins the room

-> Event: 'calculation_result'
Sample data provided in SampleResultsJSON.json
Use case: Will be emitted when the calculation is completed

-> Event: 'location_found'
Sample Data: {'swipeIndex' : 12}
Use case: Will be emitted when all there is a matching location


Client Emitted Events:

-> Event: 'join'
Sample Data: {'room' : <session_id> }
Use case: Will be triggered when the join room function is called

-> Event: 'swipe_details'
Sample Data: {'sessionID': 123456,
              'swipeIndex': 5,
              'userIdentifier':'abc123',
              'selection':'true'/'false'}
Use case: Emitted by user whenever swiping
"""

def check_dict_correct_format(dct,schema_str):
    try:
        exec("global dct_schema; dct_schema = Schema(" + schema_str + ")")
        dct_schema.validate(dct)
        return ""
    except Exception as e:
        x = ""
        x += "The correct format is: \n"
        x += str(schema_str) + "\n\n"
        x += "But you sent: \n"
        x += json.dumps(dct,indent = 2) + "\n\n"
        x += "Which returned an error: \n"
        x += str(e)  + "\n\n"
        insult_options = ['PLEASE SEND THE CORRECT FORMAT FOR GOODNESS SAKE',
                          'PEOPLE WHO USE THE WRONG FORMAT ARE CLOWNS',
                          'YEARS OF ACADEMY TRAINING JUST TO USE THE WRONG FORMAT',
                          'I COULD BE PLAYING DOTA, BUT YOUR WRONG FORMAT IS WASTING TIME',
                          ]
        x += random.choice(insult_options)
        return x



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

@app.route('/session/create', methods=['POST', 'GET'])
def create_session():
    #Here we create the session
    if request.method == "GET":
        return render_template('createMeetupPage.html')
    if request.method == "POST":
        schema_str = """
        {
            "meetup_name":str,
            "lat":float,
            "long":float,
            "transport_mode": lambda x: x in ["public","driving","walking"],
            "metrics":{
                "speed":int,
                "quality":int,
                "price":int},
            "username":str,
            "uuid":str,
            "meeting_type" : lambda x: x in ["food","outing","meeting"]
        }
        """
        content = request.get_json()

        result = check_dict_correct_format(content,schema_str)
        if result != "":
            return result

        # Create new firebase document for new meeting
        session_id = create_firebase_session(content)

        response = jsonify({'session_id':session_id})

        print('Session [ ' + session_id + " ] created")

        return response

@app.route('/session/<session_id>', methods=['POST','GET'])
def manage_details(session_id):
    if request.method == 'POST':
        ###Ensure that we have not yet received a message from this ip
        schema_str = """{
            "lat":float,
            "long":float,
            "transport_mode": lambda x: x in ["public","driving","walking"],
            "metrics":{
                "speed":int,
                "quality":int,
                "price":int},
            "username":str,
            "uuid":str
        }"""
        content = request.get_json()
        result = check_dict_correct_format(content,schema_str)
        if result != "":
            return result

        result = insert_user_details(content,session_id)

        if result == "Error":
            jsonify({'error':'Problem inserting user details'})

        #Emit using socketio the details of the new user
        socketio.emit('user_joined_room',content,room=session_id)

        print('user [ ' + content['uuid'] + " ] joined session [ " + session_id + " ]")

        return jsonify({'updated_info_for_session_id':session_id})

    elif request.method == 'GET':

        #Get all the meetup details and return it to the user
        info = get_details_for_session_id(session_id)
        if info != 'Error':
            return jsonify(info)
        else:
            return jsonify({'error':'Does session_id exist?'})

@app.route('/session/<session_id>/calculate', methods=['GET'])
def calculate(session_id):
    ###Check the OAuth details

    #Get all the meetup details
    result = set_calculate_flag(session_id)
    if result != 'Error':
        return jsonify({"info":"calculating"})
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

#Function for checking if the calculation is done

def on_snapshot(col_snapshot, changes, read_time):

    #TODO: Find a better solution
    if len(changes) > 10:
        print('Received query snapshot for more than 10 changes, assuming it is first update')
        return
    for change in changes:
        if change.type.name == 'ADDED':
            print(u'Calculation Done: {}'.format(change.document.id))
            session_id = change.document.id
            data = get_calculate_done_details(change.document.id)
            update_session_status(session_id,'pending_swipes')
            socketio.emit('calculation_result',data,room=session_id)


col_query = db.collection(u'sessions').where(u'calculate', u'==', u'done')

# Watch the collection query
query_watch = col_query.on_snapshot(on_snapshot)

@app.route('/session/<session_id>/results_display')
def results_display(session_id):
    checkHost = request.args['isHost']
    if checkHost == 'true':
        return render_template('Geoloc.html', session_id = session_id, ifHost=True)
    else:
        return render_template('Geoloc.html', session_id = session_id, ifHost=False)

@app.route('/session/get', methods = ['GET'])
def get_user_sessions():
    if 'username' in request.args:
        # print("this is username args: " + request.args["username"])
        # print("doing query...")
        data = db.collection(u'userData').document(request.args["username"]).get().to_dict()
        # print("finished query!")
        # print(data["sessionId"])
        sessionIdDict = { i : i for i in data["sessionId"]}
        return sessionIdDict

    else:
        return jsonify({'error':'no username is provided.'})

#Room joining function
@socketio.on('join')
def on_join(data):

    #Verify the data is in the correct format
    schema_str = """
    {
         "room":str
    }
    """
    result = check_dict_correct_format(data,schema_str)
    if result != "":
        emit("Error",result)

    room= data['room']
    join_room(room)
    emit('join_ack',{'message':'Someone has joined the room',
                     'room':room},room=room)

@socketio.on('swipe_details')
def on_swipe_details(data):
    #Verify the data is in the correct format
    schema_str = """
    {"sessionID": str,
    "swipeIndex": int,
    "userIdentifier": str,
    "selection":bool}
    """
    result = check_dict_correct_format(data,schema_str)
    if result != "":
        emit("Error",result)

    #Update firebase with the swipe details for that particular room
    sessionID = data['sessionID']
    swipeIndex = data['swipeIndex']
    userIdentifier = str(data['user'])
    selection = bool(strtobool(data['selection']))
    doc_ref = get_doc_ref_for_id(sessionID)
    try:
        #Update the session with the new details
        swipe_details = doc_ref.get().get('swipe_details')
        if swipeIndex == len(swipe_details):
            swipe_details.append(
                {userIdentifier:selection}
                )
        elif swipeIndex < len(swipe_details):
            swipe_details[swipeIndex][userIdentifier] = selection
        else:
            print("Warning: Someone's swipe index is more than 2 greater than the swipe details")

        #Check if all the members of the session have agreed on a place
        number_of_meetup_members = len(doc_ref.get().get('info')['users'])
        for swipe_detail_index,swipe_detail in enumerate(swipe_details):
            values = swipe_detail.values()
            if len(values) < number_of_meetup_members:
                break
            if False not in swipe_detail.values():
                #We have found a place everyone agreed on!
                update_session_status('location_confirmed')
                socketio.emit('location_found',{'swipeIndex':swipe_detail_index},room=sessionID)

    except KeyError:
        #Create the session details
        swipe_details = [{userIdentifier:selection}]

    doc_ref.update({'swipe_details':swipe_details})

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

def get_details_for_session_id(session_id):
    try:
        doc_ref = get_doc_ref_for_id(session_id)
        return doc_ref.get().to_dict()['info']
    except:
        return 'Error'

def insert_user_details(details,session_id):
    try:
        doc_ref = get_doc_ref_for_id(session_id)
        doc_dict = doc_ref.get().to_dict()
        doc_dict['info']['users'].append(details)
        doc_ref.set(doc_dict)

        update_userdata_sessionid(details,session_id)
    except:
        return "Error"

def update_session_status(session_id,status):
    doc_ref = get_doc_ref_for_id(session_id)
    data = doc_ref.get('info').to_dict()
    data['session_status'] = status
    doc_ref.update({'info':data})


def create_firebase_session(content):
    meetup_name = content.pop('meetup_name')
    meeting_type = content.pop('meeting_type')
    host_user_details = content
    session_id = str(uuid.uuid1())
    time_created = str(datetime.datetime.now())

    #Consolidate the session details
    details = {'users':[host_user_details],
               'meeting_type':meeting_type,
               'time_created':time_created,
               'meetup_name':meetup_name,
               'host_uuid':host_user_details['uuid']}

    #Generate session id
    session_id = str(uuid.uuid1())

    #Upload the user's details
    doc_ref = get_doc_ref_for_id(session_id)
    doc_ref.set({'info':details})

    #Update the session status
    update_session_status(session_id,'pending_members')

    #Update userData sessionId
    update_userdata_sessionid(host_user_details,session_id)

    #Return the session id
    return session_id

def get_doc_ref_for_id(session_id):
    session_id = str(session_id)
    return db.collection(u'sessions').document(session_id)

def update_userdata_sessionid(details,session_id):
    #Update userData sessionId
    if 'username' in details:
        username = details["username"]
    elif 'identifier' in details:
        username = details["identifier"]

    data = db.collection(u'userData').document(username).get().to_dict()

    if data is None:
        data = {}
    if 'sessionId' in data:
        data['sessionId'].append(session_id)
    else:
        data["sessionId"] = [session_id]

    db.collection(u'userData').document(username).set(data)

def send_bug_report(content):
    report = {
        u'content': content,
        u'timestamp': firestore.SERVER_TIMESTAMP
    }
    database = firestore.client()
    database.collection(u'bugReports').add(report)

if __name__ == '__main__':


    # #--------------------------------------CONNECT TO DATABASE-------------------------------
    #Run the App
    socketio.run(app,host='0.0.0.0', debug=True, use_reloader=False,port = 5000)
    # app.run(host='0.0.0.0', debug=True, use_reloader=False)
