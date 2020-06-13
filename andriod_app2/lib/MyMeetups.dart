import 'package:andriod_app2/BuildMeetupDetails.dart';
import 'package:andriod_app2/ResultsSwipePage.dart';
import 'package:flutter/material.dart';
import 'Globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'Join.dart';
import 'color_loader.dart';


class HomeUsernameWidget extends StatefulWidget {
  @override
  HomeUsernameState createState() => HomeUsernameState();
}

class HomeUsernameState extends State<HomeUsernameWidget> {

  List<Color> colorsForLoad = [
    Colors.red,
    Colors.green,
    Colors.indigo,
    Colors.pinkAccent,
    Colors.blue
  ];

  Future _future;

  bool invalidLink = false;

  final _joinController = TextEditingController(text: "");

  List allData = [];
  List<String> custLabels = [];
  List<String> custImgs = [];
  List<String> custStates = [];
  List<String> sessionIDs = [];

  @override
  initState(){
    super.initState();
    _future = getAllUserSessionsData(globals.uuid);
  }

  //////////////////////////////////// [ALL FUNCTIONS] /////////////////////////////////////////////////

  sessionEnter(String inputLink) async{
    print("INPUTLINK $inputLink");
    globals.tempData["joinlink"] = inputLink.replaceAll(new RegExp(r'/get_details'), '');
    http.Response response = await http.get(globals.tempData["joinlink"]); //get session details
    String body = response.body;
    globals.tempMeetingDetails = jsonDecode(body);
    print("Current Session Details ===> ${globals.tempMeetingDetails}");
    } //session details saved in global.tempMeetingDetails


  Future getAllUserSessionsData(String inputUserId) async{
    String url = '${globals.serverAddress}/session/get?username=$inputUserId';
    http.Response response = await http.get(url);
    Map tempMap = jsonDecode(response.body);
    print("Server Response: $tempMap");
    tempMap.forEach((k, v) => sessionIDs.add(k));

      for( var i=0 ; i<sessionIDs.length ; i++ ){
        print("");
        print("Session ID: ${sessionIDs[i]}");
        String url = '${globals.serverAddress}/session/${sessionIDs[i]}';
        http.Response response = await http.get(url);
        Map map = jsonDecode(response.body);

        allData.add(map);

        if (allData[0] == "error"){
          print(allData);
        }
        else{ //for println spacing
          print("Time Created: ${map["time_created"]}"); //TODO BUILD LIST IN ORDER OF TIME

          //LABELS
          custLabels.add(map["meetup_name"]);
          print("Meetup Name: ${custLabels[i]}");

          //IMAGES//YOLO
          if (map["meeting_type"] == "outing"){custImgs.add("images/purple.png");}
          else if (map["meeting_type"] == "food"){custImgs.add("images/yellow.png");}
          else if (map["meeting_type"] == "meeting"){custImgs.add("images/blue.png");}
          print("Meeting Image: ${custImgs[i]}");

          //STATES
          if (map["session_status"] == "pending_members"){custStates.add("Pending Members");}
          else if (map["session_status"] == "pending_swipes"){custStates.add("Pending Swipes");}
          else if (map["session_status"] == "location_confirmed"){custStates.add("Location Confirmed");}
          print("Session State: ${custStates[i]}");
          print(""); //for println spacing
        }
      }
    print("allData: $allData");
  } // list of all sessionIds saved in

  Future<Null> _refresh() async{
    _future = getAllUserSessionsData(globals.uuid);
    setState((){});
  }

  sessionRemove(String inputSessionID) async {
    //send json package to server as POST
    Map<String, String> headers = {"Content-type": "application/json"};
    String url = '${globals.serverAddress}/edit_session';

    String jsonpackage = '{ '
        '"action":"remove_user", '
        '"session_id":"$inputSessionID", '
        '"uuid":"${globals.uuid}" '
        '}';

    print("[sessionRemove] Sending Jsonpackage To Server >>> $jsonpackage");
    print("Removing $inputSessionID");

    try{
      http.Response response = await http.post(url, headers:headers, body:jsonpackage);
      int statusCode = response.statusCode;

      if (statusCode != 200){
        print(response.body);
        Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text("Oops! Server Error. StatusCode:$statusCode"),
              duration: Duration(milliseconds: 800)
            ));
      }
      else{
        print(response.body);
      }
    }
    catch(e){print("Error caught at sessionRemove(): $e");}
  }

  /////////////////////////////////////// [ALL WIDGETS] ///////////////////////////////////////////////

  //Helper method to create layout of the buttons
  Widget _buildCustomButton(String label, String imgName, String state) {

    if (imgName == "images/purple.png"){return Container(
      height: 150.0,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(imgName),
              fit: BoxFit.cover
          )
      ),// set image background
      child: Container( // yolo
        height:57,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(139, 73, 161, 0.7),
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
    );}
    else if (imgName == "images/yellow.png"){return Container(
      height: 150.0,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(imgName),
              fit: BoxFit.cover
          )
      ),// set image background
      child: Container( // yolo
        height:57,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(247, 147, 30, 0.7),
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
    );}
    else if (imgName == "images/blue.png"){return Container(
      height: 150.0,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(imgName),
              fit: BoxFit.cover
          )
      ),// set image background
      child: Container( // yolo
        height:57,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(19, 176, 190, 0.7),
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
    );}
    else {return Center(child: Text("ListTile Error"),);}
  }

  Widget slideRightBackground() {
    return Container(
      color: Colors.grey,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.archive,
              color: Colors.white,
            ),
//            Text(
//              " Edit",
//              style: TextStyle(
//                color: Colors.white,
//                fontWeight: FontWeight.w700,
//              ),
//              textAlign: TextAlign.left,
//            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.redAccent,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
//            Text(
//              " Delete",
//              style: TextStyle(
//                color: Colors.white,
//                fontWeight: FontWeight.w700,
//              ),
//              textAlign: TextAlign.right,
//            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  @override
  //Creates a list view with buildCustomButtons inside
  Widget build(BuildContext context) {

    //this code resets the below and prevents from returning cloned cards
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
                            labelText: "Joining meetup? Place meeting link here!",
                            border: OutlineInputBorder(gapPadding: 0),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.person_add),
                        onPressed: () async {
                          if (_joinController.text.isEmpty) {
                            Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Enter Link!",
                                    style: TextStyle(fontWeight: FontWeight.w400, fontFamily: "Quicksand",),
                                    textAlign: TextAlign.center,
                                  ),
                                  duration: Duration(milliseconds: 400),
                                ));
                          }
                          else{
                            globals.saveMyLocationName();
                            sessionEnter(_joinController.text);

                            showDialog(
                                context: context,
                                builder: (context)
                                {Future.delayed(Duration(milliseconds: 2000), () {
                                    _joinController.clear();
                                    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>CustomizationPage2Widget()),);;
                                  });
                                return Center(child: CircularProgressIndicator());
                                });
                          }
                        },
                        iconSize: 25,
                        color: Colors.black87,
                      )
                    ],
                  ),
                ),
              )
            ],

          ),//join text controller

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
              padding: const EdgeInsets.all(1),
              child: Center(
                  child: Text(
                    "Scroll to refresh  |  Swipe to delete" ,
                    style: TextStyle(
                        fontWeight: FontWeight.w100,
                        color: Colors.black.withOpacity(1)
                    )

                  )
              ),
            )
            ],
          ),//scroll to refresh

          Expanded(
            child: FutureBuilder(
              future: _future,
              builder: (BuildContext context, AsyncSnapshot snapshot){
                  if (snapshot.connectionState ==  ConnectionState.done && allData.isEmpty){
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      children: <Widget>[Padding(
                        padding: const EdgeInsets.only(top: 200),
                        child: Center(
                            child: Text(
                                "No Meetups",
                                style: TextStyle(
                                    fontFamily: "Quicksand",
                                    color: Colors.black.withOpacity(0.6)
                                )
                            )
                        ),
                      ),
                      ],
                    )
                  );
                }
                  else if (snapshot.connectionState ==  ConnectionState.done){
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: 0, bottom: 0, left:5, right:5),
                        itemCount: custLabels.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Dismissible(
                              key: Key(custLabels[index]),
                              dismissThresholds: {DismissDirection.endToStart : 0.4, DismissDirection.startToEnd: 1.0},
                              background: slideRightBackground(),
                              secondaryBackground: slideLeftBackground(),
                              child: Container(
                                child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: (){

                                    globals.sessionData = {};
                                    globals.sessionUrlCarrier = "";
                                    globals.sessionIdCarrier = "";

                                    globals.sessionData = allData[index];
                                    globals.sessionIdCarrier = sessionIDs[index]; ///NEW DATA
                                    globals.sessionUrlCarrier = "${globals.serverAddress}/session/${sessionIDs[index]}/get_details";

                                    print("Current SessionID===>${globals.sessionIdCarrier}");
                                    print("Current Session URL===>${globals.sessionUrlCarrier}");
                                    print("Current Session Data ===> ${globals.sessionData}");
                                    print("Current Session Status ===> ${globals.sessionData["session_status"]}");

                                    if (globals.sessionData["session_status"] == "pending_swipes") {
                                      if (globals.sessionData["swipe_details"].isNotEmpty){
                                        if (globals.sessionData["swipe_details"].containsKey(globals.uuid)){
                                          if (globals.sessionData["swipe_details"][globals.uuid].length < 20){
                                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResultSwipePage()),);
                                          }
                                        }
                                      }
                                    }

                                    else{
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MeetupPage()),);
                                    }
                                  },

                                  child:_buildCustomButton(custLabels[index], custImgs[index], custStates[index]) ,
                                ),
                              ),
                              onDismissed: (direction) async{
                                if (direction == DismissDirection.endToStart) {
                                  sessionRemove(sessionIDs[index]);
                                  setState(() {
                                    custLabels.removeAt(index);
//                                    _future = getAllUserSessionsData(globals.uuid); //refreshes on delete
                                  });
                                  Scaffold.of(context).showSnackBar(SnackBar(content: Text("Deleted ${custLabels[index]}", textAlign: TextAlign.center,),));
                                }
                                else {
                                  Scaffold.of(context).showSnackBar(SnackBar(content: Text("COMING SOON! (ᵔᴥᵔ)", textAlign: TextAlign.center,),));
                                }
                              }
                            ),
                          );
                        },
                      ),
                    );
                  }
                  else if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(child: ColorLoader(colors: colorsForLoad, duration: Duration(milliseconds: 1000)));
                }
                  else {return Center(child: Text("SNAPSHOT ERROR: ${snapshot.error}"),);}
                },
            ),
          ),//list of stuff
        ],
      )

    );
  }
}