import 'package:flutter/material.dart';

class Homescreen extends StatelessWidget {
  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(
            child: Text('My Meetups', style: TextStyle(fontWeight: FontWeight.bold),)),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
}

class HomeUsernameWidget extends StatefulWidget {
  @override
  HomeUsernameState createState() => HomeUsernameState();
}

class HomeUsernameState extends State<HomeUsernameWidget> {

  final List<String> custLabels = [
    "F07 Reunion",
    "Dinner Date - Stacy",
    "UROP Meeting",
  ];
  final List<String> custImgs = [
    "images/outing.jpg",
    "images/food.jpg",
    "images/meetingButton.jpg",
  ];

  @override
  //Creates a listview with buildCustomButtons inside
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('My Meetups', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: custImgs.length,
        itemBuilder: (context, index) {
          return Card(
            child: FlatButton(
              padding: EdgeInsets.all(0.0),
              onPressed: (){
//                Navigator.push(context,MaterialPageRoute(builder: (context) => MeetupPage1()),);
              },
              child:_buildCustomButton(custLabels[index], custImgs[index]) ,
            ),
          );
        },
      ),

    );
  }

  //Helper method to create layout of the buttons
  Container _buildCustomButton(String label, String imgName) {
    return Container(
      height: 200.0,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(imgName),
              fit: BoxFit.cover
          )
      ),
      child: Container(
        height: 50.0,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Colors.black54, Colors.white12],
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        alignment: Alignment.bottomLeft,
        child: Text(
          label,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(0.0),
    );
  }


}