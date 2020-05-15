import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'dart:convert';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'socketiohelper.dart';
import 'globals.dart' as globals;

void main() => runApp(MainApp());

class MainApp extends StatefulWidget {
  @override
  _MyAppWidget createState() => _MyAppWidget();
}

class _MyAppWidget extends State<MainApp> {
  CustomSocketIO socketIO;

  @override void initState() {
    
    super.initState();



    globals.socketIO.joinSession('000000');

    globals.socketIO.subscribe('test', (data) => {
      print('111111111111111111111111111'),
      print(data)
    });
    globals.socketIO.subscribe('test2', (data) => {
      print('2222222222222222222222222222222'),
      print(data)
    });
    globals.socketIO.subscribe('calculation_result', (data) => {
      print('333333333333333333333333333333'),
      print(data)
    });
    globals.socketIO.subscribe('bg_emit', (data) => {
      print('44444444444444444444444444444444'),
      print(data)
    });
    globals.socketIO.sendMessage('sending_data', {'hello':'there'});

    

    }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Center(child: Text("Hello"))),
      ),
    );
  }
}
