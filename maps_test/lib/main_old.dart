import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MapSample());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Google Maps Demo',
//       home: MapSample(),
//     );
//   }
// }

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

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

  

  var results;

  final Polyline _testline = Polyline(
      polylineId: PolylineId('testline'),
      points: [
        LatLng(37.42796133580664, -122.085749655962),
        LatLng(37.43296265331129, -122.08832357078792)
      ],
      visible: true);

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  //Create a function to build the items of the listview
  Text _buildCustomButton(String restaurant_name) {
    print('BUILDING LA FAG');
    return Text(
        restaurant_name,
        style: TextStyle(color: Colors.white));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: [
            Expanded(
              child: GoogleMap(
                mapType: MapType.hybrid,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                polylines: Set<Polyline>.of([_testline]),
              )
            )
          ]
        ),
        Row(
          children: [
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _getCalculate(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    //If the snapshot has data, return it in a list view
                    final List<dynamic> possible_locations = snapshot.data['possible_locations'];
                    return ListView.builder(
                      itemCount: possible_locations.length,
                      itemBuilder: (BuildContext context, int index) {
                        print(index.toString());
                        return Text(possible_locations.toString());
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text("Error");
                  } else {
                    return CircularProgressIndicator();
                  }
                }
              )
            )
          ]
        )
      ]
    );
  }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: <Widget>[Row( children: [
//                 SizedBox(
//                   height: 500.0,
//                   child: GoogleMap(
//                     mapType: MapType.hybrid,
//                     initialCameraPosition: _kGooglePlex,
//                     onMapCreated: (GoogleMapController controller) {
//                       _controller.complete(controller);
//                     },
//                     polylines: Set<Polyline>.of([_testline]),
//                   ))]),
//           Row(children:<Widget>[Expanded(
//             child: //Fetch and display the data
// FutureBuilder<Map<String, dynamic>>(
//     future: _getCalculate(),
//     builder: (context, snapshot) {
//       if (snapshot.hasData) {
//         //If there is data, return it in a list view
//         final List<dynamic> possible_locations = snapshot.data['possible_locations'];
//         print(possible_locations.length);
//         return ListView.builder(
//           // padding: EdgeInsets.zero,
//           itemCount: possible_locations.length,
//           itemBuilder: (BuildContext context, int index) {
//             print(index.toString());
//             return Text(snapshot.data[index]);
//             // return Card(
//             //   child: FlatButton(
//             //     padding: EdgeInsets.all(0.0),
//             //     onPressed: (){

//             //     print('helloworld');
//             //     },
//             //     child:_buildCustomButton(possible_locations[index]),
//             //     ),
//           // );
//         },);
//         // return Text(possible_locations.toString());
//       } else if (snapshot.hasError) {
//         return Text("Error");
//       }

//       return CircularProgressIndicator();
//     }
//   ))])
            
//           )    
//         ]);
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        polylines: Set<Polyline>.of([_testline]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _getCalculate,
        label: Text('To the lake!'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
