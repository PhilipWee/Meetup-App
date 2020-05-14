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

  List<String> custLabels = [];
  List<String> custImgs = [];
  List<String> custStates = [];
  List<String> sessionIDs = [];
  List allData = [];

  @override
  initState(){
    super.initState();
  }

  //////////////////////////////////// [ALL FUNCTIONS] /////////////////////////////////////////////////

  void saveSessionDetailsFromLink(String inputLink) async{
    globals.tempData["joinlink"] = inputLink.replaceAll(new RegExp(r'/get_details'), '');
    http.Response response = await http.get(globals.tempData["joinlink"]); //get session details
    String body = response.body;
    globals.tempMeetingDetails = jsonDecode(body);
    print(globals.tempMeetingDetails);
    } //session details saved in global.tempMeetingDetals

  Future<int> getAllUserSessionsData(String inputUserId) async{
    Map tempMap = {};
    String url = '${globals.serverAddress}/session/get?username=$inputUserId';
    http.Response response = await http.get(url);
    tempMap = jsonDecode(response.body);
    tempMap.forEach((k, v) => sessionIDs.add(k));

    if (sessionIDs.length == 0) {
      return 0;
    } else {
      for( var i=0 ; i<sessionIDs.length ; i++ ){
        print(sessionIDs[i]);
        String url = '${globals.serverAddress}/session/${sessionIDs[i]}';
        http.Response response = await http.get(url);
        Map map = jsonDecode(response.body);
        allData.add(map);
        print("map: $map");

        //LABELS
        custLabels.add(map["meetup_name"]);
        print("custLabels: ${custLabels}");

        //IMAGES
        if (map["meeting_type"] == "outing"){custImgs.add("images/outing.jpg");}
        else if (map["meeting_type"] == "food"){custImgs.add("images/food.jpg");}
        else if (map["meeting_type"] == "meeting"){custImgs.add("images/meetingButton.jpg");}
        else{custImgs.add(map["images/meetingButton.jpg"]);}
        print("custImgs: $custImgs");

        //STATES
        if (map["session_status"] == "pending_members"){custStates.add("Pending Members");}
        else if (map["session_status"] == "pending_swipes"){custStates.add("Pending Swipes");}
        else if (map["session_status"] == "location_confirmed"){custStates.add("Location Confirmed");}
        else{custStates.add("SessionStateError");}
        print("custStates: ${custStates}");

        //
      }
      return 1;
    }
  } // list of all sessionIds saved in

  /////////////////////////////////////// [ALL WIDGETS] ///////////////////////////////////////////////

  //Helper method to create layout of the buttons
  Widget _buildCustomButton(String label, String imgName, String state) {
    return Container(
      height: 150.0,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(imgName),
              fit: BoxFit.cover
          )
      ),// set image background
      child: Container(
        height:57,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Colors.black54, Colors.white12],
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        alignment: Alignment.bottomLeft,
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                label,
                style: TextStyle(
                    fontFamily: "Quicksand",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
            ),
            Container(
              alignment: Alignment.bottomLeft,
              child: Text(
                state,
                style: TextStyle(
                    fontFamily: "Quicksand",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10),
              ),
            ),
          ],
        ),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(0.0),
    );
  }

  @override
  //Creates a list view with buildCustomButtons inside
  Widget build(BuildContext context) {

    custLabels = [];
    custImgs = [];
    custStates = [];
    sessionIDs = [];
    allData = [];

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
                        onPressed: () {
                          saveSessionDetailsFromLink(_joinController.text);
                          Navigator.push(context,MaterialPageRoute(builder: (context) => CustomizationPage2Widget()),);
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
              child: FutureBuilder<int>(
                future: getAllUserSessionsData(globals.uuid),
                builder: (BuildContext context, AsyncSnapshot<int> snapshot){
                    if (snapshot.data == 1){
                      return Container(
                        child: ListView.builder(
                          padding: EdgeInsets.only(top: 0, bottom: 0, left:4, right:4),
                          itemCount: custImgs.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: FlatButton(
                                padding: EdgeInsets.all(0),
                                onPressed: (){
                                  globals.sessionData = allData[index];
                                  globals.sessionData["sessionid"] = sessionIDs[index];
                                  globals.sessionData["url"] = "${globals.serverAddress}/session/${sessionIDs[index]}/get_details";
                                  print("Current Session Data ===> ${globals.sessionData}");
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => MeetupPage()),);
                                  },
                                child:_buildCustomButton(custLabels[index], custImgs[index], custStates[index]) ,
                              ),
                            );
                          },
                        ),
                      );
                    } else if(snapshot.data == 0){
                      return Padding(
                        padding: const EdgeInsets.only(left:40.0, right:40.0),
                        child: Center(
                          child: Text(
                            "No Active Meetup!",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Quicksand",
                              color: Colors.black45,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
              ),
            ),
          ),//list of stuff
        ],
      )

    );
  }
}