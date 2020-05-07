

#--------------------------------------REQUIREMENTS--------------------------------------
from flask import Flask,jsonify,request,abort, redirect, url_for,render_template
from flask_dance.contrib.github import make_github_blueprint, github
from flask_cors import CORS
from bs4 import BeautifulSoup
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
import requests
from firebase_admin import credentials
from firebase_admin import firestore
from onemapsg import OneMapClient
import pprint
#--------------------------------------REQUIREMENTS--------------------------------------

#--------------------------------------SETTINGS--------------------------------------
NUMBER_OF_RESULTS = 20
#--------------------------------------SETTINGS--------------------------------------

#--------------------------------------CONNECT TO FIREBASE-------------------------------
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
#--------------------------------------CONNECT TO FIREBASE-------------------------------

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
try:
    print("Connecting to the data database")
    conn_string = "host="+ creds.PGHOST +" port="+ "5432" +" dbname="+ creds.PGDATADATABASE +" user=" + creds.PGUSER \
    +" password="+ creds.PGPASSWORD
    data_conn=psycopg2.connect(conn_string)
    print("Connected!")
    crsr = conn.cursor()
except:
    raise Exception("Unable to connect to the food blog data database, check postgres is running and IP address is correct")
#--------------------------------------CONNECT TO DATABASE-------------------------------
    
#Get the one map api
Client = OneMapClient(creds.ONEMAPEMAIL,creds.ONEMAPPASSWORD)

def add_food_place(name,writeup,postal_code,address,operating_hours,pictures_url_arr,cost_per_pax,rating):
    data_conn.rollback()
    cost_per_pax = str(cost_per_pax)
    rating = str(rating)
    loc_details = Client.search(postal_code)
    long = loc_details['results'][0]['LONGITUDE']
    lat = loc_details['results'][0]['LATITUDE']
    pictures_url_str = '{' + ','.join(pictures_url_arr) + '}'
    crsr = data_conn.cursor()
    crsr.execute("INSERT INTO food_blog_places (name,writeup,postal_code,lat,long,address,operating_hours,pictures_url,cost_per_pax,rating) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s);",
                 (name,writeup,postal_code,lat,long,address,operating_hours,pictures_url_str,cost_per_pax,rating))
    data_conn.commit()

# add_food_place('THE FOOD PEEPS',
#                'The Food Peeps: Rendang Toast & Peanut Butter Jelly Waffles With Delivery From Tanjong Pagar',
#                "069113",
#                "20 Maxwell Road, Maxwell House, #01-11",
#                "8am - 4pm (Mon to Fri), 8am - 3pm (Sat & Sun)",
#                ['https://sethlui.com/wp-content/uploads/2020/04/The-Food-Peeps-1.jpg',
#                 'https://sethlui.com/wp-content/uploads/2020/04/The-Food-Peeps-1.jpg',
#                 'https://sethlui.com/wp-content/uploads/2020/04/The-Food-Peeps-2.jpg',
#                 'https://sethlui.com/wp-content/uploads/2020/04/The-Food-Peeps-3.jpg',
#                 'https://sethlui.com/wp-content/uploads/2020/04/The-Food-Peeps-4.jpg',
#                 'https://sethlui.com/wp-content/uploads/2020/04/The-Food-Peeps-5.jpg',
#                 'https://sethlui.com/wp-content/uploads/2020/04/The-Food-Peeps-6.jpg',
#                 'https://sethlui.com/wp-content/uploads/2020/04/The-Food-Peeps-7.jpg']
#                ,25
#                ,4)
# add_food_place('Crown Bakery & Cafe',
#                'New Additions Like Prawn Bisque Pasta & Berries Mille Feuille at Crown Centre',
#                "269694",
#                "557 Bukit Timah Road, Crown Centre, #01-03",
#                "Operating Hours: 7.30am - 6.30pm (Daily)",
#                ['https://sethlui.com/wp-content/uploads/2020/04/Crown-Bakery-and-Cafe.jpg',
#                 'https://sethlui.com/wp-content/uploads/2020/04/Crown-Bakery-and-Cafe-1.jpg',
#                 'https://sethlui.com/wp-content/uploads/2020/04/Crown-Bakery-and-Cafe-2.jpg',
#                 'https://sethlui.com/wp-content/uploads/2020/04/Crown-Bakery-and-Cafe-3.jpg',
#                 'https://sethlui.com/wp-content/uploads/2020/04/Crown-Bakery-and-Cafe-4.jpg',
#                 'https://sethlui.com/wp-content/uploads/2020/04/Crown-Bakery-and-Cafe-5.jpg',
#                 'https://sethlui.com/wp-content/uploads/2020/04/Crown-Bakery-and-Cafe-6.jpg',
#                      ]
#                ,20
#                ,4)
    
#Scraping code for sethlui.com
URL = "https://sethlui.com/singapore/food/"
page = requests.get(URL)
