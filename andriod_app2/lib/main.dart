import 'GoogleSignIn.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'BottomTab.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() => runApp(Phoenix(child: MyApp()));

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
                  print("Internet service unavailable");
                  return Center(child: Text("Please connect to the Internet!"));
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

