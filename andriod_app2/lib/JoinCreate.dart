import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CustomizationPageWidget extends StatefulWidget {
  @override
  CustomizationPageState createState() => CustomizationPageState();
}

class CustomizationPageState extends State<CustomizationPageWidget> {
  //Method for the labels on the slider
  Map<String,dynamic> data;
  String labels() {
  switch (data["price"].floor()) {
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
}
//  CustomizationPageState() : super() {
//    FirebaseAuth _auth = FirebaseAuth.instance;
//    _auth.currentUser().then((user) =>
//        Firestore.instance.collection('userData').document(user.uid).get().then((value) =>
//        print(value.data)
//        )
//    );
//
//  }
  Future<Map<String,dynamic>> initialisingData() async{
    FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseUser user = await _auth.currentUser();
    QuerySnapshot event = await Firestore.instance.collection('userData').where("uid", isEqualTo: user.uid).snapshots().first;
    return Map.from(event.documents.first.data);
}

  Future updateFirebase(Map<String,dynamic> data) async{
    FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseUser user = await _auth.currentUser();
    Firestore.instance.collection('userData').document(user.uid).setData(data);
    print("data set.");
  }
  @override
  Widget build(BuildContext context) {
    Widget linkSection = Container(
        child: Padding(
            padding: const EdgeInsets.only(
                left: 15.0, top: 15.0, right: 15.0, bottom: 15.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: TextField(
                          controller: TextEditingController(text: ""),
                          decoration: InputDecoration(
                              labelText: "Tap here for link",
                              border: OutlineInputBorder())
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 5, right: 5, bottom: 80),
                      child: Text(""),
                    ),
                    IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () async => await _shareText()
                    ),
                  ],
                ),
              ],
            )
        )
    );

    Widget buttonSection = Container(
      height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15.0, top: 20),
              child: ButtonTheme(
                minWidth: 150,
                height: 50,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0)),
                  color: Colors.deepOrange,
                  textColor: Colors.white,
                  onPressed: () {},
                  child: Text("Create Meetup!"), //TODO
                ),
              ),
            ),
          )
        ],
      ),
    );


      return FutureBuilder<Map>(
          future: initialisingData(),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text('Please wait its loading...'));
        } else {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          else
            data = Map.from(snapshot.data);

            return Scaffold(
              appBar: AppBar(
                title: Center(
                  child: Text("Create Meetup"),
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
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 8.0, right: 10, bottom: 8.0),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.home, color: Colors.black),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Location", style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0
                                ),),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.only(
                                left: 0, top: 8, right: 8, bottom: 8),
                            child: PlacesAutocompleteField(
                                controller: TextEditingController(
                                    text: "THE LOCATION"),
                                apiKey: 'AIzaSyCCwub_R6P_vJ-zthJeVAmfZ2Lwmp-UA-g',
                                leading: Icon(Icons.search, color: Colors.black),
                                hint: "Manually enter location",
                                mode: Mode.overlay
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
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 8.0, right: 30, bottom: 8.0),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.directions_car, color: Colors.black),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Transport", style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0
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
                              value: data["transportMode"],
                              onChanged: (String newValue) {
                                setState(() {
                                  data["transportMode"] = newValue;
                                  updateFirebase(data).then((value) => print("data has been updated."));
                                  if (data["transportMode"]=="Walk"){data["transportMode"]="Walk";}
                                  else if (data["transportMode"]=="Driving"){data["transportMode"]="Driving";}
                                  else if (data["transportMode"]=="Riding"){data["transportMode"]="Riding";}
                                  else {data["transportMode"]="Public Transit";}
                                });
                              },
                              items: <String>[
                                "Public Transit",
                                "Driving",
                                "Riding",
                                "Walk"
                              ].map<DropdownMenuItem<String>>((String value) {
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
                  ), //for transport
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 8.0, right: 30.0, bottom: 8.0),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.star, color: Colors.black),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Ratings", style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0
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
                              value: data["quality"],
                              onChanged: (String newValue) {
                                setState(() {
                                  data["quality"] = newValue;
                                  updateFirebase(data).then((value) => print("data has been updated."));
//                                  if (quality=="Best"){data.quality=3;}
//                                  else if (quality=="Regular"){data.quality=2;}
//                                  else if (quality=="No Preference"){data.quality=1;}  //ADD TO DATABASE
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
                  ), //for ratings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 8.0, right: 30.0, bottom: 8.0),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.attach_money, color: Colors.black),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Price", style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0
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
                              value: data["price"].toDouble(),
                              onChanged: (newValue) =>
                                  setState(() {
                                    data["price"] = newValue.floor();
                                    updateFirebase(data).then((value) => print("data has been updated."));

                                    //                        if (price==1){data.price=1;}
                                    //                        else if (price==2){data.price=2;}
                                    //                        else if (price==3){data.price=3;}
                                    //                        else if (price==4){data.price=4;}
                                    //                        else{data.price=0;}
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
                  buttonSection,
                  linkSection
                ], //children of ListView
              ),
              bottomNavigationBar: BottomAppBar(
                child: FlatButton(
                  child: Text(
                      'Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {},
                  //            onPressed: () async {
                  //              if (value2.isNotEmpty && value4.isNotEmpty) {  //CHECK IF PREFERENCES HAS BEEN FILLED IN
                  //                data.speed = 3; // fix at 3
                  //                if (data.sessionid.isEmpty) {
                  //                  print("Running PostDataGetID");
                  //                  postDataGetID();
                  //                }  //IF THERE IS NO ID
                  //                else if (data.sessionid.isNotEmpty) {
                  //                  print("Running PostDataUpdateSess");
                  //                  postDataUpdateSess();
                  //                }  //IF THERE IS ID
                  //
                  //                await Future.delayed(Duration(milliseconds: 2000));
                  //                Navigator.push(context,MaterialPageRoute(builder: (context) => ShareLinkPage(data:data)),);
                  //                print("TEST: ${data.dataMap}");
                  //
                  //              } else {
                  //                Scaffold.of(context).showSnackBar(
                  //                    SnackBar(
                  //                      content: Text("Please select preferences!"),
                  //                      duration: Duration(seconds: 2),
                  //                    ));
                  //              }
                  //            }


                ),
              ),
            );
          }
        }
        );

    }
  }
  Future<void> _shareText() async {
    try {
      Share.text('Link', "", 'text/plain');
    } catch (e) {
      print('error: $e');
    }


}