import 'package:andriod_app2/BottomTab.dart';
import 'package:andriod_app2/ResultsSwipePage.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'Globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:getflutter/getflutter.dart';
import 'color_loader.dart';
import 'socketiohelper.dart';


class ConfirmedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConfirmedPageWidget();
  }
}

class ConfirmedPageWidget extends StatefulWidget {
  @override
  ConfirmedPageState createState() => ConfirmedPageState();
}

class ConfirmedPageState extends State<ConfirmedPageWidget> {

  List<globals.FakeData> swipeData = [];

  List<Color> colorsForLoad = [
    Colors.red,
    Colors.green,
    Colors.indigo,
    Colors.pinkAccent,
    Colors.blue
  ];

  Future _future;

  Future getSessionResults (String inputSessID) async{

    swipeData = [];

    http.Response response1 = await http.get('${globals.serverAddress}/session/${globals.sessionIdCarrier}');
    globals.sessionData = jsonDecode(response1.body);
    print("Updating sessionData");

    String url = '${globals.serverAddress}/session/$inputSessID/results';
    print("Requesting Results for $inputSessID");
    http.Response response = await http.get(url);
    Map results = jsonDecode(response.body);
    print(results);
    List possibleLocations = results["possible_locations"];

    for( var i=0 ; i<possibleLocations.length ; i++ ){

      Map oneLocation = results[possibleLocations[i]];
      globals.FakeData placeInfo =
      globals.FakeData(
        name: possibleLocations[i],
        address: oneLocation["address"], //string
        details: oneLocation["writeup"], //string
        rating: double.parse(oneLocation["rating"]), //integer
        images: oneLocation["pictures"], //list
      );
      swipeData.add(placeInfo);
    } //for loop ends here!

    globals.confirmedDetails = swipeData[globals.sessionData["confirmed_place_index"]];
    globals.locationDetails = globals.confirmedDetails;

    print("SWIPEDATA");
    print(swipeData);
  }

  @override
  initState(){
    print("Session Data");
    print(globals.sessionData);
    setState(() {});
    _future = getSessionResults(globals.sessionIdCarrier);
    super.initState();

  } //SOCKETS

  /////////////////////////////////////////////////////////////////////// [WIDGETS]

  @override
  Widget build(BuildContext context) {

    Future<bool> _isBackPressed() async{
      return true;
    }

    /////////////////////////////////////////////////////////////////////// [BUILDERS]

    //to create sub-headers within the page
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

    //to build details of tabulated final location
    FutureBuilder _buildLocationDetails(globals.FakeData details) {

      return FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          else if (snapshot.connectionState ==  ConnectionState.done){
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                                  Text(
                                    details.address,
                                    style: const TextStyle(fontSize: 12.0),
                                    overflow: TextOverflow.ellipsis,
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
                            // ignore: unnecessary_statements
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
          else {return Center(child: Text("SNAPSHOT ERROR: ${snapshot.error}"),);}
        },
      );
    }

    // to build memberTile
    Widget _memberTile(int index, Widget imageAsset ){

      String tMode = globals.sessionData["users"][index]["transport_mode"].toString();

      if (tMode == "public"){tMode = "Public Transport";}
      if (tMode == "driving"){tMode = "Driving";}
      if (tMode == "walking"){tMode = "Walking";}

      return ListTile(
        leading: SizedBox(
          width: 40,
          height: 40,
          child: imageAsset,
        ),
        title: Text(
            globals.sessionData["users"][index]["username"].toString(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(fontFamily: "Quicksand")
        ),
        subtitle: Text(tMode, style: TextStyle(fontFamily: "Quicksand")),
        trailing: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          child: Text(
              globals.sessionData["users"][index]["user_place"].toString().replaceAll(new RegExp(r', Singapore'), ''),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(fontFamily: "Quicksand")
          ),
        ),
      );
    }

    //to build the list of members in current session
    FutureBuilder membersList(BuildContext context, int index) {

      return FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot snapshot){
          List<Widget> members = [];
          if (globals.sessionData["users"][index]["uuid"] == globals.sessionData["host_uuid"] ){
            members.add(_memberTile(index, Image.asset("images/host-purple.png")));
          }
          else {
            members.add(_memberTile(index, Image.asset("images/member-yellow.png")));
          }
          return Column(
            children: members,
          );
        },
      );
    }

    /////////////////////////////////////////////////////////////////////// [SCAFFOLD]

    return WillPopScope(
      onWillPop: _isBackPressed,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("${globals.sessionData["meetup_name"]}"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              globals.socketIO.sendMessage('leave', {'room':"${globals.sessionIdCarrier}"});
              print("Exited Session: ${globals.sessionIdCarrier}, sessionData reset.");
              print("Exited Session: ${globals.sessionIdCarrier}, sessionData reset.");
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>MyHomePage()),);
            },
          ),
          backgroundColor: Colors.deepOrange,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                    delegate: SliverChildListDelegate([
                      Column(
                        children: <Widget>[
                          Visibility(
                            visible: (globals.sessionData["session_status"] == "location_confirmed") ? true : false,
                            child: _buildLocationDetails(globals.locationDetails),
                          ), //build confirmed location details
                        ],
                      ),
                    ])
                ),

                makeHeader("Mice Joining (${globals.sessionData["users"].length})"), //no. of members

//              SliverToBoxAdapter(
//                child: Center(child: Padding(
//                  padding: const EdgeInsets.all(2),
//                  child: Text("Scroll to refresh" , style: TextStyle(fontWeight: FontWeight.w100),),
//                )),
//              ), //scroll to refresh

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return membersList(context, index);
                    },
                    childCount: globals.sessionData["users"].length,
                  ),
                ),// membersList
              ]
          ), // Refresh indicator used to be wrapped here
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