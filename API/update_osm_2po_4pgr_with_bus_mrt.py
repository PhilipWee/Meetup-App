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

public_edges_2_df = pd.read_sql('select * from public_edges_2',conn_gis)
osm_2po_4pgr_sample_df = pd.read_sql('select * from osm_2po_4pgr limit 10', conn_gis)

#We need to add the id, osm_id, osm_name,
# osm_meta, osm_source_id, osm_target_id, clazz, flags,
# source, target,km,kmh,cost,reverse_cost,x1,y1,x2,y2,geom_way
#,road_start,group_id,closest_outing_node,closest_restaurant_node

