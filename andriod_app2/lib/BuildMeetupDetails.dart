import 'main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:geolocator/geolocator.dart';
import 'Globals.dart' as globals;


class MeetupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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

  List listofmembers = [
    {
      "identifier" : "identifier",
      "lat" : 0,
      "long" : 0,
      "transport_mode" : "Driving",
      "metrics" : {"speed":0, "quality":0, "price":0}
    },
    {
      "identifier" : "Julia Chua",
      "lat" : 1.332319,
      "long" : 103.672113,
      "transport_mode" : "Driving",
      "metrics" : {"speed":0, "quality":0, "price":0}
    },
    {
      "identifier" : "David Fan",
      "lat" : 1.332319,
      "long" : 103.672113,
      "transport_mode" : "Driving",
      "metrics" : {"speed":0, "quality":0, "price":0}
    },
  ]; //snapshot from future is added to this
  
  @override
  initState(){
    super.initState();
    globals.socketIO.joinSession("3046db10-9404-11ea-8bde-06b6ade4a06c");
    globals.socketIO.subscribe("user_joined_room", (data)=>{
      //whatever is inside here will run when server sends stuff
      print(data),
      listofmembers.add(data),
      print(listofmembers)
    });
  }

//  List listofplacenames(List _listofmembers) {
//    for (var index in _listofmembers) {
//    }
//  };

  Future<List<dynamic>> getMembers() async{}

  @override
  Widget build(BuildContext context) {

    Future<Null> _refresh() async {
      setState((){});
      return await Future.delayed(Duration(milliseconds: 1500));
    }

    Widget listSection = FutureBuilder(
      future: getMembers(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
//        listofmembers = snapshot.data;

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
            itemCount: listofmembers.length,
            itemBuilder: (BuildContext context, int index) {

              if (index == 0){ //means it is the meetup creator a.k.a first user on the list
                return ListTile(
                    leading: CircleAvatar(backgroundImage: AssetImage("images/mouseAvatar.jpg"),),
                    title: Text(globals.userGoogleData["name"]), //TODO
                    subtitle: Text(listofmembers[index]["transport_mode"].toString()),
                    trailing: Text(globals.userLocationName)
                );
              }
              return ListTile(
                leading: CircleAvatar(backgroundImage: AssetImage("images/mouseAvatar.jpg"),),
                title: Text(listofmembers[index]["identifier"].toString()),
                subtitle: Text(listofmembers[index]["transport_mode"].toString()),
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
          SizedBox(height:300),//temporary, remove when carousell ready
          Container(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Expanded(child: Text("Joining Mice", style: TextStyle(fontSize: 20),)),
            ),
          ),
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