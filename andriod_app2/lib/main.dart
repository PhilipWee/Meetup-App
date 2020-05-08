import 'dart:convert';
import 'package:andriod_app2/JoinCreate.dart';
import 'package:andriod_app2/MyMeetups.dart';
import 'package:andriod_app2/Profile.dart';
import 'GoogleSignIn.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'MyMeetups.dart';
import 'JoinCreate.dart';
import 'Profile.dart';

String globalurl(){
//   String serverAddress = "http://192.168.194.178:5000";
//   String serverAddress = "http://169.254.158.154:5000";
//  String serverAddress = "http://ec2-3-16-181-51.us-east-2.compute.amazonaws.com:5000";
  String serverAddress = "http://ec2-3-14-68-232.us-east-2.compute.amazonaws.com:5000";
  return serverAddress;
}


void main() => runApp(MyApp());

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
        '/': (context) => GoogleSignInPage(),
      },
    );
  }
}

class GoogleSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class CheckNetworkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  return HomeScreen();
                default:
                  return Center(child: Text("No Internet Connection!"));
              }
            })
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {return _HomeState();}
}

class _HomeState extends State<Home> {

  int _currentIndex = 0;
  final List<Widget> _children = [

    HomeUsernameWidget(),

    CustomizationPageWidget(),

    ProfilePage()

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex], // new
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            title: Text('Meetups', style: TextStyle(fontFamily: "Quicksand")),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.add_location),
            title: Text('Join/Create', style: TextStyle(fontFamily: "Quicksand")),
          ),
          new BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              title: Text('Profile', style: TextStyle(fontFamily: "Quicksand"))
          )
        ],
        backgroundColor: Colors.deepOrange,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
      ),
    );
  }
  void onTabTapped(int index) {
    setState(() {_currentIndex = index;});
  }
}
