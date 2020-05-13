import 'package:flutter/rendering.dart';

import 'main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:geolocator/geolocator.dart';
import 'Globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:getflutter/getflutter.dart';




class MeetupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Share Meetup!"),
//        backgroundColor: Colors.black,
      ),
      body: MeetupPageWidget(),
    );
  }
}

class MeetupPageWidget extends StatefulWidget {
  @override
  MeetupPageState createState() => MeetupPageState();
}

class MeetupPageState extends State<MeetupPageWidget> {

  /////////////////////////////////////////////////////////////////////// [FUNCTIONS]

  Future<List<dynamic>> getMembers() async{}

  @override
  initState(){
    super.initState();
    globals.socketIO.joinSession("3046db10-9404-11ea-8bde-06b6ade4a06c");
    globals.socketIO.subscribe("user_joined_room", (data)=>{
      //whatever is inside here will run when server sends stuff
      print(data),
      globals.fakelistofmembers.add(data),
      print(globals.fakelistofmembers)
    });
  } //SOCKETS

  // TODO: Get details of location found from database
  globals.fakeData locationDetails = globals.fakeData(name: "Fisherman's Wharf",
      address: "39 San Francisco Bay Area",
      details: "Fisherman's Wharf @ Pier 39, where you can find the most delicious clam chowder! Visit the old-fashioned arcade with only mechanical games while you are there as well!",
      rating: 4.6,
      images: ["https://irepo.primecp.com/2015/07/230563/Fishermans-Wharf-Clam-Chowder_ExtraLarge1000_ID-1117267.jpg?v=1117267",
        "https://cdn.britannica.com/13/77413-050-95217C0B/Golden-Gate-Bridge-San-Francisco.jpg",
        "https://www.mercurynews.com/wp-content/uploads/2018/10/SJM-L-WEEKENDER-1018-01.jpg",]);

  /////////////////////////////////////////////////////////////////////// [WIDGETS]

  @override
  Widget build(BuildContext context) {
    bool _host = globals.isCreator;
    bool _locationFound = globals.locationFound;

    /////////////////////////////////////////////////////////////////////// [BUILDERS]

    Future<Null> _refresh() async {
      setState((){});
      return await Future.delayed(Duration(milliseconds: 1500));
    }

    Future<void> _shareText() async {
      try {
        Share.text('Link', "inseretlink", 'text/plain'); //TODO
      } catch (e) {
        print('error: $e');
      }
    }

    //Function to generate the search button for host
    Widget _generateButton() {
      return Container(
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15.0, top: 8, bottom: 8),
                child: ButtonTheme(
                  minWidth: 150,
                  height: 50,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                    color: Colors.deepOrange,
                    textColor: Colors.white,
                    onPressed: () async{
                    },
                    child: Text('Search Places', style: TextStyle(fontFamily: "Quicksand")),
                  ),
                ),
              ),
            )
          ],
        ) ,
      );
    }

    //Function to build details of tabulated final location
    Widget _buildLocationDetails(globals.fakeData details) {
      List images = details.images;

      return Container(
        width: MediaQuery.of(context).size.width,
        height: 380,
        child: Column(
          children: <Widget>[
            Container(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                 Expanded(
                   flex: 6,
                   child: Padding(
                       padding: const EdgeInsets.only(left:15.0, top: 20.0,),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: <Widget>[
                           Text(
                             details.name,
                             style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                             maxLines: 2,
                             overflow: TextOverflow.ellipsis,
                           ),
                           const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                           Text(
                             details.address,
                             style: const TextStyle(fontSize: 12.0),
                           ),
                         ],
                       ),
                   ),
                 ),
                 Padding(
                   padding: const EdgeInsets.only(right: 8.0),
                   child: Text(
                     details.rating.toString(),
                     style: TextStyle(
                         fontSize: 15.0
                     ),
                   ),
                 ),
                 Expanded(
                     flex: 2,
                     child: Container(
                       padding: const EdgeInsets.only(right: 10.0),
                       alignment: Alignment.centerRight,
                       child: RatingBarIndicator(
                         rating: details.rating,
                         itemBuilder: (context, index) => Icon(
                           Icons.star,
                           color: Colors.black,
                         ),
                         itemCount: 5,
                         itemSize: 15,
                       ),
                     )
                 )
               ],
              )
            ),
            Container(
              height: 300,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: GFCarousel(
                  items: images.map((img) {
                    return Container(
                      child: Image.network(img, fit: BoxFit.cover,),
                    );
                  }).toList(),
                  height:700,
                  viewportFraction: 1.0,
                  pagination: true,
                  pagerSize: 8.0,
                  passiveIndicator: Colors.grey,
                  activeIndicator: Colors.white,
                  onPageChanged: (index) {
                    setState(() {
                      index;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget listSection = FutureBuilder(
      future: getMembers(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
//        listofmembers = snapshot.data;

        if(globals.fakelistofmembers == null){
          return
            Expanded(
                child:
                Container(
                    child: Center(
                        child: Text("Loading...")
                    )
                )
            );
        }
        else {
          return Container(child: RefreshIndicator(child: ListView.builder(
            itemCount: globals.fakelistofmembers.length,
            itemBuilder: (BuildContext context, int index) {

              if (index == 0){ //means it is the meetup creator a.k.a first user on the list
                return ListTile(
                    leading: CircleAvatar(backgroundImage: AssetImage("images/mouseAvatar.jpg"),),
                    title: Text(globals.username), //TODO
                    subtitle: Text(globals.fakelistofmembers[index]["transport_mode"].toString()),
                    trailing: Text(globals.userLocationName)
                );
              }
              return ListTile(
                leading: CircleAvatar(backgroundImage: AssetImage("images/mouseAvatar.jpg"),),
                title: Text(globals.fakelistofmembers[index]["identifier"].toString()),
                subtitle: Text(globals.fakelistofmembers[index]["transport_mode"].toString()),
                trailing: Text(""),
              );
            },
          ) , onRefresh: _refresh,
          ));
        }
      },
    );

    /////////////////////////////////////////////////////////////////////// [SCAFFOLD]

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate([

                Visibility(
                  visible: _locationFound == false ? true : false,
                  child: Padding(
                    padding: const EdgeInsets.only(top:20, bottom:8, left:12, right:10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: TextField(
                              controller: TextEditingController(text:globals.tempData["link"]),
                              decoration: InputDecoration(labelText: "Tap here for link", border: OutlineInputBorder())
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.content_copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: globals.tempData["link"]));
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () async {
                              await _shareText();
                              Navigator.pop(context);
                            }
                        ),
                      ],
                    ),
                  ),
                ),//copy or share link

                Visibility(
                    visible: (_host == true && _locationFound == false) ? true : false,
                    child: Container(child: _generateButton(),)
                ),// generateButton

                Visibility(
                  visible: _locationFound,
                  child: _buildLocationDetails(locationDetails),
                ),

                Container(
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top:25, bottom:5, left:15, right:8),
                        child: Text("Mice Joining (16)", style: TextStyle(fontSize: 18),),
                      ),
                    ],
                  ),
                ), //no. of members
                Divider(height: 15,color: Colors.black12, thickness: 1.5, indent: 10, endIndent: 10,),

//          Text("Scroll to refresh" , style: TextStyle(fontWeight: FontWeight.w100),),
//          Container(child: listSection),
              ]),
            ),
          ],
        ),
      ),
    );
  }

}