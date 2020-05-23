import 'package:andriod_app2/BuildMeetupDetails.dart';
import 'package:flutter/material.dart';
import 'Globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'Globals.dart' as globals;
import 'Join.dart';


class HomeUsernameWidget extends StatefulWidget {
  @override
  HomeUsernameState createState() => HomeUsernameState();
}

class HomeUsernameState extends State<HomeUsernameWidget> {


  bool invalidLink = false;

  final _joinController = TextEditingController(text: "");

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

  void sessionEnter(String inputLink) async{
    globals.tempData["joinlink"] = inputLink.replaceAll(new RegExp(r'/get_details'), '');
    http.Response response = await http.get(globals.tempData["joinlink"]); //get session details
    String body = response.body;
    globals.tempMeetingDetails = jsonDecode(body);
    print("Current Session Details ===> ${globals.tempMeetingDetails}");
    } //session details saved in global.tempMeetingDetals

  Future getAllUserSessionsData(String inputUserId) async{
    String url = '${globals.serverAddress}/session/get?username=$inputUserId';
    http.Response response = await http.get(url);
    Map tempMap = jsonDecode(response.body);
    tempMap.forEach((k, v) => sessionIDs.add(k));
    print("sessiondIDs length: ${sessionIDs.length}");

//    if (sessionIDs.length == 0 || sessionIDs.isEmpty) {return 0;}
//    else {
      for( var i=0 ; i<sessionIDs.length ; i++ ){
        print("Session ID: ${sessionIDs[i]}");
        String url = '${globals.serverAddress}/session/${sessionIDs[i]}';
        http.Response response = await http.get(url);
        Map map = jsonDecode(response.body);
        allData.add(map);
        if (allData[0] == "error"){
          print(allData);
//          return null;
        }
        else{
          print(""); //for println spacing
          print("Time Created: ${map["time_created"]}"); //TODO BUILD LIST IN ORDER OF TIME

          //LABELS
          custLabels.add(map["meetup_name"]);
          print("Meetup Name: ${custLabels[i]}");

          //IMAGES
          if (map["meeting_type"] == "outing"){custImgs.add("images/outing.jpg");}
          else if (map["meeting_type"] == "food"){custImgs.add("images/food.jpg");}
          else if (map["meeting_type"] == "meeting"){custImgs.add("images/meetingButton.jpg");}
          print("Meeting Image: ${custImgs[i]}");

          //STATES
          if (map["session_status"] == "pending_members"){custStates.add("Pending Members");}
          else if (map["session_status"] == "pending_swipes"){custStates.add("Pending Swipes");}
          else if (map["session_status"] == "location_confirmed"){custStates.add("Location Confirmed");}
          print("Session State: ${custStates[i]}");
          print(""); //for println spacing
        }
      }
//      return 1;
//    }
  } // list of all sessionIds saved in

  Future<Null> _refresh() async {
    setState((){});
    return await Future.delayed(Duration(milliseconds: 1000));
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
                            labelText: "Joining meetup? Place meeting link here!",
                            border: OutlineInputBorder(gapPadding: 0),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.person_add),
                        onPressed: () async{
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
                              await Future.delayed(Duration(milliseconds:2000)); //TODO TIME.SLEEP FOR JOINING SESSION
                              _joinController.clear();
                              Navigator.push(context,MaterialPageRoute(builder: (context) =>CustomizationPage2Widget()),
                              );
                            }
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
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Center(child: Text("Scroll to refresh" , style: TextStyle(fontWeight: FontWeight.w200),)),
            ),
          ),
          Container(
            child: Expanded(
              child: FutureBuilder(
                future: getAllUserSessionsData(globals.uuid),
                builder: (BuildContext context, AsyncSnapshot snapshot){
                    if (snapshot.connectionState ==  ConnectionState.done){
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: 0, bottom: 0, left:4, right:4),
                        itemCount: custLabels.length,
                        itemBuilder: (context, index) {
                          final item = custLabels[index];
                          return Dismissible(
                            child: Card(
                              child: FlatButton(
                                padding: EdgeInsets.all(0),
                                onPressed: (){
                                  globals.isCalculating = false;
                                  globals.sessionData = allData[index];
                                  globals.sessionData["sessionid"] = sessionIDs[index];
                                  globals.sessionData["url"] = "${globals.serverAddress}/session/${sessionIDs[index]}/get_details";
                                  print("Current Session Data ===> ${globals.sessionData}");
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => MeetupPage()),);
                                },
                                child:_buildCustomButton(custLabels[index], custImgs[index], custStates[index]) ,
                              ),
                            ),
                            key: Key(item),
                            onDismissed: (direction){
                              sessionRemove(sessionIDs[index]);
                              custLabels.removeAt(index);
//                              setState(() {custLabels.removeAt(index);});
                              Scaffold.of(context).showSnackBar(SnackBar(content: Text("Deleted $item", textAlign: TextAlign.center,),));
                            }
                          );
                        },
                      ),
                    );
                  }
                    else if(snapshot.connectionState == ConnectionState.waiting){
                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.builder(
                          padding: EdgeInsets.only(top: 0, bottom: 0, left:4, right:4),
                          itemCount: custLabels.length,
                          itemBuilder: (context, index) {
                            final item = custLabels[index];
                            return Dismissible(
                                child: Card(
                                  child: FlatButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: (){
                                      globals.isCalculating = false;
                                      globals.sessionData = allData[index];
                                      globals.sessionData["sessionid"] = sessionIDs[index];
                                      globals.sessionData["url"] = "${globals.serverAddress}/session/${sessionIDs[index]}/get_details";
                                      print("Current Session Data ===> ${globals.sessionData}");
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => MeetupPage()),);
                                    },
                                    child:_buildCustomButton(custLabels[index], custImgs[index], custStates[index]) ,
                                  ),
                                ),
                                key: Key(item),
                                onDismissed: (direction){
                                  sessionRemove(sessionIDs[index]);
                                  setState(() {custLabels.removeAt(index);});
                                  Scaffold.of(context).showSnackBar(SnackBar(content: Text("Deleted $item", textAlign: TextAlign.center,),));
                                }
                            );
                          },
                        ),
                      );
                  }
                    else {
                      return Center(child: Text("SNAPSHOT ERROR: ${snapshot.error}"),);
                    }
//                    else {return Center(
//                        child: CircularProgressIndicator()
//                    );}
                  },
              ),
            ),
          ),//list of stuff
        ],
      )

    );
  }
}