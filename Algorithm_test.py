# import overpy
import requests
import json
import geopy.distance

overpass_url = "http://overpass-api.de/api/interpreter"

#----CONSTANTS----
WALKING_SPEED = 5.0
CYCLING_SPEED = 15.5
DEFAULT_DRIVING_SPEED_LIMIT = 50
DEFAULT_BUS_SPEED_LIMIT_MOTORWAY = 60
DEFAULT_BUS_SPEED_LIMIT_SMALL_ROADS = 50
#----CONSTANTS----


# fetch all ways and nodes
overpass_query = """
[out:json][bbox:1.359023,103.858879,1.372067,103.870828];
(way["highway"="motorway"];
way["highway"="trunk"];
way["highway"="primary"];
way["highway"="secondary"];
way["highway"="tertiary"];
way["highway"="residential"];
way["highway"="motorway_link"];
way["highway"="trunk_link"];
way["highway"="primary_link"];
way["highway"="secondary_link"];
way["highway"="tertiary_link"];
way["highway"="living_street"];
way["highway"="service"];
way["highway"="pedestrian"];
way["highway"="track"];
way["highway"="road"];
way["highway"="residential"];
way["highway"="footway"];);
out geom;
    """

response = requests.get(overpass_url,params={'data':overpass_query})
data = response.json()

# for key in data.keys():
#     print(key)

#We are only interested in the elements, so:
elements = data['elements']

nodes = {}

#Note: We have to make the road gathering function more robust
for element in elements:
    # print(element)
    # print(element['nodes'])
    # print(element['geometry'])
    for index,(node,location) in enumerate(zip(element['nodes'],element['geometry'])):
        if node not in nodes:
            #Initialise the node with default values
            nodes[node] = {}
            nodes[node]['location'] = location
            nodes[node]['neighbours'] = []
            nodes[node]['walkable'] = False
            nodes[node]['drivable'] = False
        #Check for speed limits and accessibility

        #Add the neighboring nodes as connection
        new_neighbour_before = {'node':element['nodes'][index-1:index]}
        new_neighbour_after = {'node':element['nodes'][index+1:index+2]}
        new_neighbour_before['direction'] = 'both'
        new_neighbour_after['direction'] = 'both'
        #If it exists append, if its one way enter details
        if element['nodes'][index-1:index] != []:
            if "oneway" in element['tags'].keys():
                if element['tags']['oneway'] == 'yes':
                    new_neighbour_before['direction'] = 'from'
            nodes[node]['neighbours'].append(new_neighbour_before)

        if element['nodes'][index+1:index+2] != []:
            if "oneway" in element['tags'].keys():
                if element['tags']['oneway'] == 'yes':
                    new_neighbour_after['direction'] = 'to'
            nodes[node]['neighbours'].append(new_neighbour_after)

        #Get the different max driving speeds for the location
        if 'maxspeed' in element['tags']:
            nodes[node]['maxspeed'] = int(element['tags']['maxspeed'])
        else:
            nodes[node]['maxspeed'] = DEFAULT_DRIVING_SPEED_LIMIT
        #Check if it is walkable (As long as one connection is not the highway, it's walkable)
        if element['tags']['highway'] != 'motorway':
            nodes[node]['walkable'] = True
        #Check if it is drivable
        if element['tags']['highway'] not in ['residential','footway']:
            nodes[node]['drivable'] = True

#Get the lengths and time travelled inbetween nodes
for node1,node1_details in nodes.items():
    coord1 = (node1_details['location']['lat'],node1_details['location']['lon'])
    for node2s in node1_details['neighbours']:
        for node2 in node2s['node']:
            node2_details = nodes[node2]
            coord2 = (node2_details['location']['lat'],node2_details['location']['lon'])
            #Apply attributes here to store the values
            node2s['distance'] = geopy.distance.geodesic(coord1,coord2)
            node2s['bus time'] =
            node2s['walk time']
            node2s['mrt time']
            node2s[' time']

length_dict = {}
for node_no,node in nodes.items():
    if len(node['neighbours']) not in length_dict:
        length_dict[len(node['neighbours'])] =  1
    else:
        length_dict[len(node['neighbours'])] += 1
# print(nodes)
# print(length_dict)

import numpy as np
import pylab as pl
import matplotlib.pyplot as plt
from matplotlib import collections as mc

lines = []

#Visualisation
for node1,node1_details in nodes.items():
    coord1 = (node1_details['location']['lon'],node1_details['location']['lat'])
    for node2s in node1_details['neighbours']:
        # print(11111111111111111111111111,node2s)
        for node2 in node2s['node']:
            node2_details = nodes[node2]
            coord2 = (node2_details['location']['lon'],node2_details['location']['lat'])
            lines.append([coord2,coord1])



lc = mc.LineCollection(lines, linewidths=2)

fig, ax = pl.subplots()
ax.add_collection(lc)
ax.autoscale()
ax.margins(0.1)



plt.show()



# for way in result.ways:
#     print(way)
