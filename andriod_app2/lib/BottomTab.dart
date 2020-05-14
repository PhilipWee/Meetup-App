import 'package:flutter/material.dart';
import 'MyMeetups.dart';
import 'Create.dart';
import 'Profile.dart';
import 'PopUp.dart';
import 'BuildMeetupDetails.dart';
import 'Globals.dart' as globals;
import 'Join.dart';


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _selectedPage = 0;

  List<Widget> pageList = [
    HomeUsernameWidget(),
    CustomizationPageWidget(),
    ProfilePage()
  ];

//  @override
//  void initState() {
//    super.initState();
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedPage,
        children: pageList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            title: Text('Meetups', style: TextStyle(fontFamily: "Quicksand")),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location),
            title: Text('Create Meetup', style: TextStyle(fontFamily: "Quicksand")),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              title: Text('Profile', style: TextStyle(fontFamily: "Quicksand"))
          )
        ],
        currentIndex: _selectedPage,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedPage = index;
    });
  }
}