#--------------------------------------REQUIREMENTS--------------------------------------
from flask import Flask,jsonify,request,abort, redirect, url_for,render_template
from flask_dance.contrib.github import make_github_blueprint, github
from flask_cors import CORS
from flask_socketio import SocketIO
from flask_socketio import emit, send
from flask_socketio import join_room, leave_room
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

app = Flask(__name__)
socketio = SocketIO(app)


@app.route('/', methods=['POST', 'GET'])
def index():
    #A placeholder to check if the website is working
    if request.method == 'GET':
        return render_template('mainpage.html')
    

@socketio.on('send_message')
def handle_message(data):
    print(data)
    emit('receive_message', data, broadcast = True)
    print('connect')

@socketio.on('send_test')
def testing(data):
    print(data)
    room = data['room']
    join_room(room)
    print(1111111111111111)
    emit('test',{'message':'Oi youre in the room'},room='1111')
    emit('receive_message', data, broadcast = True)
    print('connect')

#Testing function for joining a room based on sess id
@socketio.on('join')
def on_join(data):
    print('Hello there')
    room= data['room']
    join_room(room)
    emit('test',{'message':'Oi youre in the room'},room='1111')

    
if __name__ == '__main__':
    #--------------------------------------CONNECT TO FIREBASE-------------------------------
    print('Connecting to firebase')
    if (not len(firebase_admin._apps)):
        
        # Use the application default credentials
        # Use a service account
        # cred = credentials.Certificate('/Users/vedaalexandra/Desktop/meetup-mouse-265200-2bcf88fc79cc.json')
        cred = credentials.Certificate('C:/Users/Philip Wee/Documents/MeetupAppConfidential/meetup-mouse-934d0-firebase-adminsdk-txqu5-9b67a90c2c.json')
        firebase_admin.initialize_app(cred)
        db = firestore.client()
    else:
        db = firestore.client()
    print('Connected!')
    #--------------------------------------CONNECT TO FIREBASE-------------------------------

    # #--------------------------------------CONNECT TO DATABASE-------------------------------
    #Run the App
    socketio.run(app,host='0.0.0.0',debug=True, use_reloader=False,port = 5000)
    # app.run(host='0.0.0.0', debug=True, use_reloader=False)
