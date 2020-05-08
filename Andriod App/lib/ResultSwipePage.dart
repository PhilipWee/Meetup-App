import 'dart:convert';
import 'dart:math';

import 'ShareLinkPage.dart';
import 'color_loader.dart';
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

//Fake Images to generate cards
// TODO: Get images and info of the results
List fakeImg = [
  Image.asset("images/bikinibottom.jpg"),
  Image.asset("images/zoo.jpg"),
  Image.asset("images/backyard.jpg"),
  Image.asset("images/sanf.jpg"),];

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
      fakeImg.remove(item);
      selectedCards.add(item);
    });
  }

  _dismissCard(dynamic item) {
    // TODO: Communicate to backend it's a NO
    setState(() {
      fakeImg.remove(item);
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

    return Scaffold(
      body: Container(
        child: fakeImg.length == 0
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
                children: fakeImg.map((item) {
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
                            item,
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