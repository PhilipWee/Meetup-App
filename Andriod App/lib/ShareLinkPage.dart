import 'main.dart';
import 'MapPage.dart';
import 'CustomizationPage.dart';
import 'Meetingtype.dart';

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

class ShareLinkPage extends StatelessWidget {
  final PrefData data;
  ShareLinkPage({this.data,});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Share the Link!"),
//        backgroundColor: Colors.black,
      ),
      body: ShareLinkWidget(data: data),
    );
  }
}

class ShareLinkWidget extends StatefulWidget {
  final PrefData data;
  ShareLinkWidget({this.data});
  @override
  ShareLinkState createState() => ShareLinkState(data: data);
}



class ShareLinkState extends State<ShareLinkWidget> {
  final PrefData data;
  ShareLinkState({this.data});
  List listofmembers = [];

  Future<String> sessionIdPost() async {

    //extract data from PrefData to add to json package
    double lat = data.lat;
    double long = data.long;
    int quality = data.quality;
    int speed = data.speed;
    String transportmode = data.transportMode;
    int price_level  = data.price;

    //send json package to server as POST
    Map<String, String> headers = {"Content-type": "application/json"};
    String address = globalurl();

    String url = '$address/session/create';

    String jsonpackage = '{"lat":$lat,   "long":$long,   "quality":$quality,   "speed":$speed,    "transport_mode":"$transportmode"}';
//    String jsonpackage = '{"lat":$lat,   "long":$long,   "quality":$quality,   "speed":$speed,    "transport_mode":"$transportmode", "price_level":"$price_level"}';
    print("jsonpackage $jsonpackage");
    try{

      http.Response response = await http.post(url, headers:headers, body:jsonpackage);
      int statusCode = response.statusCode;

      if (statusCode != 200){
        Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text("Oops! Server Error 404! Can"),
              duration: Duration(seconds: 2),
            ));
      }

      else{

        String body = response.body; //store returned string-map "{sessionid: XXX}"" into String body
        print("POST REQUEST SUCCESSFUL/FAILED WITH STATUSCODE: $statusCode");
        print("SERVER SAYS: $body");

        //decode the string-map
        Map<String, dynamic> sessionidjsonversion = jsonDecode(body);
        var sessionid = sessionidjsonversion['session_id'];
        print("Transport Mode:$transportmode");
        print("Quality:$quality");
        print("Speed:$speed");
        print("Price: $price_level");
        data.link = "$address/session/$sessionid/get_details";

        data.sessionid = sessionid;
        String tempvar = data.link;
        print('Link Created--> $tempvar');
        return data.link;

      }
    }

    catch(e){print("Session Create Failed with Error: $e");}
  }

//  Stream<Future<List<dynamic>>> stream = Stream<Future<List<dynamic>>>.periodic(Duration(seconds:2), getMembers)

  Future<List<dynamic>> getMembers() async {

    String sessID = data.sessionid;
    String address = globalurl();

    try{
      http.Response response = await http.get('$address/session/$sessID');
      print("COCK");
      await Future.delayed(Duration(milliseconds: 1500));
      int statusCode = response.statusCode;
      String body = response.body;
      print(response.statusCode);

      if (statusCode != 200){
        Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text("Oops! Server Error 404"),
              duration: Duration(seconds: 2),
            ));
      }
      else{
        print("GET REQUEST SUCCESSFUL/FAILED WITH STATUSCODE: $statusCode");
        print("SERVER SAYS: $body");
        Map<String, dynamic> memberDatajsonVersion = jsonDecode(body); //parse the data from server into a map<string,dynamic>
        List membersData = memberDatajsonVersion["users"];
        //extract the list of user detail maps into a list
        List<Placemark> myplace = await Geolocator().placemarkFromCoordinates(data.lat,data.long); //get the name of the place where user is at right now
        Map<String,String> placeNameMap = {"username": myplace[0].thoroughfare.toString() }; //add the place name as a value to the key "username" to a new map
        for (Map<String, dynamic> mapcontent in membersData) { // for every user detail map packet in the main list
          print(mapcontent);
          if (mapcontent["lat"] != null && mapcontent["long"] != null && mapcontent["identifier"] != null){
            List<Placemark> place = await Geolocator().placemarkFromCoordinates(double.parse(mapcontent["lat"]), double.parse(mapcontent["long"])); //use the lat long values to find the placename
//            List<Placemark> place = await Geolocator().placemarkFromCoordinates(mapcontent["lat"], mapcontent["long"]); //use the lat long values to find the placename
            placeNameMap[mapcontent["identifier"].toString()] = place[0].thoroughfare.toString(); // add the placename to the map with the key being the name of the user
          }
          else{placeNameMap[mapcontent["identifier"].toString()] = "ERRROR";}
        }
        membersData.add(placeNameMap);
        print("membersData-> $membersData");
        return membersData;
      }
    }
    catch(e){print("Get-session-details Failed with error: $e");}
  }

  Future<List<Map<String, dynamic>>> getMembersFAKE() async {

    List<Map<String, dynamic>> membersData = [
      {
        "lat": 37.4219983,
        "long": -122.084,
        "metrics": {
          "quality": 3,
          "speed": 3
        },
        "transport_mode": "Driving",
        "username": "username"
      },
      {
        "identifier": "Philip",
        "lat": 1.2848664,
        "long": 103.8244263,
        "metrics": {
          "quality": 5,
          "speed": 5
        },
        "transport_mode": "Driving"
      },
      {
        "identifier": "Julia",
        "lat": 1.2848664,
        "long": 103.8244263,
        "metrics": {
          "quality": 5,
          "speed": 5
        },
        "transport_mode": "Public Transport"
      },
      {
        "identifier": "Joel",
        "lat": 1.2848664,
        "long": 103.8244263,
        "metrics": {
          "quality": 5,
          "speed": 5
        },
        "transport_mode": "Public Transport"
      },
      {
        "identifier": "Veda",
        "lat": 1.2848664,
        "long": 103.8244263,
        "metrics": {
          "quality": 5,
          "speed": 5
        },
        "transport_mode": "Walking"
      },
      {
        "username" : "Jalan Bukit Merah",
        "Philip" : "Serangoon Gardens",
        "Julia" : "Potong Pasir",
        "Joel" : "Hougang",
        "Veda" : "Upper Changi",
      },
    ];
    return membersData;
  }

  @override
  Widget build(BuildContext context) {

    Widget linkSection = Container(
      child:
      FutureBuilder(
          future: sessionIdPost(),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            print(snapshot);
            if(snapshot.data == null){
              return Text("Unable to retrieve link");
            }
            else {
              return
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 15.0, right: 15.0, bottom: 5.0),
                  child: TextField(
                      controller: TextEditingController(text:data.link),
                      decoration: InputDecoration(labelText: "Tap here for link", border: OutlineInputBorder())
                  ),
                );
            }
          }
      ),
    );

    Widget buttonSection = Container(
      height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 5.0),
                child: ButtonTheme(
                  height: 35,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                    color: Colors.amber,
                    textColor: Colors.black,
                    onPressed: () async => await _shareText(),
                    child: Text("Share"),
                  ),
                ),
              )
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 15.0),
              child: ButtonTheme(
                minWidth: 180,
                height: 35,
                child: FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                  color: Colors.amber,
                  textColor: Colors.black,
                  onPressed: () {
                    Navigator.push(context,MaterialPageRoute(builder: (context) => MapSample(data:data)),);
                  },
                  child: Text("Create Meetup!"),
                ),
              ),
            ),
          )
        ],
      ) ,
    );

    Future<Null> _refresh() async {
      setState((){});
      return await Future.delayed(Duration(milliseconds: 1500));
    }

    Widget listSection = Container(
      child:
      FutureBuilder(
        future: getMembers(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          print(snapshot);
          listofmembers = snapshot.data;
          if(listofmembers == null){
            return
              Expanded(
                  child:
                  Container(
                      child: Center(
                          child: Text("Loading...")
                      )
                  )
              );
          }
          else {
            return Expanded (child: RefreshIndicator(child: ListView.builder(
              itemCount: listofmembers.length-1,
              itemBuilder: (BuildContext context, int index) {
                Map<String,dynamic> myMap = snapshot.data[snapshot.data.length-1];
                if (index == 0){
                  return ListTile(
                      leading: CircleAvatar(backgroundImage: AssetImage("images/mouseAvatar.jpg"),),
                      title: Text(data.username),
                      subtitle: Text(snapshot.data[index]["transport_mode"].toString()),
                      trailing: Text(myMap["username"].toString())
                  );
                }
                return ListTile(
                  leading: CircleAvatar(backgroundImage: AssetImage("images/mouseAvatar.jpg"),),
                  title: Text(snapshot.data[index]["identifier"].toString()),
                  subtitle: Text(snapshot.data[index]["transport_mode"].toString()),
                  trailing: Text(myMap[snapshot.data[index]["identifier"]].toString()),
                );
              },
            ) , onRefresh: _refresh,
            ));
          }
        },
      ),
    );

    return Scaffold(
      body: Column(
        children:[
          linkSection,
          buttonSection,
          listSection,
        ],
      ),
    );
  }


  Future<void> _shareText() async {
    try {
      Share.text('Link', data.link, 'text/plain');
    } catch (e) {
      print('error: $e');
    }
  }

}