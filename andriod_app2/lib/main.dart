import 'dart:convert';
import 'package:andriod_app2/ResultsSwipePage.dart';
import 'GoogleSignIn.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'MyMeetups.dart';
import 'Create.dart';
import 'Profile.dart';
import 'PopUp.dart';
import 'BuildMeetupDetails.dart';
import 'Globals.dart' as globals;
import 'Join.dart';

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
//        '/': (context) => MeetupPage(),
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

  String myLocationName = "";

  final List<Widget> _children = [
    HomeUsernameWidget(),
    CustomizationPageWidget(),
    ProfilePage()
  ];

  /////////////////////////////////////////////////////////////////////// [WIDGETS]

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
            title: Text('Create Meetup', style: TextStyle(fontFamily: "Quicksand")),
          ),
          new BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              title: Text('Profile', style: TextStyle(fontFamily: "Quicksand"))
          )
        ],
        backgroundColor: Colors.deepOrange,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
      ),
    );
  }

  void onTabTapped(int index) async{
    globals.resetempData();
    setState(() {_currentIndex = index;});
  }

  showPopup(BuildContext context, Widget widget, String title,
      {BuildContext popupContext}) {
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
              title: Text(title),
              leading: new Builder(builder: (context) {
                return IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    try {
                      Navigator.pop(context); //close the popup
                    } catch (e) {}
                  },
                );
              }),
              brightness: Brightness.light,
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
