library meetupmouse.globals;
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'socketiohelper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

CustomSocketIO socketIO = CustomSocketIO(serverAddress);

String serverAddress = "http://ec2-3-14-68-232.us-east-2.compute.amazonaws.com:5000";

String uuid = "defaultUser";
String username = "defaultName";
String profileurl = "https://upload-icon.s3.us-east-2.amazonaws.com/uploads/icons/png/19339625881548233621-512.png";

String userLocationName = "defaultLocation";
double phonelat = 0.0;
double phonelong = 0.0;

List templistofmembers = [];

List<dynamic> usersSessionsList = [];

bool isCreator = true;

Map<String, dynamic> tempMeetingDetails = {};

List fakelistofmembers = [
  {
    "identifier" : "identifier",
    "lat" : 0,
    "long" : 0,
    "transport_mode" : "driving",
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

Map<String,dynamic> tempData = {

  "meetupname" : "Default Name",
  "meetingtype": "outing",
  "lat" : 0.0,
  "long" : 0.0,
  "username" : "",
  "userplace" : "",
  "transportmode" : "public",
  "quality" : 1,
  "price" : 1,
  "sessionid" : 01234567,
  "link" : "LinkNotUpdated",
  "joinlink": "",

//    "speed" :0,
}; ///////////////////////////////////////////////////////////////////////////////////////////////////////tempDATA


void resetempData() {
  tempData = {

    "meetupname" : "Default Name",

    "meetingtype": "outing",

    "lat" : 0.0,
    "long" : 0.0,
    "user_place" : "",

    "transportmode" : "public",
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
