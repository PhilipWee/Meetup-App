import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ProfilePageState createState() => new _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final String imgUrl = 'https://instagram.fsin5-1.fna.fbcdn.net/v/t51.2885-19/s320x320/50970111_363470467763943_4307712117529640960_n.jpg?_nc_ht=instagram.fsin5-1.fna.fbcdn.net&_nc_ohc=hQGxnWLr1sUAX-fK7EW&oh=697905853376c6bae9163c7eb70b4a22&oe=5EDD1282';

    return new Stack(children: <Widget>[
      new Container(color: Colors.deepOrange,),
      new Image.network(imgUrl, scale: 0.1, fit: BoxFit.fitWidth,),
      new BackdropFilter(
          filter: new ui.ImageFilter.blur(
            sigmaX: 6.0,
            sigmaY: 6.0,
          ),
          child: new Container(
            decoration: BoxDecoration(
              color:  Colors.deepOrange.withOpacity(0.7),
              borderRadius: BorderRadius.all(Radius.circular(50.0)),
            ),)),
      new Scaffold(
          drawer: new Drawer(child: new Container(),),
          backgroundColor: Colors.transparent,
          body: new Center(
            child: new Column(
              children: <Widget>[
                new SizedBox(height: _height/12,),
                new CircleAvatar(radius:_width<_height? _width/6:_height/6,backgroundImage: NetworkImage(imgUrl),),
                new SizedBox(height: _height/25.0,),
                new Text('Stephen Alvin', style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: _width/15,
                    color: Colors.white,
                    fontFamily: "Quicksand",
                ),),
                new Padding(
                  padding: new EdgeInsets.only(left: _width/4, right: _width/4),
                  child: new FlatButton(onPressed: (){}, textColor: Colors.white,
                    child: new Container(
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Icon(Icons.person),
                            new SizedBox(width: _width/30,),
                            new Text('Edit Profile')
                          ],)),color: Colors.white.withOpacity(0),),),
                new Padding(padding: new EdgeInsets.only(left: _width/8, right: _width/8),
                  child:new Text('Bio: I love salty and spicy stuff. Follow me on Instagram! @stepkab00m ',
                    style: new TextStyle(
                      fontFamily: "Quicksand",
                      fontSize: _width/27,color: Colors.white),
                      textAlign: TextAlign.center,) ,),

                new Divider(height: _height/30,color: Colors.white,),

                new Row(
                  children: <Widget>[
                    rowCell(343, 'Meetups'),
                    rowCell(67, 'Followers'),
                    rowCell(275, 'Following'),
                  ],),

                new Divider(height: _height/30,color: Colors.white),

                ListTileTheme(
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  child: ListTile(
                    title: Text("Saved Places",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: "Quicksand")),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {},
                  ),
                ),
                ListTileTheme(
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  child: ListTile(
                    title: Text("Settings",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: "Quicksand")),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {},
                  ),
                ),
                ListTileTheme(
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  child: ListTile(
                    title: Text("Share Feedback",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: "Quicksand")),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {},
                  ),
                ),
                ListTileTheme(
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  child: ListTile(
                    title: Text("Sign Out",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: "Quicksand")),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {},
                  ),
                ),


              ],
            ),
          )
      )
    ],);
  }

  Widget rowCell(int count, String type) => new Expanded(child: new Column(children: <Widget>[
    new Text('$count',style: new TextStyle(color: Colors.white),),
    new Text(type,style: new TextStyle(color: Colors.white, fontWeight: FontWeight.normal))
  ],));
}