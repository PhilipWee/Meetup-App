import 'main.dart';
import 'ShareLinkPage.dart';
import 'CustomizationPage.dart';
import 'Meetingtype.dart';
import 'color_loader.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
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

class MapSample extends StatefulWidget {
  final PrefData data;
  MapSample({this.data});
  @override
  State<MapSample> createState() => MapSampleState(data:data);
}

class MapSampleState extends State<MapSample> {
  final PrefData data;
  MapSampleState({this.data});
  Completer<GoogleMapController> _controller = Completer();
  List<Polyline> polylines = [];
  List<Marker> markers = [];


  //Create the get request function
  Future<Map<String, dynamic>> _getCalculate() async {
    String id = data.sessionid;
    String address = globalurl();
    // final result = await http.get("$address/session/$id/calculate")
    var _ = await http.get("$address/session/$id/calculate");
    while (true) {
      var result = await http.get("$address/session/$id/results");
      if (result.statusCode != 200 || result.statusCode != 302) {
        Map<String, dynamic> results = jsonDecode(result.body);
        //Check if its still info or not
        print(results);
        if (results.containsKey('info')) {
          //Still Calculating
          await Future.delayed(Duration(milliseconds: 1000));
          continue;
        } else if (results.containsKey('error')){
          //There is an error
          print(results);
        } else {
          //The results are out
          return results;
        }
      }
      //Do a time sleep of 1 second and wait to ping again

    }
//    if (result.statusCode != 200 || result.statusCode != 302) {
//      Map<String, dynamic> results = jsonDecode(result.body);
//      print(results);
//      print(results['possible_locations']);
//      return results;
//    } else {
//      // throw ("Error getting results with statusCode " + result.statusCode.toString());
//      Map<String, dynamic> results = jsonDecode(result.body);
//      print(results);
//      print(results['possible_locations']);
//      return results;
//    }
  }

  static final CameraPosition _kSingapore = CameraPosition(
    target: LatLng(1.3385253,103.8),
    zoom: 10,
  );

  //Build the map
  GoogleMap displayMap() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _kSingapore,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      polylines: Set<Polyline>.of(polylines),
      markers: Set<Marker>.of(markers),
    );
  }

  //Make a list for the different colors
  List<Color> colors = <Color>[
    Colors.blue,
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.pink
  ];

  //Create a polyline from array
  Polyline _makeLine(List<dynamic> latitude, List<dynamic> longtitude, int polylineid) {
    List<LatLng> latLngList = [];
    for (var i = 0; i < latitude.length; i++) {
      // print(latitude[i]);
      // print(longtitude[i]);
      latLngList.add(LatLng(latitude[i],longtitude[i]));
    }
    return Polyline(
        polylineId: PolylineId(polylineid.toString()),
        color: colors[polylineid%5],
        width: 5,
        points: latLngList
    );
  }

  //Make a function that makes a widget appear to show the current selection


  //Place a marker
  Marker _makeMarker(LatLng location, int markerid) {
    return Marker(
      markerId: MarkerId(markerid.toString()),
      position: location,
      consumeTapEvents: false,
    );
  }

  //Drawing the map lines
  Future<void> _drawRoutes(String locationName, Map<String,dynamic> data) async {
    print('Now showing routes for ' + locationName);
    print(data[locationName]);
    List<Polyline> polylineContainer = [];
    List<Marker> markerContainer = [];
    int lineIterator = 0;
    double destinationLat = 0;
    double destinationLong = 0;
    LatLng destinationLatLng;

    for (String key in data[locationName].keys) {
      //Continue the loop for the banned keys
      var bannedNames = ['price','rating','place_id','total_cost'];
      if (bannedNames.contains(key)) {
        continue;
      }
      var latitude = data[locationName][key]['latitude'];
      var longtitude = data[locationName][key]['longtitude'];
      var transport_type = data[locationName][key]['transport_type'];
      var transport_type_id = data[locationName][key]['transport_type_id'];
      print(data[locationName][key]['end_vid']);
      // print(latitude);
      // print(longtitude);
      polylineContainer.add(_makeLine(latitude,longtitude,lineIterator));
      lineIterator++;
      destinationLong = data[locationName][key]['restaurant_x'];
      destinationLat = data[locationName][key]['restaurant_y'];

      destinationLatLng = LatLng(destinationLat,destinationLong);
//      print(destinationLatLng);

      markerContainer.add(_makeMarker(destinationLatLng, lineIterator));


    }
    //Draw routes
    setState(() {
//      print(markerContainer.length.toString());
      _locationName = locationName;
      _destinationLat = destinationLat;
      _destinationLong = destinationLong;

      visibility = true;
      polylines = polylineContainer;
      markers = markerContainer;
    });

    //Center the map on the appropriate location
    final CameraPosition _endDestination = CameraPosition(
        bearing: 0,
        target: destinationLatLng,
        tilt: 0,
        zoom: 14);


    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_endDestination));

  }

  //Build the listview
  FutureBuilder<Map<String,dynamic>> displayPossibleOptions() {
    //Make a helper function for each button of the listview
//    var price = data[locationName]['price'].toString();
//    var rating = data[locationName]['rating'].toString();
//    var totalTravelTime = data[locationName]['total_cost'].toString();
    Card _tile(String locationName, Map<String,dynamic> data) => Card(
        child: FlatButton(
            padding: EdgeInsets.all(0.1),
            onPressed: (){
              //Place the functionality for showing the route here
              _drawRoutes(locationName, data);
            },
            child: ListTile(
                title: Text(locationName.toString()),
                trailing: Text('Rating:' + data[locationName]['rating'].toString() + ' Price:' + data[locationName]['price'].toString() + ' Travel time:' + data[locationName]['total_cost'].toString())
            )
        )

    );

    List<Color> colorsForLoad = [
      Colors.red,
      Colors.green,
      Colors.indigo,
      Colors.pinkAccent,
      Colors.blue
    ];
    List<dynamic> possibleLocations = [];
    Map<String,dynamic> datacopy = {};

    return FutureBuilder<Map<String,dynamic>>(
        future: _getCalculate(),
        builder: (context, snapshot) {
//          print(possibleLocations)
//          && possibleLocations.length == 0
          if (snapshot.hasData) {//save data oni
            if (snapshot.data.containsKey('info')) {
              //Not yet done processing
              print('warning the snapshot is still at the info stage!');
            }
            possibleLocations = snapshot.data['possible_locations'];
//            print(snapshot.data);
            datacopy = snapshot.data;
            return ListView.builder(
              itemCount: possibleLocations.length,
              itemBuilder: (BuildContext context, int index) {
                //Need to add in code to prevent nulls form appearing
                return _tile(possibleLocations[index], datacopy);
              },
            );
          }
//          if (possibleLocations.length != 0)
          // ignore: missing_return
//          else if (true) {   //blast saved data
//            return ListView.builder(
//              itemCount: possibleLocations.length,
//              itemBuilder: (BuildContext context, int index) {
//                print(possibleLocations);
//                //Need to add in code to prevent nulls form appearing
//                return _tile(possibleLocations[index], datacopy);
//              },
//            );
//          }
          else {
//            final List<dynamic> possibleLocations = snapshot.data['possible_locations'];
            return ColorLoader(colors: colorsForLoad, duration: Duration(milliseconds: 1200));
          }
        }
    );
  }

  //generate the necessary variables for display location details
  String _locationName = "";
  bool visibility = false;
  double _destinationLong = 0;
  double _destinationLat = 0;

  //Make a button that launches the google maps
  _launchGoogleMaps() async {
    String url = "https://www.google.com/maps/dir/?api=1&destination="+_destinationLat.toString()+","+_destinationLong.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  //Make a widget to display the final location, as well as allow the user to go to google maps
  Visibility displayLocationDetails() {
    return Visibility(
      child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
            <Widget>[
              ListTile(
                  title: Center(
                      child:Text(_locationName, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
                  )
              ),
              ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: Text("SHOW IN MAPS"),
                    onPressed: () {
                      _launchGoogleMaps();
                    },
                  )
                ],
              )
            ],
          )
      ),
      visible: visibility,
    );

  }

  //Make a widget for the background objects, namely the map and the options
  Center displayBackground() {
    return Center(
        child: Container(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child:displayMap(),
                      flex:5
                  ),
                  Expanded(
                      child:displayPossibleOptions(),
                      flex:1
                  )
                ]
            )
        )
    );
  }

  //Build the main widget
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(title: Text("Suggested Locations"),),
        body: SafeArea(
            child: Stack(
              children: <Widget>[
                displayBackground(),
                displayLocationDetails()
              ],
            )
        )
    );
  }
}