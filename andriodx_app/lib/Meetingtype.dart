import 'CustomizationPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Data.dart';


class MeetingType extends StatelessWidget {

  final PrefData data;
  MeetingType({this.data});

  final List<String> custLabels = [
    "Recreation",
    "Food",
    "Meeting",
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
        title: Text("Select Meetup Type"),
//        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: custImgs.length,
        itemBuilder: (context, index) {
          return Card(
            child: FlatButton(
              padding: EdgeInsets.all(0.0),
              onPressed: (){
                Navigator.push(context,MaterialPageRoute(builder: (context) => CustomizationPage(data: data)),);
                print("TEST: ${data.dataMap}");
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