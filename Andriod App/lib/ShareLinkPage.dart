import 'main.dart';
import 'MapPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:geolocator/geolocator.dart';
import 'Data.dart';


class ShareLinkPage extends StatelessWidget {
  final PrefData data;
  ShareLinkPage({this.data,});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Share Meetup!"),
//        backgroundColor: Colors.black,
      ),
      body: ShareLinkWidget(data: data),
    );
  }
}

class ShareLinkWidget extends StatefulWidget {
  final PrefData data;
  ShareLinkWidget({this.data});
  @override
  ShareLinkState createState() => ShareLinkState(data: data);
}

class ShareLinkState extends State<ShareLinkWidget> {
  final PrefData data;
  ShareLinkState({this.data});
  List listofmembers = [];

  Future<List<dynamic>> getMembers(sessID) async {

    String address = globalurl();
    try{
      http.Response response = await http.get('$address/session/$sessID');
      await Future.delayed(Duration(milliseconds: 1500));
      int statusCode = response.statusCode;
      String body = response.body;
      print("GetMembers Request Successful/Failed With Status: $statusCode");

      if (statusCode != 200){
        Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text("Oops! Server Error 404"),
              duration: Duration(seconds: 2),
            ));
      }
      else{
        print("Members List: $body");
        Map<String, dynamic> memberDatajsonVersion = jsonDecode(body); //parse the data from server into a map<string,dynamic>
        List<dynamic> membersData = memberDatajsonVersion["users"];//extract the list of user detail maps into a list

//        for (Map<String, dynamic> mapcontent in membersData) {
//        };
//
//


        Map<String,String> placeNameMap = {"username": data.userplace }; //add the place name as a value to the key "username" to a new map
        for (Map<String, dynamic> mapcontent in membersData) { // for every user detail map packet in the main list
          if (mapcontent["lat"] != null && mapcontent["long"] != null && mapcontent["identifier"] != null){
//            List<Placemark> place = await Geolocator().placemarkFromCoordinates(double.parse(mapcontent["lat"]), double.parse(mapcontent["long"])); //use the lat long values to find the placename
            List<Placemark> place = await Geolocator().placemarkFromCoordinates(mapcontent["lat"], mapcontent["long"]); //use the lat long values to find the placename
            placeNameMap[mapcontent["identifier"].toString()] = place[0].thoroughfare.toString(); // add the placename to the map with the key being the name of the user
          }
          else{placeNameMap[mapcontent["identifier"].toString()] = "ERRROR";}
        }
        membersData.add(placeNameMap);
//        print("membersData-> $membersData");
        return membersData;
      }
    }
    catch(e){print("Get-session-details Failed with error: $e");}
  }

  Future checkMeetupDone(sessID) async{
    String address = globalurl();
    http.Response response = await http.get('$address/session/$sessID/results');
    await Future.delayed(Duration(milliseconds: 1500));
    int statusCode = response.statusCode;
    String body = response.body;
    print(statusCode);
    print(body);
  }

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
                    controller: TextEditingController(text:data.link),
                    decoration: InputDecoration(labelText: "Tap here for link", border: OutlineInputBorder())
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 5, right: 5),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15.0),
              child: ButtonTheme(
                minWidth: 180,
                height: 35,
                child: FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                  color: Colors.amber,
                  textColor: Colors.black,
                  onPressed: () {
//                    checkMeetupDone(data.sessionid);
                    Navigator.push(context,MaterialPageRoute(builder: (context) => MapSample(data:data)),);
                    print("TEST: ${data.dataMap}");
                  },
                  child: Text("Create Meetup!"), //TODO
                ),
              ),
            ),
          )
        ],
      ) ,
    );

    Future<Null> _refresh() async {
      setState((){});
      return await Future.delayed(Duration(milliseconds: 1500));
    }

    Widget listSection = Container(
      child:
      FutureBuilder(
        future: getMembers(data.sessionid),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          listofmembers = snapshot.data;
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
              itemCount: listofmembers.length-1,
              itemBuilder: (BuildContext context, int index) {
                Map<String,dynamic> myMap = snapshot.data[snapshot.data.length-1];
                if (index == 0){
                  return ListTile(
                      leading: CircleAvatar(backgroundImage: AssetImage("images/mouseAvatar.jpg"),),
                      title: Text(data.username),
                      subtitle: Text(snapshot.data[index]["transport_mode"].toString()),
                      trailing: Text(myMap["username"].toString())
                  );
                }
                return ListTile(
                  leading: CircleAvatar(backgroundImage: AssetImage("images/mouseAvatar.jpg"),),
                  title: Text(snapshot.data[index]["identifier"].toString()),
                  subtitle: Text(snapshot.data[index]["transport_mode"].toString()),
                  trailing: Text(myMap[snapshot.data[index]["identifier"]].toString()),
                );
              },
            ) , onRefresh: _refresh,
            ));
          }
        },
      ),
    );

    return Scaffold(
      body: Column(
        children:[
          linkSection,
          Text("Scroll to refresh" , style: TextStyle(fontWeight: FontWeight.w100),),
          listSection,
          buttonSection,
        ],
      ),
    );
  }


  Future<void> _shareText() async {
    try {
      Share.text('Link', data.link, 'text/plain');
    } catch (e) {
      print('error: $e');
    }
  }

}