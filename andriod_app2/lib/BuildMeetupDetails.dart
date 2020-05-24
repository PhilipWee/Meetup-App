import 'package:andriod_app2/ResultsSwipePage.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
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
        title: Text(globals.sessionData["meetup_name"]),
        backgroundColor: Colors.deepOrange,
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

  void calculateSession (String inputSessID) async{
    String url = '${globals.serverAddress}/session/$inputSessID/calculate';
    http.Response response = await http.get(url);
    print(response.body);
    Map calculate = jsonDecode(response.body);
  }


  @override
  initState(){
    super.initState();

    if (globals.sessionData["host_uuid"] == globals.uuid){globals.isCreator = true;}
    else{globals.isCreator = false;}

    ///SOCKETS
    globals.socketIO.joinSession(globals.sessionData["sessionid"]);

    globals.socketIO.subscribe("user_joined_room", (data)=>{
      print("INCOMING SOCKETS DATA: $data"),
      globals.sessionData["users"].add(data),
      print("UPDATED SESSION'S USER DATA: ${globals.sessionData["users"]}"),
    });

    globals.socketIO.subscribe("calculation_result", (data)=>{
      print("Calculation Done!"),
      Navigator.push(context,MaterialPageRoute(builder: (context) => ResultSwipePage()),)
    });

    globals.socketIO.subscribe("location_found", (data)=>{
      print("Location Found!")

    });

//    globals.socketIO.sendMessage('leave', {'room':{globals.sessionData["sessionid"]}});

  } //SOCKETS

  // TODO: Get details of final location found from database
  globals.FakeData locationDetails = globals.FakeData(name: "Fisherman's Wharf",
      address: "39 San Francisco Bay Area",
      details: "Fisherman's Wharf @ Pier 39, where you can find the most delicious clam chowder! Visit the old-fashioned arcade with only mechanical games while you are there as well!",
      rating: 4.6,
      images: ["https://irepo.primecp.com/2015/07/230563/Fishermans-Wharf-Clam-Chowder_ExtraLarge1000_ID-1117267.jpg?v=1117267",
        "https://cdn.britannica.com/13/77413-050-95217C0B/Golden-Gate-Bridge-San-Francisco.jpg",
        "https://www.mercurynews.com/wp-content/uploads/2018/10/SJM-L-WEEKENDER-1018-01.jpg",]);

  /////////////////////////////////////////////////////////////////////// [WIDGETS]

  @override
  Widget build(BuildContext context) {

  /////////////////////////////////////////////////////////////////////// [BUILDERS]

    Future<Null> _refresh() async {
      setState((){});
      return await Future.delayed(Duration(milliseconds: 1000));
    }
    Future<void> _shareText() async {
      try {
        Share.text('Link', globals.sessionData["url"], 'text/plain'); //TODO
      } catch (e) {
        print('error: $e');
      }
    }

    //Function to create sub-headers within the page
    SliverPersistentHeader makeHeader(String headerText) {
      return SliverPersistentHeader(
        pinned: true,
        delegate: _SliverAppBarDelegate(
          minHeight: 75.0,
          maxHeight: 75.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top:25, bottom:5, left:15, right:8),
                child: Text(headerText, style: TextStyle(fontSize: 18, fontFamily: "Quicksand")),
                color: Colors.white60,
              ),
              Container(
                color: Colors.white60,
                child: Divider(height: 15,color: Colors.black12, thickness: 1.5, indent: 10, endIndent: 10,)
              ),
            ],
          ),
        ),
      );
    }

    //Function to generate the search button for the host
    Widget _calculatingText() {
      return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15.0, top: 8, bottom: 8),
        child: Center(child: Text("Calculating")),
      );
    }

    //Function to generate the search button for host
    Widget _generateButton() {
      if (globals.isCreator ==  true) {
        return SizedBox(
            width: 22,
            height: 22,
            child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.deepOrange,
                  strokeWidth: 3,
                )
            )
        );
      }
      else {
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
                    child: Center(child: Text("Search Places", style: TextStyle(fontFamily: "Quicksand"))),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                    color: Colors.deepOrange,
                    textColor: Colors.white,
                    onPressed: () {
                      print("Calculating for session id: ${globals.sessionData["sessionid"]}");
                      calculateSession(globals.sessionData["sessionid"]);
                    },
                  ),
                ),
              ),
            )
          ],
        ) ,
      );
      }

    }

    //Function to build details of tabulated final location
    Widget _buildLocationDetails(globals.FakeData details) {
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

    //Function to build the list of members in current session
    FutureBuilder membersList(BuildContext context, int index) {
      return FutureBuilder(
        future: getMembers(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(globals.sessionData["users"].isEmpty){
            return
              Container(
                  child: Center(
                      child: Text("Loading...")
                  )
              );
          }
          else {
            List<Widget> members = [];
            members.add(
                ListTile(
                  leading: CircleAvatar(backgroundImage: AssetImage("images/mouseAvatar.jpg"),),
                  title: Text(
                    globals.sessionData["users"][index]["username"].toString(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Text(globals.sessionData["users"][index]["transport_mode"].toString()),
                  trailing: Container(
                    width: MediaQuery.of(context).size.width*0.4,
                    child: Text(
                      globals.sessionData["users"][index]["user_place"].toString().replaceAll(new RegExp(r', Singapore'), ''),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
            ));
            return Column(
              children: members,
            );
          }
        },
      );
    }

    /////////////////////////////////////////////////////////////////////// [SCAFFOLD]

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate([
                  Column(
                    children: <Widget>[
                      Visibility(
                        visible:
                        (globals.sessionData["session_status"] == "pending_members") ? true : false,
                        child: Padding(
                          padding: const EdgeInsets.only(top:20, bottom:8, left:12, right:10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: TextField(
                                    controller: TextEditingController(text:globals.sessionData["url"]),
                                    decoration: InputDecoration(labelText: "Tap here for link", border: OutlineInputBorder())
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.content_copy),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: globals.sessionData["url"]));
                                },
                              ),
                              IconButton(
                                  icon: Icon(Icons.share),
                                  onPressed: () async {
                                    await _shareText();
                                  }
                              ),
                            ],
                          ),
                        ),
                      ),//share link

                      Visibility(
                        visible: (globals.isCreator == true && globals.sessionData["session_status"] == "pending_members") ? true : false,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: _generateButton(),),
                        )
                      ),// generateButton

                      Visibility(
                        visible: (false) ? true : false, //TODO DOOBEEDOOBEDOOOO
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: Text("Waiting for the rest")),
                        )
                      ),// build Waiting text

                      Visibility(
                        visible: (globals.sessionData["session_status"] == "location_confirmed") ? true : false,
                        child: _buildLocationDetails(locationDetails),
                      ), //build confirmed location details
                    ],
                  ),
                ])
              ),

              makeHeader("Mice Joining (${globals.sessionData["users"].length})"), //no. of members

              SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text("Scroll to refresh" , style: TextStyle(fontWeight: FontWeight.w100),),
                )),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return membersList(context, index);
                    },
                  childCount: globals.sessionData["users"].length,
              ),
            ),

            ]
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;
  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent)
  {
    return new SizedBox.expand(child: child);
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}