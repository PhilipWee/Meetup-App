import 'package:andriod_app2/BuildMeetupDetails.dart';
import 'package:flutter/material.dart';
import 'Globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'Globals.dart' as globals;
import 'Join.dart';


class Homescreen extends StatelessWidget {
  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(
            child: Text('My Meetups', style: TextStyle(fontFamily: "Quicksand"))),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
}

class HomeUsernameWidget extends StatefulWidget {
  @override
  HomeUsernameState createState() => HomeUsernameState();
}

class HomeUsernameState extends State<HomeUsernameWidget> {

  bool invalidLink = false;

  final _joinController = TextEditingController();

  final List<String> custLabels = [
    "F07 Reunion",
    "Dinner Date - Stacy",
    "UROP Meeting",
  ];
  final List<String> custImgs = [
    "images/outing.jpg",
    "images/food.jpg",
    "images/meetingButton.jpg",
  ];

  //////////////////////////////////// [ALL FUNCTIONS] /////////////////////////////////////////////////

  void saveSessionDetailsFromLink(String inputLink) async{
    globals.tempData["joinlink"] = inputLink.replaceAll(new RegExp(r'/get_details'), '');
    http.Response response = await http.get(globals.tempData["joinlink"]); //get session details
    String body = response.body;
    globals.tempMeetingDetails = jsonDecode(body);
    print(globals.tempMeetingDetails);
    } //session details saved in global.tempMeetingDetals

  void getAllUserSessions(String inputUserId) async{
    String url = '${globals.serverAddress}/session/get?username=$inputUserId';
    http.Response response = await http.get(url);
    String body = response.body;
    print(body);
    globals.usersSessionsList = jsonDecode(body);
    print(globals.usersSessionsList);
  } // list of all sessionIds saved in

  void getNameGetType (List inputUsersSessionsList) {

  }

  /////////////////////////////////////// [ALL WIDGETS] ///////////////////////////////////////////////


  @override
  //Creates a list view with buildCustomButtons inside
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text('My Meetups', style: TextStyle(fontFamily: "Quicksand")),
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _joinController,
                          decoration: InputDecoration(
                            labelText: "Joining meetup? Enter Meeting ID or Link",
                            border: OutlineInputBorder(gapPadding: 0),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.person_add),
                        onPressed: (){
                          saveSessionDetailsFromLink(_joinController.text);
                          Navigator.push(context,MaterialPageRoute(builder: (context) => CustomizationPage2Widget()),);
//                          getAllUserSessions(globals.uuid);
                          },
                        iconSize: 25,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),//join text controller
          Container(
            child: Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 0, bottom: 0, left:4, right:4),
                itemCount: custImgs.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: FlatButton(
                      padding: EdgeInsets.all(0),
                      onPressed: (){},
                      child:_buildCustomButton(custLabels[index], custImgs[index]) ,
                    ),
                  );
                },
              ),
            ),
          ),//list of stuff
        ],
      )

    );
  }

  //Helper method to create layout of the buttons
  Container _buildCustomButton(String label, String imgName) {
    return Container(
      height: 150.0,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(imgName),
              fit: BoxFit.cover
          )
      ),
      child: Container(
        height: 50.0,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Colors.black54, Colors.white12],
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        alignment: Alignment.bottomLeft,
        child: Text(
          label,
          style: TextStyle(
              fontFamily: "Quicksand",
              color: Colors.white,
//              fontWeight: FontWeight.bold,
              fontSize: 17),
        ),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(0.0),
    );
  }


}