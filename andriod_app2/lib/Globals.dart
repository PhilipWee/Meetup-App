library meetupmouse.globals;
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'socketiohelper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

String serverAddress = "http://ec2-3-14-68-232.us-east-2.compute.amazonaws.com:5000";

CustomSocketIO socketIO = CustomSocketIO(serverAddress);

Map<String, dynamic> tempMeetingDetails = {};

Map<String,dynamic> tempData = {

  "meetupname" : "Default Name",
  "meetingtype": "Recreation",

  "lat" : 0.0,
  "long" : 0.0,
  "username" : "",
  "userplace" : "",

  "transportmode" : "Public Transit",
  "quality" : 1,
  "price" : 1,


  "sessionid" : 01234567,
  "link" : "LinkNotUpdated",
  "joinlink": "",

//    "speed" :0,
}; //tempDATA

String uuid = "defaultUser";
String username = "defaultName";

String userLocationName = "defaultLocation";
double phonelat = 0.0;
double phonelong = 0.0;

void resetempData() {
  tempData = {

    "meetupname" : "Default Name",

    "meetingtype": "Recreation",

    "lat" : 0.0,
    "long" : 0.0,
    "userplace" : "",

    "transportmode" : "Public Transit",
    "quality" : 1,
    "price" : 0,

    "sessionid" : 01234567,
    "link" : "CreationLinkNotUpdated",
    "joinlink": "JoinLinkNotUpdated",

    "speed" :0, //not used anymore but just send anyway
  };
  print("tempData reset!");
}

void saveMyLocationName() async{
  var location = Location();
  LocationData currentLocation = await location.getLocation();

  phonelat = currentLocation.latitude;
  phonelong = currentLocation.longitude;

  print("User's Current Coordinates: $phonelat,$phonelong");
  List<Placemark> myplacemark = await Geolocator().placemarkFromCoordinates(phonelat,phonelong);
  Placemark placeMark = myplacemark[0];
  String name = myplacemark[0].thoroughfare.toString();
  String locality = placeMark.locality;
  String myLocationName = "$name, $locality";
  print("User's Current Location $myLocationName." );

  userLocationName = myLocationName;
}

Future<String> getplacefromlatlong(double givenlat, double givenlong) async{
  var location = Location();
  LocationData currentLocation = await location.getLocation();
  double lat = givenlat;
  double long = givenlong;
  print("Member Coordinates: $lat,$long");
  List<Placemark> myplacemark = await Geolocator().placemarkFromCoordinates(lat,long);
  Placemark placeMark = myplacemark[0];
  String name = myplacemark[0].thoroughfare.toString();
  String locality = placeMark.locality;
  String memberLocationName = "$name, $locality";
  print("Member Location $memberLocationName." );
  return memberLocationName;
}

class fakeData {
  String name;
  String address;
  String details;
  double rating;
  List images;

  fakeData({this.name, this.address, this.details, this.rating, this.images});

  Map<String,dynamic> get dataMap {
    return {
      "name" : name,
      "address" : address,
      "details" : details,
      "rating" : rating,
      "images" : images,
    };
  }
} //for swipe page

List fakelistofmembers = [
  {
    "identifier" : "identifier",
    "lat" : 0,
    "long" : 0,
    "transport_mode" : "Driving",
    "metrics" : {"speed":0, "quality":0, "price":0}
  },
  {
    "identifier" : "Julia Chua",
    "lat" : 1.332319,
    "long" : 103.672113,
    "transport_mode" : "Driving",
    "metrics" : {"speed":0, "quality":0, "price":0}
  },
  {
    "identifier" : "David Fan",
    "lat" : 1.332319,
    "long" : 103.672113,
    "transport_mode" : "Driving",
    "metrics" : {"speed":0, "quality":0, "price":0}
  },
];

List templistofmembers = [];

List usersSessionsList = [];

bool isCreator = true;