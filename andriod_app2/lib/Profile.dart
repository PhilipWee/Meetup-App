import 'Globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ProfilePageState createState() => new _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _edit = false;
  String name = globals.username;
  String bio = "Add your bio";
  TextEditingController _nameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();

  void signOutGoogle() async{
//    await globals.googleSignIn.signOut();
    await globals.auth.signOut();
    print("User Sign Out");
    await Future.delayed(Duration(milliseconds: 1000));
  }

  void _changed(bool editing, String button) {
    setState(() {
    if (button == "edit") {
      _edit = editing;
    }
    if (button == "done"){
      if(_nameController.text.isNotEmpty) {
        name = _nameController.text;
        globals.username = name;
      }
      if (_bioController.text.isNotEmpty){
        bio = _bioController.text;
      } else if (_bioController.text.isEmpty) {
        bio = "Add your bio";
      }
      _edit = editing;
    }
    });
  }

  _launchURL() async {
    const url = 'https://forms.gle/ua19qDgYCpuLWGJw9';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = name;
  }

  @override
  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final String imgUrl = globals.profileurl;

    return new Scaffold(
        drawer: new Drawer(child: new Container(),),
        backgroundColor: Colors.deepOrange,
        body: new Container(
          width: _width,
          height: _height,
          alignment: Alignment.topCenter,
          child: new CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                  width: _width,
                  height: 385,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned.fill(
                          child: new Image.network(imgUrl, scale: 2, fit: BoxFit.cover, width: _width,)),

                      ClipRect(
                        child: new BackdropFilter(
                            filter: new ui.ImageFilter.blur(
                              sigmaX: 5.0,
                              sigmaY: 5.0,
                            ),
                            child: new Container(
                              width: _width,
                              height: 385,
                              color: Colors.deepOrange.withOpacity(0.7),
                            )
                        ),
                      ),

                      _edit == false ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(padding: const EdgeInsets.symmetric(vertical: 25)),
                          Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              radius:_width/4.5,
                              backgroundImage: NetworkImage(imgUrl),),
                          ),

                          Padding(padding: const EdgeInsets.symmetric(vertical:5.0)),
                          Text(name,
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: Colors.white,
                              fontFamily: "Quicksand",
                            ),),

                          Padding(
                            padding: const EdgeInsets.only(top:10.0, left: 15.0, right: 15.0),
                            child: new Text(bio,
                              maxLines: 2,
                              style: new TextStyle(
                                  fontFamily: "Quicksand",
                                  fontSize: 14,
                                  color: Colors.white),
                              textAlign: TextAlign.center,),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top:25.0, bottom: 15),
                            child: new Row(
                              children: <Widget>[
                                rowCell(0, 'Meetups'),
                                rowCell(0, 'Followers'),
                                rowCell(0, 'Following'),
                              ],),
                          ),
                        ],
                      )
                      : Column(
                        children: <Widget>[
                          Padding(padding: const EdgeInsets.symmetric(vertical: 25)),
                          Align(
                            alignment: Alignment.center,
                            child: Column(
                              children: <Widget>[
                                CircleAvatar(
                                  radius:_width/6,
                                  backgroundImage: NetworkImage(imgUrl),
                                ),

                                FlatButton(
                                    onPressed: () {},
                                    child: Text("Edit",
                                      style: TextStyle(
                                        color: Colors.white
                                      ),
                                    ),
                                )
                              ],
                            ),
                          ),
//                          Padding(padding: const EdgeInsets.symmetric(vertical:3.0)),

                          Padding(
                            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                            child: TextField(
                              controller: _nameController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Name",
                                labelStyle: TextStyle(color: Colors.white, fontSize: 14.0),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                            child: TextField(
                              controller: _bioController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Bio",
                                labelStyle: TextStyle(color: Colors.white, fontSize: 14.0),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                              ),
                            ),
                          ),

                        ],
                      ),

                      Positioned(
                        top: 25,
                        right: 10,
                        child: _edit == false
                            ? IconButton(
                                icon: Icon(Icons.edit, color: Colors.white,),
                                onPressed: (){
                                  _changed(true, "edit");
                                },
                                iconSize: 25,
                              )
                            : IconButton(
                                icon: Icon(Icons.done, color: Colors.white,),
                                onPressed: () {
                                  _changed(false, "done");
                                },
                                iconSize: 25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),



              SliverList(
                delegate: SliverChildListDelegate([

                    ListTileTheme(
                      iconColor: Colors.white,
                      textColor: Colors.white,
                      child: ListTile(
                        title: Text("Saved Places",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: "Quicksand")),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          Scaffold.of(context).showSnackBar(SnackBar(content: Text("COMING SOON! (ᵔᴥᵔ)", textAlign: TextAlign.center,),));
                        },
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
                        onTap: () {
                          Scaffold.of(context).showSnackBar(SnackBar(content: Text("COMING SOON! (ᵔᴥᵔ)", textAlign: TextAlign.center,),));
                        },
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
                        onTap: _launchURL,
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
                        onTap: () async{
                          signOutGoogle();
                          Phoenix.rebirth(context);
                          },
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