import 'package:flutter/material.dart';
import 'MyMeetups.dart';
import 'Create.dart';
import 'Profile.dart';
import 'Globals.dart' as globals;


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

  @override
  void initState() {
    super.initState();
    globals.saveMyLocationName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: pageList[_selectedPage],

//      body: IndexedStack(
//        index: _selectedPage,
//        children: pageList,
//      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepOrange,
        selectedItemColor: Colors.white,
        selectedFontSize: 15,
        unselectedItemColor: Colors.white70,
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
        onTap: _onItemTapped,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  void _onItemTapped(int index) {
    setState(() {
      globals.saveMyLocationName();
      globals.resetempData();
      _selectedPage = index;
    });
  }
}