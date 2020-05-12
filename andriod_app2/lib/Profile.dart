//import 'dart:html';

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
    final String imgUrl = 'https://img-s-msn-com.akamaized.net/tenant/amp/entityid/BBYM6ZP.img?h=630&w=1200&m=6&q=60&o=t&l=f&f=jpg&x=2282&y=1331';

    return new Scaffold(
        drawer: new Drawer(child: new Container(),),
        backgroundColor: Colors.deepOrange,
        body: new Container(
          width: _width,
          height: _height,
          alignment: Alignment.topCenter,
          child: new CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white,),
                    onPressed: (){ },
                    iconSize: 25,
                  )
                ],
                backgroundColor: Colors.deepOrange,
                automaticallyImplyLeading: false,
                floating: true,
                expandedHeight: _height*0.5,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned.fill(
                        child: new Image.network(imgUrl, scale: 2, fit: BoxFit.cover, width: _width,)),
                      Positioned.fill(
                        child: new BackdropFilter(
                            filter: new ui.ImageFilter.blur(
                              sigmaX: 5.0,
                              sigmaY: 5.0,
                            ),
                            child: new Container(
                              color: Colors.deepOrange.withOpacity(0.7),
                            )
                        ),
                      ),
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(padding: const EdgeInsets.symmetric(vertical: 5.0)),
                            Align(
                              alignment: Alignment.center,
                              child: CircleAvatar(
                                radius:_width/4.5,
                                backgroundImage: NetworkImage(imgUrl),),
                            ),
                            Padding(padding: const EdgeInsets.symmetric(vertical:5.0)),
                            Text('Justin Trudeau',
                              style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.white,
                                fontFamily: "Quicksand",
                              ),),
                            Padding(
                              padding: const EdgeInsets.only(top:10.0, left: 10.0, right: 10.0),
                              child: new Text('Prime Minister of Canada. "Come Home" to Canada, the Maple Leaf Country <3',
                                maxLines: 2,
                                style: new TextStyle(
                                    fontFamily: "Quicksand",
                                    fontSize: 14,
                                    color: Colors.white),
                                textAlign: TextAlign.center,),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top:20.0, bottom: 0.0),
                              child: new Row(
                                children: <Widget>[
                                  rowCell(343, 'Meetups'),
                                  rowCell(67, 'Followers'),
                                  rowCell(275, 'Following'),
                                ],),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildListDelegate([
//                    Container(
//                      color: Colors.white,
//                      child: Padding(
//                        padding: const EdgeInsets.only(top:8.0, bottom: 8.0),
//                        child: new Row(
//                          children: <Widget>[
//                            rowCell(343, 'Meetups'),
//                            rowCell(67, 'Followers'),
//                            rowCell(275, 'Following'),
//                          ],),
//                      ),
//                    ),

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
              ),

            ],
          ),
        )
    );
  }

  Widget rowCell(int count, String type) => new Expanded(child: new Column(children: <Widget>[
    new Text('$count',style: new TextStyle(color: Colors.white),),
    new Text(type,style: new TextStyle(color: Colors.white, fontWeight: FontWeight.normal))
  ],));
}