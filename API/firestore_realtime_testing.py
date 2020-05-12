# -*- coding: utf-8 -*-
"""
Created on Mon May 11 09:24:34 2020

@author: Philip Wee
"""
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
import pprint
import threading
import sys
import signal
#--------------------------------------REQUIREMENTS--------------------------------------


#python "C:\Users\Philip Wee\Documents\Meetup-App\API\firestore_realtime_testing.py"
print('Connecting to firebase')
if (not len(firebase_admin._apps)):

    # Use the application default credentials
    # Use a service account
    cred = credentials.Certificate('C:/Users/Philip Wee/Documents/MeetupAppConfidential/meetup-mouse-265200-2bcf88fc79cc.json')
    firebase_admin.initialize_app(cred)
    db = firestore.client()
else:
    db = firestore.client()
print('Connected!')

#--------------------------------------FIREBASE--------------------------------------

# Create an Event for notifying main thread.
delete_done = threading.Event()

# Create a callback on_snapshot function to capture changes
def on_snapshot(col_snapshot, changes, read_time):
    print(u'Callback received query snapshot.')
    print(u'Current cities in California: ')
    for change in changes:
        if change.type.name == 'ADDED':
            print(u'New city: {}'.format(change.document.id))
        elif change.type.name == 'MODIFIED':
            print(u'Modified city: {}'.format(change.document.id))
        elif change.type.name == 'REMOVED':
            print(u'Removed city: {}'.format(change.document.id))
            delete_done.set()

col_query = db.collection(u'sessions').where(u'calculate', u'==', u'True')

# Watch the collection query
query_watch = col_query.on_snapshot(on_snapshot)
        
if __name__ == '__main__':
    while True:
        time.sleep(2)
        
    


        