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
sources = bus_routes_locations_2[['osm_source_id','bus_no','x1','y1','x2','y2']]
targets = bus_routes_locations_2[['bus_no','osm_target_id','x1','y1','x2','y2']]
targets.columns = ['bus_no','osm_source_id','x1','y1','x2','y2']
unique_bus_stops_osms = pd.concat([sources,targets],sort=True).drop_duplicates()

#Put in the waiting times
waiting_times_df = unique_bus_stops_osms
waiting_times_df['osm_target_id'] = waiting_times_df['osm_source_id'] + 1000000000000
waiting_times_df['transport_type'] = 'bus_boarding_or_unboarding'
waiting_times_df['transport_type_id'] = 'nil'

#Change this part of the function in order to make the waiting times unique per bus
waiting_times_df['cost'] = 5/60

waiting_times_df['reverse_cost'] = 0

waiting_times_df.to_sql('bus_routes_waiting_times',engine,if_exists = 'replace')

#--------------------------------------REPEAT FOR MRT-------------------------------
print('handling mrt routes waiting times')
#Get the unique bus stops
mrt_routes_locations_2 = pd.read_sql('select * from mrt_map_edges',conn_gis)
sources = mrt_routes_locations_2[['osm_source_id','REF_STNSTART','Longitude_Start','Latitude_Start','Longitude_End','Latitude_End']]
sources.columns = ['osm_source_id','mrt_no','x1','y1','x2','y2']
unique_mrt_stops_osms= sources.drop_duplicates()

#Put in the waiting times
waiting_times_df = unique_mrt_stops_osms
waiting_times_df['osm_target_id'] = waiting_times_df['osm_source_id'] + 2000000000000
waiting_times_df['transport_type'] = 'mrt_boarding_or_unboarding'
waiting_times_df['transport_type_id'] = 'nil'

#Change this part of the function in order to make the waiting times unique per bus
waiting_times_df['cost'] = 5/60

waiting_times_df['reverse_cost'] = 0
waiting_times_df['mrt_no'] = waiting_times_df['mrt_no'].apply(lambda s: ''.join(i for i in s if not i.isdigit()))

waiting_times_df.to_sql('mrt_routes_waiting_times',engine,if_exists = 'replace')
print('done')





