import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'main.dart';

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