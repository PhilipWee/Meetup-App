

#--------------------------------------REQUIREMENTS--------------------------------------
from flask import Flask,jsonify,request,abort, redirect, url_for,render_template
from flask_dance.contrib.github import make_github_blueprint, github
from flask_cors import CORS
from bs4 import BeautifulSoup
import re
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
import sys
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium import webdriver
from selenium.webdriver.common import keys
from webdriver_manager.chrome import ChromeDriverManager
from firebase_admin import credentials
from firebase_admin import firestore
from onemapsg import OneMapClient
from sqlalchemy import create_engine
import pprint
#--------------------------------------REQUIREMENTS--------------------------------------

#--------------------------------------SETTINGS--------------------------------------
NUMBER_OF_RESULTS = 20
DEBUG_MODE = True
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

def quit_if_debug():
    if DEBUG_MODE == True:
        sys.exit()
    else:
        pass

#--------------------------------------CONNECT TO DATABASE-------------------------------
# Set up a connection to the postgres server.

try:
    print("Connecting to the data database")
    conn_string = "host="+ creds.PGHOST +" port="+ "5432" +" dbname="+ creds.PGDATADATABASE +" user=" + creds.PGUSER \
    +" password="+ creds.PGPASSWORD
    data_conn=psycopg2.connect(conn_string)
    print("Connected!")
    crsr = data_conn.cursor()
except:
    raise Exception("Unable to connect to the food blog data database, check postgres is running and IP address is correct")
try:
    db_string = creds.PGUSER+"://"+creds.PGUSER+":"+creds.PGPASSWORD+"@"+creds.PGHOST+":5432/data"
    data_engine = create_engine(db_string)
except:
    pass
#--------------------------------------CONNECT TO DATABASE-------------------------------
    
#Get the one map api
Client = OneMapClient(creds.ONEMAPEMAIL,creds.ONEMAPPASSWORD)

def add_food_place(name,writeup,postal_code,address,operating_hours,pictures_url_arr,cost_per_pax,rating,food_place_link):
    data_conn.rollback()
    if cost_per_pax is not None:  
        cost_per_pax = str(cost_per_pax)
    if rating is not None:
        rating = str(rating)
    loc_details = Client.search(postal_code)
    long = loc_details['results'][0]['LONGITUDE']
    lat = loc_details['results'][0]['LATITUDE']
    pictures_url_str = '{' + ','.join(pictures_url_arr) + '}'
    crsr = data_conn.cursor()
    crsr.execute("INSERT INTO food_blog_places (name,writeup,postal_code,lat,long,address,operating_hours,pictures_url,cost_per_pax,rating,food_place_link) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s);",
                 (name,writeup,postal_code,lat,long,address,operating_hours,pictures_url_str,cost_per_pax,rating,food_place_link))
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
driver = webdriver.Chrome(ChromeDriverManager().install())
driver.get("https://sethlui.com/singapore/food/")
assert "SETHLUI" in driver.title
#If the annoying popup comes click on it
popups_close = WebDriverWait(driver,10).until(
            EC.presence_of_all_elements_located((By.XPATH,"//a[@class='spu-close spu-close-popup spu-close-top_right']")))
if len(popups_close) > 0:
    for popup_close in popups_close:
        popup_close.click()
#End annoying popup
filter_buttons = driver.find_elements_by_class_name('filter-option')
filter_buttons[2].click()
cafe_button = driver.find_element_by_id('cafes')
cafe_button.click()
filterSubmit = driver.find_element_by_id('filterSubmit')
filterSubmit.click()

cafe_links = []

while True:
    #repeat this script for every food page
    try:
        food_place_urls = WebDriverWait(driver,10).until(
            EC.presence_of_all_elements_located((By.XPATH,"//div[@id='latestPosts']/div/a")))
    except:
        print('Driver Quitting')
        driver.quit()
    cur_page_cafe_links = [food_place_url.get_attribute('href') for food_place_url in food_place_urls]
    cafe_links = cafe_links + cur_page_cafe_links
    
    try:
        next_button = WebDriverWait(driver,10).until(
            EC.element_to_be_clickable((By.XPATH,"(//a[@class='paging__arrow'])[2]")))
        next_button.click()
    except:
        break

cafe_links = list(dict.fromkeys(cafe_links))

cafe_link = "https://sethlui.com/plus-eight-two-cafe-korean-bingsu-singapore/"

def get_cafe_details_from_webpage(cafe_link):
    #Now that we have each page we need to get the data from each of them
    driver.get(cafe_link)
    wait = WebDriverWait(driver,3)
    try:
        name_element = wait.until(
            EC.presence_of_element_located((By.XPATH,"//div[@class='desktop']/h4")))
        name = name_element.text
    except:
        try:
            name_element = wait.until(
            EC.presence_of_element_located((By.XPATH,"//h1")))
            name = name_element.text.split(':')[0]
        except:
            print("Unable to get data for " + cafe_link + " it is probably a different format.")
            return None
    wait = WebDriverWait(driver,1)
    try:
        write_up_elements = wait.until(
            EC.presence_of_all_elements_located((By.XPATH,"//span[@style='font-weight: 400;']")))
    except:
        #The write up elements are stored in a different format
        write_up_elements = driver.find_elements_by_xpath("//div[@class='col-md-6 article__post responsive-iframe-video']/p")
    write_ups = [write_up_element.text for write_up_element in write_up_elements]
    write_up = ' '.join(write_ups)
    try:
        #The new seth lui format
        address_element = driver.find_element_by_xpath("//div[@class='desktop']/p")
        address,postal_code = address_element.text.split(', Singapore ')
        operating_hours_element = driver.find_element_by_xpath("//div[@class='review-meta desktop']")
        operating_hours = operating_hours_element.text
    except:
        #the old seth lui format
        try:
            info_element = driver.find_element_by_xpath("//div[@class='col-md-6 article__post responsive-iframe-video']/h3")
            address_and_postal = info_element.text.split('|')[0].split(':')[1]
            address,postal_code=  address_and_postal.split(', Singapore ')
            operating_hours = info_element.text.split('|')[2].strip()
        except:
            print('Unable to get address for ' + cafe_link + ' assuming its overseas and continuing')
            quit_if_debug()
            return None
    if operating_hours == "":
        print('Operating hours are empty for ' + cafe_link)
        quit_if_debug()
    img_elements = driver.find_elements_by_css_selector("img[class^='alignnone size-full']")
    if len(img_elements)==0:
        #Another image format
        img_elements = driver.find_elements_by_css_selector("img[class$='size-large']")
    img_urls = [img_element.get_attribute('src') for img_element in img_elements]
    try:
        cost_per_pax = re.split('Expected Damage:',write_up, flags = re.IGNORECASE)[1].strip()
    except:
        
        try: 
            cost_per_pax = re.split('Prices:',write_up, flags = re.IGNORECASE)[1].strip()
            
        except:
            try: 
            cost_per_pax = re.split('Price:',write_up, flags = re.IGNORECASE)[1].strip()
            except:
                cost_per_pax = None
                print('Unable to get cost for ' + cafe_link)
                quit_if_debug()
        
    try:
        rating_element = driver.find_element_by_css_selector("span[style^='font-size:11px; color:#888;font-weight:bold;']")
        rating = rating_element.text.split('/')[0]
    except:
        rating = None
        print('Unable to get rating for ' + cafe_link)
        quit_if_debug()
    address = address.strip()
    postal_code = postal_code.strip()
    food_place_link = cafe_link
    return [name,write_up,postal_code,address,operating_hours,img_urls,cost_per_pax,rating,food_place_link]

#Final execute loop
for cur_iteration,cafe_link in enumerate(cafe_links):
    details = get_cafe_details_from_webpage(cafe_link)
    if details is None:
        continue
    else:
        print('Adding food place to postgres for iteration ' + str(cur_iteration) + ' and webpage ' + cafe_link)
        # pprint.pprint(details)
        add_food_place(*details)


cafe_links = cafe_links[6:]

def correct_operating_hrs(op_hrs):
    contains_illegal_words = bool(re.search('Facebook|Website|Tel',op_hrs))
    if contains_illegal_words:
        return ""
    else:
        return op_hrs

def is_not_closed(place_name):
    if bool(re.search('close',place_name)):
        return False
    else:
        return True

#Data cleaning
food_places_df = pd.read_sql('SELECT * FROM food_blog_places',data_conn)
x = [picture_urls != [] for picture_urls in food_places_df['pictures_url']]
food_places_df = food_places_df[x]
food_places_df['operating_hours'] = pd.Series(correct_operating_hrs(op_hrs) for op_hrs in food_places_df['operating_hours'])
x = [is_not_closed(place_name) for place_name in food_places_df['name']]
food_places_df = food_places_df[x]

#Uplaod the cleaned results
food_places_df.to_sql('food_blog_places_clean',data_engine)
