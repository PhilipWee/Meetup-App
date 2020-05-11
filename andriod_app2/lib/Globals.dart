library meetupmouse.globals;
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'socketiohelper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

String serverAddress = "http://ec2-3-14-68-232.us-east-2.compute.amazonaws.com:5000";

String userLocationName = "Jalan Membina, Singapore";

CustomSocketIO socketIO = CustomSocketIO(serverAddress);

Map<String,dynamic> tempData = {
  "meetupname" : "",
  "meetingType": 0,
  "sessionid" : 0,
  "link" : "",
  "username" : "",
  "userplace" : "",
  "lat" : 0.0,
  "long" : 0.0,
  "transportMode" : "",
  "quality" : 0,
  "price" : 0,
  "speed" :0,
};

Map<String,dynamic> userGoogleData = {
  "name" : "Stephen",
};

void saveMyLocationName() async{
  var location = Location();
  LocationData currentLocation = await location.getLocation();
  double mylat = currentLocation.latitude;
  double mylong = currentLocation.longitude;
  print("User's Current Coordinates: $mylat,$mylong");
  List<Placemark> myplacemark = await Geolocator().placemarkFromCoordinates(mylat,mylong);
  Placemark placeMark = myplacemark[0];
  String name = myplacemark[0].thoroughfare.toString();
  String locality = placeMark.locality;
  String myLocationName = "$name, $locality";
  print("User's Current Location $myLocationName." );
  userLocationName = myLocationName;
}

Future<String> getplacefromcoor(double givenlat, double givenlong) async{
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
