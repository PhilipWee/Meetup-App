# -*- coding: utf-8 -*-
"""
Created on Wed Jan 22 09:15:34 2020

@author: Philip
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
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import pprint
#--------------------------------------REQUIREMENTS--------------------------------------

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
    
#--------------------------------------CREATE ENGINE-------------------------------
from sqlalchemy import create_engine
engine = create_engine('postgresql://postgres:housepotato@localhost:5432/gisdb')
#--------------------------------------CREATE ENGINE-------------------------------

print('handling bus route waiting times')
#Get the unique bus stops
bus_routes_locations_2 = pd.read_sql('select * from bus_routes_locations',conn_gis)

unique_transport_no = bus_routes_locations_2['bus_no'].drop_duplicates().values


#waiting_times_df.to_sql('bus_routes_waiting_times',engine,if_exists = 'replace')

#--------------------------------------REPEAT FOR MRT-------------------------------
print('handling mrt routes waiting times')
#Get the unique bus stops
mrt_routes_locations_2 = pd.read_sql('select * from mrt_map_edges',conn_gis)
meow = mrt_routes_locations_2['REF_STNSTART'].apply(lambda s: ''.join(i for i in s if not i.isdigit()))
print(meow)

#waiting_times_df.to_sql('mrt_routes_waiting_times',engine,if_exists = 'replace')
print('done')





