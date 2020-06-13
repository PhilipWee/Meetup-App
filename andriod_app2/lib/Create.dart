import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'PopUp.dart';
import 'Globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class CustomizationPageWidget extends StatefulWidget {
  @override
  CustomizationPageState createState() => CustomizationPageState();
}

class CustomizationPageState extends State<CustomizationPageWidget> {

  final _meetupNameController = TextEditingController();
  final _locationNameController = TextEditingController(text: globals.userLocationName);

  String value7 = "Outing";
  String value2 = "Public Transit";
  String value4 = "No Preference";
  double value5 = 1;

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

  //////////////////////////////////// [ALL FUNCTIONS] /////////////////////////////////////////////////

  Future<String> sessionCreate() async {
    //send json package to server as POST
    Map<String, String> headers = {"Content-type": "application/json"};
    String address = globals.serverAddress;
    String url = '$address/session/create';

    String jsonpackage = '{ '
        '"uuid":"${globals.uuid}", '
        '"meetup_name":"${globals.tempData["meetupname"]}", '
        '"username":"${globals.username}", '
        '"meeting_type":"${globals.tempData["meetingtype"]}", '
        '"lat":${globals.tempData["lat"]}, '
        '"long":${globals.tempData["long"]}, '
        '"user_place":"${globals.tempData["userplace"]}", '
        '"transport_mode":"${globals.tempData["transportmode"]}", '
        '"metrics": {'
        '"quality":${globals.tempData["quality"]}, '
        '"price":${globals.tempData["price"]}, '
        '"speed":0'
        '}'
        '}';

    print("[sessionCreate] Sending Jsonpackage To Server >>> $jsonpackage");

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
        return null;
      }
      else{
        String body = response.body; //store returned string-map "{sessionid: XXX}"" into String body
        Map<String, dynamic> sessionidjsonversion = jsonDecode(body);
        var sessionid = sessionidjsonversion['session_id'];
        globals.tempData["sessionid"] = sessionid;
        print("SESSION ID : ${globals.tempData["sessionid"]}");
        globals.tempData["link"] = "$address/session/$sessionid/get_details";
        print('Link Created[ ${globals.tempData["link"]} ]');
        return globals.tempData["link"];
      }
    }
    catch(e){print("Error caught at SessionCreate(): $e");}

  }

  showPopup(BuildContext context, Widget widget, {BuildContext popupContext}) {
    Navigator.push(
      context,
      PopupLayout(
        top: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height/4,
        left: 0,
        right: 0,
        bottom: 57,
        child: PopupContent(
          content: Scaffold(
              resizeToAvoidBottomPadding: false,
              body: widget,
              backgroundColor: Colors.white
          ),
        ),
      ),
    );
  }

  Future<void> _shareText() async {
    try {
      Share.text('Link', globals.tempData["link"], 'text/plain');
    } catch (e) {
      print('error: $e');
    }
  }


  /////////////////////////////////////// [ALL WIDGETS] ///////////////////////////////////////////////

  Widget _popupBody() {

    return FutureBuilder(
      future: sessionCreate(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null){
          return Container(child: Container(
              height: 100,
              child: Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 15.0, right: 15.0, bottom: 15.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: TextField(
                                controller: TextEditingController(text:snapshot.data),
                                decoration: InputDecoration(labelText: "Tap here for link", border: OutlineInputBorder())
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.content_copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: globals.tempData["link"]));
                              Navigator.pop(context);
                            },
                          ),
                          IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () async {
                                await _shareText();
                                Navigator.pop(context);
                              }
                          ),
                        ],
                      ),
                    ],
                  )
              )
          ));
        }
        else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );

//    return Container(child: linkSection);
  }

  @override
  Widget build(BuildContext context) {

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
                  child: Text('Create Meetup', style: TextStyle(fontFamily: "Quicksand")),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                  color: Colors.deepOrange,
                  textColor: Colors.white,
                  onPressed: () async{
                    if (_meetupNameController.text.isEmpty) {
                      Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Enter Meetup Name!",
                              style: TextStyle(
                                fontFamily: "Quicksand",
                                fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center,
                            ),
                            duration: Duration(seconds: 1),
                          ));
                    }
                    else {
                      globals.tempData["meetupname"] =_meetupNameController.text;
                      globals.tempData["userplace"] =_locationNameController.text;
                      showPopup(context, _popupBody());
                    }
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
        title: Center(
          child: Text("Create Meetup", style: TextStyle(fontFamily: "Quicksand")),
        ),
        backgroundColor: Colors.deepOrange,
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
                  child: TextFormField(
                    controller: _meetupNameController,
                    decoration: InputDecoration(labelText: "Name of Meetup", border: OutlineInputBorder()),
                  ),
                )
              )
            ],
          ),//for meetup name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 5, left: 15, right:15),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.group, color: Colors.black),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text("Activity", style: TextStyle(
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
                      value: value7,
                      onChanged: (String newValue) {
                        setState(() {
                          value7 = newValue;
                          if (value7=="Outing"){globals.tempData["meetingtype"]="outing";}
                          else if (value7=="Food"){globals.tempData["meetingtype"]="food";}
                          else {globals.tempData["meetingtype"]="meeting";}
                        });
                      },
                      items: <String>["Outing", "Food", "Meeting"].map<DropdownMenuItem<String>>((String value) {
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
          ),//for meetup type
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
          Container(child: buttonSection), //for creating meetup
        ], //children of ListView
      ),
    );
  }
}