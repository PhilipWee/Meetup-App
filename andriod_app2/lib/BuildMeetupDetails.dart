import 'main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:geolocator/geolocator.dart';
import 'Globals.dart' as globals;
import 'package:flutter/services.dart';


class MeetupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Share Meetup!"),
//        backgroundColor: Colors.black,
      ),
      body: MeetupPageWidget(),
    );
  }
}

class MeetupPageWidget extends StatefulWidget {
  @override
  MeetupPageState createState() => MeetupPageState();
}

class MeetupPageState extends State<MeetupPageWidget> {

  /////////////////////////////////////////////////////////////////////// [FUNCTIONS]

  Future<List<dynamic>> getMembers() async{}

  @override
  initState(){
    super.initState();
    globals.socketIO.joinSession("3046db10-9404-11ea-8bde-06b6ade4a06c");
    globals.socketIO.subscribe("user_joined_room", (data)=>{
      //whatever is inside here will run when server sends stuff
      print(data),
      globals.fakelistofmembers.add(data),
      print(globals.fakelistofmembers)
    });
  } //SOCKETS

  /////////////////////////////////////////////////////////////////////// [WIDGETS]

  @override
  Widget build(BuildContext context) {

    Future<Null> _refresh() async {
      setState((){});
      return await Future.delayed(Duration(milliseconds: 1500));
    }

    Widget generateButton = Container(
      height: 50.0,
      child: Expanded(
        flex: 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15.0, top: 8, bottom: 8),
                child: ButtonTheme(
                  minWidth: 150,
                  height: 50,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                    color: Colors.deepOrange,
                    textColor: Colors.white,
                    onPressed: () async{
                    },
                    child: Text('Search Places', style: TextStyle(fontFamily: "Quicksand")),
                  ),
                ),
              ),
            )
          ],
        ),
      ) ,
    );

    Widget listSection = FutureBuilder(
      future: getMembers(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
//        listofmembers = snapshot.data;

        if(globals.fakelistofmembers == null){
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
            itemCount: globals.fakelistofmembers.length,
            itemBuilder: (BuildContext context, int index) {

              if (index == 0){ //means it is the meetup creator a.k.a first user on the list
                return ListTile(
                    leading: CircleAvatar(backgroundImage: AssetImage("images/mouseAvatar.jpg"),),
                    title: Text(globals.username), //TODO
                    subtitle: Text(globals.fakelistofmembers[index]["transport_mode"].toString()),
                    trailing: Text(globals.userLocationName)
                );
              }
              return ListTile(
                leading: CircleAvatar(backgroundImage: AssetImage("images/mouseAvatar.jpg"),),
                title: Text(globals.fakelistofmembers[index]["identifier"].toString()),
                subtitle: Text(globals.fakelistofmembers[index]["transport_mode"].toString()),
                trailing: Text(""),
              );
            },
          ) , onRefresh: _refresh,
          ));
        }
      },
    );

    return Scaffold(
      body: Column(
        children:[
          Container(
            child: Padding(
              padding: const EdgeInsets.only(top:20, bottom:8, left:12, right:10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: TextField(
                        controller: TextEditingController(text:globals.tempData["link"]),
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
            ),
          ),//copy or share link
          Visibility(
              visible: true,
              child: Container(child: generateButton,)
          ),// generateButton
          Container(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top:8, bottom:8, left:15, right:8),
                  child: Expanded(child: Text("Joining Mice: 16", style: TextStyle(fontSize: 20),)),
                ),
              ],
            ),
          ), //no. of members
          Divider(height: 15,color: Colors.black12, thickness: 1.5, indent: 10, endIndent: 10,),
          Text("Scroll to refresh" , style: TextStyle(fontWeight: FontWeight.w100),),
          Container(child: listSection),
        ],
      ),
    );
  }


  Future<void> _shareText() async {
    try {
      Share.text('Link', "inseretlink", 'text/plain'); //TODO
    } catch (e) {
      print('error: $e');
    }
  }

}