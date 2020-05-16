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

//User's selected places
List selectedCards = [];

List<globals.FakeData> swipeData = [];

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
        backgroundColor: Colors.deepOrange,
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

  Future getSessionResults (String inputSessID) async{
    swipeData = [];
    String url = '${globals.serverAddress}/session/$inputSessID/results';
    http.Response response = await http.get(url);
    Map results = jsonDecode(response.body);
//    print(results);
    List possibleLocations = results["possible_locations"];

    for( var i=0 ; i<possibleLocations.length ; i++ ){

      Map oneLocation = results[possibleLocations[i]];

//      print("");
      print(possibleLocations);
//      print(possibleLocations[i]);
//      print(oneLocation);
//      print(oneLocation["address"]);
//      print(oneLocation["writeup"]);
//      print(oneLocation["rating"]);
//      print(oneLocation["pictures"]);

      globals.FakeData placeInfo =
      globals.FakeData(
        name: possibleLocations[i],
        address: oneLocation["address"], //string
        details: oneLocation["writeup"], //string
        rating: double.parse(oneLocation["rating"]), //integer
        images: oneLocation["pictures"], //list
      );
      swipeData.add(placeInfo);
    } //for loop ends here!
  }

//  var listLen = fakeImg.length;
  List<Color> colorsForLoad = [
    Colors.red,
    Colors.green,
    Colors.indigo,
    Colors.pinkAccent,
    Colors.blue
  ];

  _addCard(dynamic item) {

//    setState(() {
      // TODO: Communicate to backend it's a YES
      swipeData.remove(item);
      selectedCards.add(item);
//    });
  }

  _dismissCard(dynamic item) {
    // TODO: Communicate to backend it's a NO
//    setState(() {
      swipeData.remove(item);
//    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;

    return Scaffold(
      body: FutureBuilder(
        future: getSessionResults(globals.sessionData["sessionid"]),
        builder: (BuildContext context, AsyncSnapshot snapshot){
        if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                child: swipeData.length == 0
                    ? Container(
                        width: screen.width,
                        height: screen.height,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ColorLoader(
                                colors: colorsForLoad,
                                duration: Duration(milliseconds: 1200)),
                            Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 10),
                                child: Text("Waiting for results")),
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
                                              child: Image.network(
                                                item.images[0],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailsPage(
                                                            item: item,
                                                          )));
                                            },
                                          )),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 6,
                                            child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0,
                                                    top: 20.0,
                                                    bottom: 15,
                                                    right: 20.0),
                                                child: _Description(
                                                  name: item.name,
                                                  address: item.address,
                                                )),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Text(
                                              item.rating.toString(),
                                              style: TextStyle(fontSize: 15.0),
                                            ),
                                          ),
                                          Expanded(
                                              flex: 2,
                                              child: Container(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                alignment:
                                                    Alignment.centerRight,
                                                child: RatingBarIndicator(
                                                  rating: item.rating,
                                                  itemBuilder:
                                                      (context, index) => Icon(
                                                    Icons.star,
                                                    color: Colors.black,
                                                  ),
                                                  itemCount: 5,
                                                  itemSize: 15,
                                                ),
                                              ))
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
              );
            }
        else{return Center(child: CircularProgressIndicator());}
          }),
    );
  }
}