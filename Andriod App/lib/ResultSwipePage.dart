import 'dart:convert';
//import 'dart:html';
import 'dart:math';

import 'ShareLinkPage.dart';
import 'color_loader.dart';
import 'package:getflutter/getflutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity/connectivity.dart';
import 'Data.dart';
import 'package:http/http.dart' as http;

class ResultSwipePage extends StatelessWidget {

  final PrefData data;
  ResultSwipePage({this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose a Place!"),
      ),
      body: ResultSwipeWidget(data: data),
    );
  }
}

class ResultSwipeWidget extends StatefulWidget{
  final PrefData data;
  ResultSwipeWidget({this.data});
  @override
  ResultSwipeState createState() => ResultSwipeState(data: data);
}

//Fake data to generate cards
// TODO: Get actual images and info of the results from database
List myData = [
  fakeData(name: "Krusty Krab",
      address: "999 Bikini Bottom Boulevard",
      details: "Delicious burgers made by a sponge",
      rating: 3,
      images: ["images/bikinibottom.jpg", "images/food.jpg",]),
  fakeData(name: "Singapore Zoo",
      address: "123 Mandai Rd",
      details: "Dining for the wild, experience what it's like to be the prey",
      rating: 2,
      images: ["images/zoo.jpg", "images/food.jpg"]),
  fakeData(name: "Chez Platypus",
      address: "33 Tri-state Area Ave 1",
      details: "MOM! Phineas and Ferb are running a restaurant!",
      rating: 4,
      images: ["images/backyard.jpg", "images/food.jpg"]),
  fakeData(name: "Fisherman's Wharf",
      address: "39 San Francisco Bay Area",
      details: "Fisherman's Wharf @ Pier 39, where you can find the most delicious clam chowder!",
      rating: 5,
      images: ["images/sanf.jpg", "images/sanfrans.jpg", "images/food.jpg"]),
];

//User's selected places
List selectedCards = [];

class ResultSwipeState extends State<ResultSwipeWidget> {
//  var listLen = fakeImg.length;
  final PrefData data;
  ResultSwipeState({this.data});
  List<Color> colorsForLoad = [
    Colors.red,
    Colors.green,
    Colors.indigo,
    Colors.pinkAccent,
    Colors.blue
  ];

  _addCard(dynamic item) {
    setState(() {
      // TODO: Communicate to backend it's a YES
      myData.remove(item);
      selectedCards.add(item);
    });
  }

  _dismissCard(dynamic item) {
    // TODO: Communicate to backend it's a NO
    setState(() {
      myData.remove(item);
    });
  }

  @override
  void initState() {
    // TODO: implement initState (For future, animation of cards swiping)
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;


    //Function to build the carousel for images
    Widget _buildImgCarousel(List images) {
      return Container(
        child: GFCarousel(
          items: images.map((img) {
            return Container(
              child: Image.asset(img, fit: BoxFit.cover,),
            );
          }).toList(),
          height: screen.height*0.6,
          viewportFraction: 1.0,
          pagination: true,
          pagerSize: 8.0,
          passiveIndicator: Colors.grey,
          activeIndicator: Colors.white,
        ),
      );
    }

    return Scaffold(
      body: Container(
        child: myData.length == 0
            ? Container(
                width: screen.width,
                height: screen.height,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ColorLoader(colors: colorsForLoad, duration: Duration(milliseconds: 1200)),
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 10),
                      child: Text("Waiting for results")
                    ),
                  ],
                ),
              )
            : Stack(
                alignment: AlignmentDirectional.center,
                children: myData.map((item) {
                  return Dismissible(
                    key: UniqueKey(),
                    onDismissed: (DismissDirection direction) {
                      if (direction == DismissDirection.endToStart) {
                        _dismissCard(item);
                      } else {
                        _addCard(item);
                      }
                    },
                    child: Card(
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            _buildImgCarousel(item.images),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

}