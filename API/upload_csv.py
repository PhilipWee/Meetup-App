import pandas as pd
import credentials as creds
import psycopg2

from sqlalchemy import create_engine
engine = create_engine('postgresql://postgres:housepotato@localhost:5432/gisdb')

print("Connecting to routing database")
conn_string = "host="+ creds.PGHOST +" port="+ "5432" +" dbname="+ creds.PGROUTINGDATABASE +" user=" + creds.PGUSER \
+" password="+ creds.PGPASSWORD
conn_gis=psycopg2.connect(conn_string)
print("Connected!")
crsr_gis = conn_gis.cursor()

data = pd.read_csv('D:/restaurant_data.csv')
print(data.head())

data.to_sql('singapore_restaurants_2',engine)
print('done!')