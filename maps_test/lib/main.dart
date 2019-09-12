import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "testing one 2 three",
      home: MapSample()
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  List<Polyline> polylines = [];


  //Create the get request function
  Future<Map<String, dynamic>> _getCalculate() async {
    final result =
        await http.get('http://192.168.194.210:5000/session/123456/results');
    if (result.statusCode == 200) {
      Map<String, dynamic> results = jsonDecode(result.body);
      print(results);
      print(results['possible_locations']);
      return results;
    } else {
      throw ("Error getting results with statusCode " + result.statusCode.toString());
    }
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
      print(latitude[i]);
      print(longtitude[i]);
      latLngList.add(LatLng(latitude[i],longtitude[i]));
    }
    return Polyline(
      polylineId: PolylineId(polylineid.toString()),
      color: colors[polylineid%5],
      width: 5,
      points: latLngList
    );
  }

  //Drawing the map lines
  Future<void> _drawRoutes(String locationName, Map<String,dynamic> data) async {
    print('Now showing routes for ' + locationName);
    print(data[locationName]);
    List<Polyline> polylineContainer = [];
    int lineIterator = 0;
    LatLng destinationLatLng;
    for (String key in data[locationName].keys) {
        var latitude = data[locationName][key]['latitude'];
        var longtitude = data[locationName][key]['longtitude'];
        print(latitude);
        print(longtitude);
        polylineContainer.add(_makeLine(latitude,longtitude,lineIterator));
        lineIterator++;
        if (latitude.length > 0) {
          destinationLatLng = LatLng(latitude.last,longtitude.last);
        }
      }
    //Draw routes
    setState(() {
      polylines = polylineContainer;
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
    Card _tile(String locationName, Map<String,dynamic> data) => Card(
      child: FlatButton(
        padding: EdgeInsets.all(0.1),
        onPressed: (){
          //Place the functionality for showing the route here
          _drawRoutes(locationName, data);
        },
        child: ListTile(
          title: Text(locationName.toString())
        )
      )
     
    );

    return FutureBuilder<Map<String,dynamic>>(
        future: _getCalculate(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<dynamic> possibleLocations = snapshot.data['possible_locations'];
            return ListView.builder(
              itemCount: possibleLocations.length,
              itemBuilder: (BuildContext context, int index) {
                print(possibleLocations);
                //Need to add in code to prevent nulls form appearing
                return _tile(possibleLocations[index], snapshot.data); 
              },
            );
          } else if (snapshot.hasError) {
            return Text("Error");
          } else {
            return CircularProgressIndicator();
          }
        }
      );
  }

  //Build the main widget
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: SafeArea(
          child: Center( 
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
          )
        )
      );
    }
}
