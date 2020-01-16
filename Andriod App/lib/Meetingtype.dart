import 'main.dart';
import 'MapPage.dart';
import 'ShareLinkPage.dart';
import 'CustomizationPage.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity/connectivity.dart';
import 'color_loader.dart';


class MeetingType extends StatelessWidget {

  final PrefData data;
  MeetingType({this.data});

  final List<String> custLabels = [
    "Recreation",
    "Food",
    "Meeting",
  ];
  final List<String> custImgs = [
    "images/outing.jpg",
    "images/food.jpg",
    "images/meetingButton.jpg",
  ];

  @override
  //Creates a listview with buildCustomButtons inside
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Meetup Type"),
//        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: custImgs.length,
        itemBuilder: (context, index) {
          return Card(
            child: FlatButton(
              padding: EdgeInsets.all(0.0),
              onPressed: (){
                Navigator.push(context,MaterialPageRoute(builder: (context) => CustomizationPage(data: data)),);
              },
              child:_buildCustomButton(custLabels[index], custImgs[index]) ,
            ),
          );
        },
      ),
    );
  }

  //Helper method to create layout of the buttons
  Container _buildCustomButton(String label, String imgName) {
    return Container(
      height: 200.0,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(imgName),
              fit: BoxFit.cover
          )
      ),
      child: Container(
        height: 50.0,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Colors.black54, Colors.white12],
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        alignment: Alignment.bottomLeft,
        child: Text(
          label,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(0.0),
    );
  }

}