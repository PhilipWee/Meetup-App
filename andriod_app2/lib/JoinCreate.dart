import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'TinderPopUp.dart';
import 'Globals.dart' as globals;

class CustomizationPageWidget extends StatefulWidget {
  @override
  CustomizationPageState createState() => CustomizationPageState();
}

class CustomizationPageState extends State<CustomizationPageWidget> {

  final _meetupNameController = TextEditingController();
  final _locationNameController = TextEditingController(text: globals.userLocationName);

  String value7 = "Recreation";
  String value2 = "Public Transit";
  String value4 = "No Preference";
  double value5 = 0;

  //Method for the labels on the slider
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
  }

//  void initState() {
//    super.initState();
//    _locationNameController.addListener(() {
//      final text = _locationNameController.text.toLowerCase();
//      _locationNameController.value = _locationNameController.value.copyWith(
//        text: text,
//        selection:
//        TextSelection(baseOffset: text.length, extentOffset: text.length),
//        composing: TextRange.empty,
//      );
//    });
//  }
//
//  void dispose() {
//    _locationNameController.dispose();
//    super.dispose();
//  }

  @override
  Widget build(BuildContext context) {

    Widget linkSection = Container(
        child: Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 15.0, right: 15.0, bottom: 15.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: TextField(
                          controller: TextEditingController(text:""),
                          decoration: InputDecoration(labelText: "Tap here for link", border: OutlineInputBorder())
                      ),
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
              padding: const EdgeInsets.only(left: 15, right: 15.0, top: 5, bottom: 5),
              child: ButtonTheme(
                minWidth: 150,
                height: 50,
                child: FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                  color: Colors.deepOrange,
                  textColor: Colors.white,
                  onPressed: () {
                    showPopup(context, _popupBody(), 'F07 Class Outing');
                    globals.tempData["meetupname"] = _meetupNameController.text;
                    globals.tempData["userplace"] = _locationNameController.text;
                    print(globals.tempData);
                    },
                  child: Text('Create Meetup', style: TextStyle(fontFamily: "Quicksand")),
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
                          if (value7=="Recreation"){globals.tempData["meetingType"]="Recreation";}
                          else if (value7=="Food"){globals.tempData["meetingType"]="Food";}
                          else {globals.tempData["meetingType"]="Meeting";}
                        });
                      },
                      items: <String>["Recreation", "Food", "Meeting"].map<DropdownMenuItem<String>>((String value) {
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
                          if (value2=="Walk"){globals.tempData["transportMode"]="Walk";}
                          else if (value2=="Driving"){globals.tempData["transportMode"]="Driving";}
                          else if (value2=="Riding"){globals.tempData["transportMode"]="Riding";}
                          else {globals.tempData["transportMode"]="Public Transit";}
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
                          if (value4=="Best"){globals.tempData["quality"]=3;}
                          else if (value4=="Regular"){globals.tempData["quality"]=2;}
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
                        if (value5==1){globals.tempData["price"]=1;}
                        else if (value5==2){globals.tempData["price"]=2;}
                        else if (value5==3){globals.tempData["price"]=3;}
                        else if (value5==4){globals.tempData["price"]=4;}
                        else{globals.tempData["price"]=0;}
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
          Container(child: linkSection),
        ], //children of ListView
      ),
    );
  }

  Future<void> _shareText() async {
    try {
      Share.text('Link', "", 'text/plain');
    } catch (e) {
      print('error: $e');
    }
  }

  showPopup(BuildContext context, Widget widget, String title, {BuildContext popupContext}) {
    Navigator.push(
      context,
      PopupLayout(
        top: 30,
        left: 30,
        right: 30,
        bottom: 50,
        child: PopupContent(
          content: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: Center(child:Text(title),),
              brightness: Brightness.light,
              automaticallyImplyLeading: false,
            ),
            resizeToAvoidBottomPadding: false,
            body: widget,
          ),
        ),
      ),
    );
  }

  Widget _popupBody() {
    return Container(
      child: Text('This is a popup window'),
    );
  }

}