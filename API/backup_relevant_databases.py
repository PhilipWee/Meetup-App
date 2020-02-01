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

#--------------------------------------CREATE BACKUP ENGINE-------------------------------
from sqlalchemy import create_engine
engine_backup = create_engine('postgresql://postgres:housepotato@localhost:5432/gisdb_bak')
#--------------------------------------CREATE BACKUP ENGINE-------------------------------

print('Downloading databases')
#Get the unique bus stops
try:
    bus_routes_locations = pd.read_sql('select * from bus_routes_locations',conn_gis)
    mrt_map_edges = pd.read_sql('select * from mrt_map_edges',conn_gis)
    singapore_restaurants_2 = pd.read_sql('select * from singapore_restaurants_2',conn_gis)
    outing_data = pd.read_sql('select * from outing_data',conn_gis)
    osm_2po_4pgr = pd.read_sql('select * from osm_2po_4pgr_no_geom',conn_gis)
except:
    print('Database doesnt exist, you need to load the spydata file!')

print('Uploading databases')
#Upload the relevant databases

bus_routes_locations.to_sql('bus_routes_locations',engine_backup,if_exists = 'replace')
mrt_map_edges.to_sql('mrt_map_edges',engine_backup,if_exists = 'replace')
singapore_restaurants_2.to_sql('singapore_restaurants_2',engine_backup,if_exists = 'replace')
outing_data.to_sql('outing_data',engine_backup,if_exists = 'replace')
osm_2po_4pgr.to_sql('osm_2po_4pgr',engine_backup,if_exists = 'replace')


print('done')





