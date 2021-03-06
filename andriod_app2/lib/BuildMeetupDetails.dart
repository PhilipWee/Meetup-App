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




class MeetupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MeetupPageWidget();
  }
}

class MeetupPageWidget extends StatefulWidget {
  @override
  MeetupPageState createState() => MeetupPageState();
}

class MeetupPageState extends State<MeetupPageWidget> {

  List<Color> colorsForLoad = [
    Colors.red,
    Colors.green,
    Colors.indigo,
    Colors.pinkAccent,
    Colors.blue
  ];

  Future _future;

  Future getMembers() async{
    http.Response response = await http.get('${globals.serverAddress}/session/${globals.sessionIdCarrier}');
    globals.sessionData = jsonDecode(response.body);
    print("Updating sessionData");
//    print("Getting Members ${globals.sessionData}");
  }

  void calculateSession (String inputSessID) async{
    String url = '${globals.serverAddress}/session/$inputSessID/calculate';
    http.Response response = await http.get(url);
    print(response.body);
//    Map calculate = jsonDecode(response.body);
  }

  @override
  initState(){
    print("SESSION DATA");
    print(globals.sessionData);
    if (globals.sessionData["host_uuid"] == globals.uuid){globals.isCreator = true;}
    else{globals.isCreator = false;}

    setState(() {});

    _future = getMembers();


    /// SOCKETS

    print("Connecting SOCKETS to Session with SESSION ID: ${globals.sessionIdCarrier}");

    globals.socketIO.joinSession(globals.sessionIdCarrier);

    globals.socketIO.subscribe("user_joined_room", (data)=>{
      setState((){globals.sessionData["users"].add(data);}), //updates globals.sessionData and refreshes the state of the page
      print('''
      ${data["username"]} has entered the session.
      There are now ${globals.sessionData["users"].length} users in this session.
      '''),});

    globals.socketIO.subscribe("calculation_result", (data)=>{
      print("Calculation Done!"),
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => ResultSwipePage()),)});

    globals.socketIO.subscribe("Error", (data)=>{
      print("SOCKET ERROR FOUND!"),
      print(data)
    });

    super.initState();

  } //SOCKETS

  /////////////////////////////////////////////////////////////////////// [WIDGETS]

  @override
  Widget build(BuildContext context) {

    Future<bool> _isBackPressed() async{
      return true;
    }

  /////////////////////////////////////////////////////////////////////// [BUILDERS]

    Future<void> _shareText() async {
      try {
        Share.text('Link', globals.sessionUrlCarrier, 'text/plain'); //TODO
      } catch (e) {
        print('error: $e');
      }
    }

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

    //to show waiting
    Widget _waitingText() {
      return SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15.0, top: 8, bottom: 8),
          child: Center(child: Text("Waiting for the rest ...", style: TextStyle(fontFamily: "Quicksand"))),
        ),
      );
    }

    //to generate the search button for host
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
                    child: Center(child: Text("Search Places", style: TextStyle(fontFamily: "Quicksand"))),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                    color: Colors.deepOrange,
                    textColor: Colors.white,
                    onPressed: () {
                      setState(() {globals.sessionData["session_status"] = "is_calculating";});
                      print("Calculating for session id: ${globals.sessionIdCarrier}");
                      calculateSession(globals.sessionIdCarrier);
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }

    //to build details of tabulated final location
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
                            visible:(globals.sessionData["session_status"] == "pending_members" && globals.sessionData["session_status"] != "is_calculating") ? true : false,
                            child: Padding(
                              padding: const EdgeInsets.only(top:20, bottom:8, left:12, right:10),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                        controller: TextEditingController(text:globals.sessionUrlCarrier),
                                        decoration: InputDecoration(labelText: "Tap here for link", border: OutlineInputBorder())
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.content_copy),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: globals.sessionUrlCarrier));
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
                              visible: (globals.sessionData["session_status"] == "pending_members"  && globals.isCreator == true) ? true : false,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(child: _generateButton(),),
                              )
                          ),// generateButton

                          Visibility(
                              visible: (globals.sessionData["session_status"] == "is_calculating") ? true : false,
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Center(child: ColorLoader(colors: colorsForLoad, duration: Duration(milliseconds: 1200))),
                              )
                          ),// build Calculating text

                          Visibility(
                              visible: (globals.sessionData["session_status"] == "pending_swipes") ? true : false,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(child: _waitingText()),
                              )
                          ),// build Waiting text

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