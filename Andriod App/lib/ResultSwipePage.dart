import 'dart:convert';
//import 'dart:html';
import 'dart:math';

import 'Details.dart';
import 'Data.dart';
import 'color_loader.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity/connectivity.dart';
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
      rating: 3.0,
      images: ["images/bikinibottom.jpg", "images/food.jpg",]),
  fakeData(name: "Singapore Zoo",
      address: "123 Mandai Rd",
      details: "Dining for the wild, experience what it's like to be the prey",
      rating: 3.2,
      images: ["images/zoo.jpg", "images/food.jpg"]),
  fakeData(name: "Chez Platypus",
      address: "33 Tri-state Area Ave 1",
      details: "MOM! Phineas and Ferb are running a restaurant!",
      rating: 4.3,
      images: ["images/backyard.jpg", "images/food.jpg"]),
  fakeData(name: "Fisherman's Wharf",
      address: "39 San Francisco Bay Area",
      details: "Fisherman's Wharf @ Pier 39, where you can find the most delicious clam chowder!",
      rating: 4.6,
      images: ["images/sanf.jpg", "images/sanfrans.jpg", "images/food.jpg"]),
];

//User's selected places
List selectedCards = [];

//Build the individual card description
class _Description extends StatelessWidget {
  const _Description({
    Key key,
    this.name,
    this.address,
  }) : super(key: key);

  final String name;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
            maxLines: 2,
            overflow: TextOverflow.fade,
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          Text(
            address,
            style: const TextStyle(fontSize: 12.0),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
        ],
      ),
    );
  }
}

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
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;

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
                    crossAxisEndOffset: -0.25,
                    onDismissed: (DismissDirection direction) {
                      if (direction == DismissDirection.endToStart) {
                        _dismissCard(item);
                      } else {
                        _addCard(item);
                      }
                    },
                    child: Hero(
                        tag: item.name,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Details(item: item,)));
                          },
                          child: Card(
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(0))
                            ),
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    flex: 12,
                                    child: Container(
                                      child: Image.asset(item.images[0], fit: BoxFit.cover,),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 4,
                                          child: Padding(
                                              padding: const EdgeInsets.only(left:10.0, top: 20.0, bottom: 15, right: 20.0),
                                              child: _Description(name: item.name, address: item.address,)
                                          ),
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.only(right: 10.0),
                                              alignment: Alignment.centerRight,
                                              child: RatingBarIndicator(
                                                rating: item.rating,
                                                itemBuilder: (context, index) => Icon(
                                                  Icons.star,
                                                  color: Colors.black,
                                                ),
                                                itemCount: 5,
                                                itemSize: 18,
                                              ),
                                            )
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

}