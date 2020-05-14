import 'dart:convert';
//import 'dart:html';
import 'dart:math';
import 'Details.dart';
import 'color_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'Globals.dart' as globals;

//Fake data to generate cards
// TODO: Get actual images and info of the results from database

List swipeData = [
  globals.fakeData(name: "Krusty Krab",
      address: "999 Bikini Bottom Boulevard",
      details: "Delicious burgers made by a sponge",
      rating: 3.0,
      images: ["https://marcusgohmarcusgoh.com/wp/wp-content/uploads/2017/03/GE-Maths00003.jpg",
        "https://media.tenor.com/images/efb52cc0e4b02ac8c5d0d71e659df8f4/tenor.png",]),
  globals.fakeData(name: "Singapore Zoo",
      address: "123 Mandai Rd",
      details: "Dining for the wild, experience what it's like to be the prey",
      rating: 3.2,
      images: ["https://blog.headout.com/wp-content/uploads/2018/10/Singapore-Zoo-Breakfast-With-Orangutans-e1539864638230-1200x900.jpg",
        "https://pix10.agoda.net/hotelImages/9643334/-1/8a2bfba69eb9d639885182e5cc9e6c07.jpg"]),
  globals.fakeData(name: "Chez Platypus",
      address: "33 Tri-state Area Ave 1",
      details: "MOM! Phineas and Ferb are running a restaurant!",
      rating: 4.3,
      images: ["https://vignette.wikia.nocookie.net/phineasandferb/images/0/0d/Chez_Platypus.jpg/revision/latest?cb=20090717044333",
        "https://vignette.wikia.nocookie.net/phineasandferb/images/f/fd/Romance_at_last.jpg/revision/latest?cb=20120701091616"]),
  globals.fakeData(name: "Fisherman's Wharf",
      address: "39 San Francisco Bay Area",
      details: "Fisherman's Wharf @ Pier 39, where you can find the most delicious clam chowder! Visit the old-fashioned arcade with only mechanical games while you are there as well!",
      rating: 4.6,
      images: ["https://irepo.primecp.com/2015/07/230563/Fishermans-Wharf-Clam-Chowder_ExtraLarge1000_ID-1117267.jpg?v=1117267",
        "https://cdn.britannica.com/13/77413-050-95217C0B/Golden-Gate-Bridge-San-Francisco.jpg",
        "https://www.mercurynews.com/wp-content/uploads/2018/10/SJM-L-WEEKENDER-1018-01.jpg",]),
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

class ResultSwipePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose a Place!"),
      ),
      body: ResultSwipeWidget(),
    );
  }
}

class ResultSwipeWidget extends StatefulWidget{
  @override
  ResultSwipeState createState() => ResultSwipeState();
}

class ResultSwipeState extends State<ResultSwipeWidget> {
//  var listLen = fakeImg.length;
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
      swipeData.remove(item);
      selectedCards.add(item);
    });
  }

  _dismissCard(dynamic item) {
    // TODO: Communicate to backend it's a NO
    setState(() {
      swipeData.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        child: swipeData.length == 0
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
          children: swipeData.map((item) {
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
              child: Container(
                color: Colors.white,
//                      elevation: 0.5,
//                      shape: RoundedRectangleBorder(
//                          borderRadius: BorderRadius.all(Radius.circular(0))
//                      ),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 12,
                        child: Hero(
                            tag: item.name,
                            child: GestureDetector(
                              child: Container(
                                child: Image.network(item.images[0], fit: BoxFit.cover,),
                              ),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(item: item,)));
                              },
                            )
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 6,
                              child: Padding(
                                  padding: const EdgeInsets.only(left:10.0, top: 20.0, bottom: 15, right: 20.0),
                                  child: _Description(name: item.name, address: item.address,)
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                item.rating.toString(),
                                style: TextStyle(
                                    fontSize: 15.0
                                ),
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
                                    itemSize: 15,
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
            );
          }).toList(),
        ),
      ),
    );
  }

}