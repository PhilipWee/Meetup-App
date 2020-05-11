import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'dart:convert';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'socketiohelper.dart';

void main() => runApp(MainApp());

class MainApp extends StatefulWidget {
  @override
  _MyAppWidget createState() => _MyAppWidget();
}

class _MyAppWidget extends State<MainApp> {
  CustomSocketIO socketIO;

  @override void initState() {
    
    super.initState();



    socketIO = CustomSocketIO('http://10.0.2.2:5000');

    socketIO.joinSession('1111');


    socketIO.subscribe('test', (data) => {
      print(data)
    });
    
    socketIO.sendMessage('sending_data', {'hello':'there'});

    

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
