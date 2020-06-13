import 'package:andriod_app2/BottomTab.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class CustomizationPage2Widget extends StatefulWidget {
  @override
  CustomizationPage2State createState() => CustomizationPage2State();
}

class CustomizationPage2State extends State<CustomizationPage2Widget> {

  final _locationNameController = TextEditingController(text: globals.userLocationName);

  String value7 = "Recreation";
  String value2 = "Public Transit";
  String value4 = "No Preference";
  double value5 = 0;

  String labels() {
    switch (value5.floor()) {
      case 0:
        return "No Pref.";
      case 1:
        return "\$";
      case 2:
        return "\$\$";
      case 3:
        return "\$\$\$";
      case 4:
        return "\$\$\$\$";
    }
    return "";
  } //Method for the labels on the slider

  /////////////////////////////////////////////////////////////////////// [FUNCTIONS]

  sessionJoin() async {
    //send json package to server as POST
    Map<String, String> headers = {"Content-type": "application/json"};
    String url = globals.tempData["joinlink"];
    String jsonpackage = '{ '  //this package has no MeetupName and MeetupType
        '"uuid":"${globals.uuid}", '
        '"username":"${globals.username}", '
        '"lat":${globals.tempData["lat"]}, '
        '"long":${globals.tempData["long"]}, '
        '"user_place":"${globals.tempData["userplace"]}", '
        '"transport_mode":"${globals.tempData["transportmode"]}", '
        '"metrics": {'
        '"quality":${globals.tempData["quality"]}, '
        '"price":${globals.tempData["price"]}, '
        '"speed":0}'
        '}';
    print("Sending Jsonpackage To Server >>> $jsonpackage");
    print("Using Link: $url");
    try{
      http.Response response = await http.post(url, headers:headers, body:jsonpackage);
      int statusCode = response.statusCode;

      if (statusCode != 200){
        print(response.body);
        Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text("Oops! Server Error. StatusCode:$statusCode"),
              duration: Duration(seconds: 2),
            ));
      }
      else{
        String body = response.body; //store returned string-map "{sessionid: XXX}"" into String body
        print("PostData successfull with statuscode: $statusCode");
        print("Get Session ID successfull with body : $body");
      }
    }
    catch(e){print("Error caught at SessionCreate(): $e");}
  }

  /////////////////////////////////////////////////////////////////////// [WIDGETS]

  @override
  initState() {
    super.initState();
    setState(() {});

  }


  @override
  Widget build(BuildContext context) {

    String mtype = "";
    if (globals.tempMeetingDetails["meeting_type"] == "food") {mtype = "Food";}
    else if (globals.tempMeetingDetails["meeting_type"] == "outing") {mtype = "Outing";}
    else if (globals.tempMeetingDetails["meeting_type"] == "meeting") {mtype = "Meeting";}
    else {mtype = globals.tempMeetingDetails["meeting_type"];}

    Widget buttonSection = Container(
      height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15.0, top: 5, bottom: 5),
              child: ButtonTheme(
                minWidth: 150,
                height: 50,
                child: FlatButton(
                  child: Text('Join Meetup', style: TextStyle(fontFamily: "Quicksand")),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                  color: Colors.deepOrange,
                  textColor: Colors.white,
                  onPressed: () async{
                    globals.tempData["userplace"] = _locationNameController.text;
                    print(globals.tempData);
                    sessionJoin();
                    showDialog(
                        context: context,
                        builder: (context)
                        {Future.delayed(Duration(milliseconds: 2000), () {
                          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>MyHomePage()),);
                        });
                        return Center(child: CircularProgressIndicator());
                        });
                  },
                ),
              ),
            ),
          )
        ],
      ) ,
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Center(
          child: Text("Join Meetup", style: TextStyle(fontFamily: "Quicksand")),
        ),
        backgroundColor: Colors.deepOrange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),


      ),
      body: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding:const EdgeInsets.only(left: 20, top: 15, right: 20, bottom: 8),
                      child: Text("${globals.tempMeetingDetails["meetup_name"]}",
                        style: TextStyle(fontFamily: "QuickSand", fontSize: 20, fontWeight: FontWeight.bold),)
                  )
              )
            ],
          ),//for meetup name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding:const EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 8),
                      child: Text("$mtype",
                        style: TextStyle(fontFamily: "QuickSand", fontSize: 15, fontWeight: FontWeight.bold),)
                  )
              )
            ],
          ),//for activity
          Divider(height: 15,color: Colors.black12, thickness: 1.5, indent: 10, endIndent: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 5, left: 15, right:15),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.location_on, color: Colors.black),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Location", style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            fontFamily: "Quicksand"
                        ),),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child:Padding(
                    padding:const EdgeInsets.only(top: 8, bottom: 5, left: 15, right:8),
                    child: PlacesAutocompleteField(
                      controller: _locationNameController,
                      apiKey: 'AIzaSyCCwub_R6P_vJ-zthJeVAmfZ2Lwmp-UA-g',
                      leading: Icon(Icons.search, color: Colors.black),
                      hint: "Enter Location",
                      mode: Mode.overlay,
                      onSelected: (selected) async {
                        List<Placemark> placemark = await Geolocator().placemarkFromAddress("${selected.description}");
                        await Future.delayed(Duration(milliseconds: 1000));
                        globals.tempData["lat"] = placemark[0].position.latitude;
                        globals.tempData["long"] = placemark[0].position.longitude;
                      },
                    )
                ),
              ),
            ],
          ), //for location
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 5, left: 15, right:8),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.directions_car, color: Colors.black),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Transport", style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            fontFamily: "Quicksand"
                        ),),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value2,
                      onChanged: (String newValue) {
                        setState(() {
                          value2 = newValue;
                          if (value2=="Walk"){globals.tempData["transportmode"]="walking";}
                          else if (value2=="Driving"){globals.tempData["transportmode"]="driving";}
                          else if (value2=="Riding"){globals.tempData["transportmode"]="riding";}
                          else {globals.tempData["transportmode"]="public";}
                        });
                      },
                      items: <String>["Public Transit", "Driving", "Riding", "Walk"].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              )
            ],
          ),//for transport
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 5, left: 15, right:8),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.star, color: Colors.black),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Ratings", style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            fontFamily: "Quicksand"
                        ),),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value4,
                      onChanged: (String newValue) {
                        setState(() {
                          value4 = newValue;
                          if (value4=="Best"){globals.tempData["quality"]=5;}
                          else if (value4=="Regular"){globals.tempData["quality"]=3;}
                          else if (value4=="No Preference"){globals.tempData["quality"]=1;}
                        });
                      },
                      items: <String>["No Preference", "Regular", "Best"]
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              )
            ],
          ),//for ratings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 15, right:8),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.attach_money, color: Colors.black),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right:8),
                        child: Text("Price", style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            fontFamily: "Quicksand"
                        ),),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Container(
                    child: Slider(
                      value: value5,
                      onChanged: (newValue) => setState(() {
                        value5 = newValue;
                        if (value5==1){globals.tempData["price"]=2;}
                        else if (value5==2){globals.tempData["price"]=3;}
                        else if (value5==3){globals.tempData["price"]=4;}
                        else if (value5==4){globals.tempData["price"]=5;}
                        else{globals.tempData["price"]=1;}
                      }),
                      max: 4,
                      min: 0,
                      divisions: 4,
                      label: labels(),
                    )
                ),
              )
            ],
          ), //for price
          Divider(height: 40,color: Colors.black12, thickness: 1.5, indent: 10, endIndent: 10,),
          Container(child: buttonSection),
        ], //children of ListView
      ),
    );
  }
}