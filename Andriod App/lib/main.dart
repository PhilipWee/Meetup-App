import 'MapPage.dart';
import 'ShareLinkPage.dart';
import 'CustomizationPage.dart';
import 'Meetingtype.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity/connectivity.dart';
import 'color_loader.dart';

String globalurl(){
//   String serverAddress = "http://192.168.194.178:5000";
//   String serverAddress = "http://169.254.158.154:5000";
  String serverAddress = "http://ec2-3-16-181-51.us-east-2.compute.amazonaws.com:5000";
  return serverAddress;
}

void main() => runApp(MyApp());

class PrefData {
  String username;
  String activityType;
  double lat;
  double long;
  String link;
  String transportMode;
  int speed;
  int quality;
  String sessionid;
  int price;
  PrefData({this.username,this.transportMode, this.quality, this.speed, this.link, this.lat, this.long, this.activityType,this.sessionid,this.price});
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xffff6347),
        fontFamily: 'Quicksand'
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => CheckNetworkPage(),
      },
    );
  }
}

class CheckNetworkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text(""),
        // ),
        body: StreamBuilder(
            stream: Connectivity().onConnectivityChanged,
            builder: (BuildContext ctxt,
                AsyncSnapshot<ConnectivityResult> snapShot) {
              if (!snapShot.hasData) return CircularProgressIndicator();
              var result = snapShot.data;
              switch (result) {
                case ConnectivityResult.none:
                  print("Internet servie unavailable");
                  return Center(child: Text("No Internet Connection!"));
                case ConnectivityResult.mobile:
                case ConnectivityResult.wifi:
                  print("Connected to Internet!");
                  return HomeScreen();
                default:
                  return Center(child: Text("No Internet Connection!"));
              }
            })
      );
  }
}

refreshServer() async {
  String address = globalurl();
  try{
    http.Response response = await http.get('$address/refresh');
    int statusCode = response.statusCode;
    String body = response.body;
    print("SERVER REFRESHED WITH STATUSCODE: $statusCode");
    print("SERVER SAYS: $body");
    }
  catch(e){print(e);}
}

class HomeScreen extends StatelessWidget {
  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Home', style: TextStyle(fontWeight: FontWeight.bold),),
//        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.list),
          onPressed: (){
            _scaffoldKey.currentState.openDrawer();
          },
        ),
      ),
      body: HomeUsernameWidget(),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Meetup Mouse',style: TextStyle(
                color: Colors.white,
                fontSize: 23
                ),
              ),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.black,
              ),
            ),
            ListTile(
              title: Text('Account'),
              onTap: () {
                //TODO
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                // TODO
              },
            ),
            ListTile(
              title: Text('Contact Us'),
              onTap: () {
                //TODO
              },
            ),
            ListTile(
              title: Text('Exit'),
              onTap: () {
                //TODO
              },
            ),
          ],
        ),
      ),
      );
  }

}

class HomeUsernameWidget extends StatefulWidget {
  @override
  HomeUsernameState createState() => HomeUsernameState();
}

class HomeUsernameState extends State<HomeUsernameWidget> {
  static String name;
  final data = PrefData(username:"",activityType: "",lat: 0,long: 0,link:"",transportMode: "",speed: 0, quality: 0,sessionid: '');
  final textController  = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Logo and start message
    Widget welcomeSection = Container(
      margin: const EdgeInsets.only(left: 50.0, top: 20.0, right: 50.0),
      alignment: Alignment.center,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left:20.0, right: 20.0, top:20.0, bottom: 20.0),
            child: Image.asset(
              'images/Mouse_copy.png',
              scale: 3,
            ),
          ),
          Text(
            "Start Your Meetup!",
            style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
                fontFamily: 'Pacifico'
            ),
          )
        ],
      ),
    );

    //Button Section
    Widget buttonSection =  Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton(
              onPressed: () {
//                refreshServer();
//                saveLocation();
                if (textController.text != "") {
                  name = textController.text;
                  data.username = name;
                  Navigator.push(context,MaterialPageRoute(builder: (context) => MeetingType(data : data)),);
                } else {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please enter your username!"),
                        duration: Duration(seconds: 2),
                      ));
                }},
              child: _buildButtonColumn(Colors.black, Icons.arrow_forward, 'Get Started!'),
              color: Colors.amber,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            )
          ],
        ) ,
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  child: Text( "OR", style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 20.0
                  ),
                  )
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatButton(
                    onPressed: () {
                      if (textController.text != "") {
                        Navigator.push(context,MaterialPageRoute(builder: (context) => ShareLinkPage(data : data)),);
                      } else {
                        Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text("There is no ongoing session!"),
                              duration: Duration(seconds: 2),
                            ));
                      }
                    },
                    child: _buildButtonColumn(Colors.black, Icons.autorenew, 'Go to My Meetup!'),
                    color: Colors.lightBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  )
                ],
              ),
              Container(
                child: Text("       "),
              ),
            ],
          )
      ],
    );


    return Center(
        child: ListView(
          children:[
            welcomeSection,
            Padding(
              padding: const EdgeInsets.only(left: 50.0, top: 20.0, right: 50.0, bottom: 50.0),
              child: TextFormField(
                controller: textController,
                decoration: InputDecoration(
                    labelText: "Username"
                ),
              ),
            ),
            buttonSection,
          ],
        )
    );
  }

  //Helper method to create button icons with text
  Row _buildButtonColumn(Color color, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        Icon(icon, color: color),
      ],
    );
  }

}


