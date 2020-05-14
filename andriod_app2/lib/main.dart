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
import 'BottomTab.dart';

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
                  return MyHomePage();
                default:
                  return Center(child: Text("No Internet Connection!"));
              }
            })
    );
  }
}

