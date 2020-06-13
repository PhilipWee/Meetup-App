import 'dart:convert';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

class CustomSocketIO {
  String url;
  String sessionID;
  SocketIO socketIO;
  List<String> subscribedEvents;

  ///Create a Socket Class that will work with the flask back end.
  ///
  ///Input the url of the Meetup Mouse website and save the instance of the class for use later
  ///
  ///Example:
  ///```socketIO = CustomSocketIO('http://10.0.2.2:5000');```
  CustomSocketIO(String url) {
    if (this.socketIO == null) {
      this.subscribedEvents = [];
      this.url = url;
      //Create the socket connection
      this.socketIO = SocketIOManager().createSocketIO(
        url,
        '/',
      );
      this.socketIO.init();
      this.socketIO.connect();
    } else {
      print("Socket already exists, why are you trying to recreate it?");
    }
  }

  _unSubscribeAll() {
    this.socketIO.unSubscribesAll();
    this.subscribedEvents = [];
    print("All sessions unsubscribed");
  }

  ///For joining a particular room
  ///
  ///Input the sessionID here, and you will be able to receive the socket io emits for that particular session.
  ///If you do not join a session the subscribe function WILL NOT WORK
  ///
  ///Example:
  ///```socketIO.joinSession('1111');```
  joinSession(String sessionID) {
    if (this.sessionID != null) {
      //Leave the session
      this.socketIO.sendMessage('leave', {'room': this.sessionID});
      this._unSubscribeAll();
    }
    this.sessionID = sessionID;
    this.socketIO.sendMessage('join', json.encode({'room': this.sessionID}));
  }

  ///For subscribing to events emitted by the server
  ///
  ///When the event with the specified name occurs, the inputted function will run
  ///depending on the data received from the server
  ///
  ///Example:
  ///```socketIO.subscribe('test', (data) => {print(data)});```
  ///
  ///In the above example, when the server emits the event 'test',
  ///the data is received in a Map<String,dynamic>. Hence by using the same
  ///format you are able to run whatever function you want within the curly braces
  ///in this case a print statement
  ///
  subscribe(String event, Function runOnEvent) {
    this.socketIO.unSubscribe(event);
    this.subscribedEvents.add(event);
    this.socketIO.subscribe(event, (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      runOnEvent(data);
    });
  }

  ///For emitting an event to the server
  ///
  ///When you need to send data to the server, this is the function
  ///
  ///Example:
  ///```socketIO.sendMessage('send_message', {'hello':'there'});```
  sendMessage(String event, Map<String, dynamic> data) {
    socketIO.sendMessage(event, json.encode(data));
  }
}
