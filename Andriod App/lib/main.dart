import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity/connectivity.dart';
import 'color_loader.dart';

String globalurl(){
//   String serverAddress = "http://192.168.194.178:5000";
//   String serverAddress = "http://169.254.158.154:5000";
  String serverAddress = "http://ec2-3-16-181-51.us-east-2.compute.amazonaws.com:5000";
  return serverAddress;
}

void main() => runApp(MyApp());

class PrefData {
  String username;
  String activityType;
  double lat;
  double long;
  String link;
  String transportMode;
  int speed;
  int quality;
  String sessionid;
  PrefData({this.username,this.transportMode, this.quality, this.speed, this.link, this.lat, this.long, this.activityType,this.sessionid});
}


class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xffff6347),
        fontFamily: 'Quicksand'
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => CheckNetworkPage(),
      },
    );
  }
}

class CheckNetworkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text(""),
        // ),
        body: StreamBuilder(
            stream: Connectivity().onConnectivityChanged,
            builder: (BuildContext ctxt,
                AsyncSnapshot<ConnectivityResult> snapShot) {
              if (!snapShot.hasData) return CircularProgressIndicator();
              var result = snapShot.data;
              switch (result) {
                case ConnectivityResult.none:
                  print("no net");
                  return Center(child: Text("No Internet Connection!"));
                case ConnectivityResult.mobile:
                case ConnectivityResult.wifi:
                  print("Connected!");
                  return HomeScreen();
                default:
                  return Center(child: Text("No Internet Connection!"));
              }
            })
      );
  }
}


  refreshServer() async {
    String address = globalurl();
    try{
      http.Response response = await http.get('$address/refresh');
      int statusCode = response.statusCode;
      String body = response.body;
      print("SERVER REFRESHED WITH STATUSCODE: $statusCode");
      print("SERVER SAYS: $body");
      }
    catch(e){print(e);}
  }

class HomeScreen extends StatelessWidget {
  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Home', style: TextStyle(fontWeight: FontWeight.bold),),
//        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.list),
          onPressed: (){
            _scaffoldKey.currentState.openDrawer();
          },
        ),
      ),
      body: HomeUsernameWidget(),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Meetup Mouse',style: TextStyle(
                color: Colors.white,
                fontSize: 23
                ),
              ),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.black,
              ),
            ),
            ListTile(
              title: Text('Account'),
              onTap: () {
                //TODO
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                // TODO
              },
            ),
            ListTile(
              title: Text('Contact Us'),
              onTap: () {
                //TODO
              },
            ),
            ListTile(
              title: Text('Exit'),
              onTap: () {
                //TODO
              },
            ),
          ],
        ),
      ),
      );
  }

}

class HomeUsernameWidget extends StatefulWidget {
  @override
  HomeUsernameState createState() => HomeUsernameState();
}

class HomeUsernameState extends State<HomeUsernameWidget> {
  static String name;
  final data = PrefData(username:"",activityType: "",lat: 0,long: 0,link:"",transportMode: "",speed: 0, quality: 0,sessionid: '');
  final textController  = TextEditingController();

  saveLocation() async{
    // Get user's current location
    var location = Location(); 
    LocationData currentLocation = await location.getLocation();
    data.lat = currentLocation.latitude;
    data.long = currentLocation.longitude;
    print(data.lat);
    print(data.long);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Logo and start message
    Widget welcomeSection = Container(
      margin: const EdgeInsets.only(left: 50.0, top: 20.0, right: 50.0),
      alignment: Alignment.center,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left:20.0, right: 20.0, top:20.0, bottom: 20.0),
            child: Image.asset(
              'images/Mouse_copy.png',
              scale: 3,
            ),
          ),
          Text(
            "Start Your Meetup!",
            style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
                fontFamily: 'Pacifico'
            ),
          )
        ],
      ),
    );

    //Button Section
    Widget buttonSection =  Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton(
              onPressed: () {
//                refreshServer();
                saveLocation();
                if (textController.text != "") {
                  name = textController.text;
                  data.username = name;
                  Navigator.push(context,MaterialPageRoute(builder: (context) => MeetingType(data : data)),);
                } else {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please enter your username!"),
                        duration: Duration(seconds: 2),
                      ));
                }},
              child: _buildButtonColumn(Colors.black, Icons.arrow_forward, 'Get Started!'),
              color: Colors.amber,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            )
          ],
        ) ,
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  child: Text( "OR", style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 20.0
                  ),
                  )
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatButton(
                    onPressed: () {
                      if (textController.text != "") {
                        Navigator.push(context,MaterialPageRoute(builder: (context) => ShareLinkPage(data : data)),);
                      } else {
                        Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text("There is no ongoing session!"),
                              duration: Duration(seconds: 2),
                            ));
                      }
                    },
                    child: _buildButtonColumn(Colors.black, Icons.autorenew, 'Go to My Meetup!'),
                    color: Colors.lightBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  )
                ],
              ),
              Container(
                child: Text("       "),
              ),
            ],
          )
      ],
    );


    return Center(
        child: ListView(
          children:[
            welcomeSection,
            Padding(
              padding: const EdgeInsets.only(left: 50.0, top: 20.0, right: 50.0, bottom: 50.0),
              child: TextFormField(
                controller: textController,
                decoration: InputDecoration(
                    labelText: "Username"
                ),
              ),
            ),
            buttonSection,
          ],
        )
    );
  }

  //Helper method to create button icons with text
  Row _buildButtonColumn(Color color, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        Icon(icon, color: color),
      ],
    );
  }

}

class MeetingType extends StatelessWidget {

  final PrefData data;
  MeetingType({this.data});

  final List<String> custLabels = [
    "Recreation",
    "Food",
    "Meeting",
    ];
  final List<String> custImgs = [
    "images/food.jpg",
    "images/outing.jpg",
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

class CustomizationPage extends StatelessWidget {
  final PrefData data;
  CustomizationPage({this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Your Preferences"),
//        backgroundColor: Colors.black,
      ),
      body: CustomizationPageWidget(data: data,),
    );
  }

}

class CustomizationPageWidget extends StatefulWidget {
  final PrefData data;
  CustomizationPageWidget({this.data});
  @override
  CustomizationPageState createState() => CustomizationPageState(data: data);
}

class CustomizationPageState extends State<CustomizationPageWidget> {
  final PrefData data;
  CustomizationPageState({this.data});

  sessionIdPost() async {

    //extract data from PrefData to add to json package
    double lat = data.lat;
    double long = data.long;
    int quality = data.quality;
    int speed = data.speed;
    String transportmode = data.transportMode;

    //send json package to server as POST
    Map<String, String> headers = {"Content-type": "application/json"};
    String address = globalurl();

    String url = '$address/session/create';

    String jsonpackage = '{"lat":$lat,   "long":$long,   "quality":$quality,   "speed":$speed,    "transport_mode":"$transportmode"}';
    print("jsonpackage $jsonpackage");
    try{

      http.Response response = await http.post(url, headers:headers, body:jsonpackage);
      int statusCode = response.statusCode;

      if (statusCode != 200){
        Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text("Oops! Server Error 404!"),
              duration: Duration(seconds: 2),
            ));
      }

      else{

        String body = response.body; //store returned string-map "{sessionid: XXX}"" into String body
        print("POST REQUEST SUCCESSFUL/FAILED WITH STATUSCODE: $statusCode");
        print("SERVER SAYS: $body");

        //decode the string-map
        Map<String, dynamic> sessionidjsonversion = jsonDecode(body);
        var sessionid = sessionidjsonversion['session_id'];
        print("Transport Mode:$transportmode");
        print("Quality:$quality");
        print("Speed:$speed");
        data.link = "$address/session/$sessionid/get_details";

        data.sessionid = sessionid;
        String tempvar = data.link;
        print('Link Created--> $tempvar');
        return jsonpackage;

      }
    }

    catch(e){print("Session Create Failed with Error: $e");}
    }

//  String value1 = "Select...";
  String value2 = "Select...";
  String value3 = "Select...";
  String value4 = "Select...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
          children: [
//            Row(
//              mainAxisAlignment: MainAxisAlignment.spaceAround,
//              mainAxisSize: MainAxisSize.max,
//              children: <Widget>[
//                Container(
//                  width: 180,
//                  padding: const EdgeInsets.only(left: 10.0, top: 8.0, right: 30.0, bottom: 8.0),
//                  child: Row(
//                    children: <Widget>[
//                      Icon(Icons.fastfood, color: Colors.black),
//                      Padding(
//                        padding: const EdgeInsets.all(8.0),
//                        child: Text("Activities", style: TextStyle(
//                            color: Colors.black,
//                            fontWeight: FontWeight.bold,
//                            fontSize: 20.0
//                        ),),
//                      ),
//                    ],
//                  ),
//                ),
//                Expanded(
//                  child: Container(
//                    child: DropdownButtonHideUnderline(
//                      child: DropdownButton<String>(
//                        value: value1,
//                        onChanged: (String newValue) {
//                          setState(() {
//                            value1 = newValue;
//                            data.activityType = newValue; //ADD TO DATABASE
//                          });
//                        },
//                        items: <String>["Select...", "Lunch/Dinner", "Recreation", "Study"].map<DropdownMenuItem<String>>((String value) {
//                          return DropdownMenuItem<String>(
//                            value: value,
//                            child: Text(value),
//                          );
//                        }).toList(),
//                      ),
//                    ),
//                  ) ,
//                )
//              ],
//            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.only(left: 10.0, top: 8.0, right: 30.0, bottom: 8.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.directions_car, color: Colors.black),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Transport", style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0
                          ),),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: value2,
                        onChanged: (String newValue) {
                          setState(() {
                            value2 = newValue;
                            data.transportMode = newValue; //ADD TO DATABASE
                          });
                        },
                        items: <String>["Select...", "Driving", "Public Transit", "Walk"].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.only(left: 10.0, top: 8.0, right: 30.0, bottom: 8.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.timer, color: Colors.black),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Speed", style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0
                          ),),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: value3,
                        onChanged: (String newValue) {
                          setState(() {
                            value3 = newValue;
                            if (value3=="Fast"){data.speed = 3;}
                            else if (value3=="Regular"){data.speed=2;}
                            else if (value3=="No Preference"){data.speed=1;}  //ADD TO DATABASE
                            else {data.speed=0;}
                          });
                        },
                        items: <String>["Select...", "Fast", "Regular", "No Preference"].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.only(left: 10.0, top: 8.0, right: 30.0, bottom: 8.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.star, color: Colors.black),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Ratings", style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0
                          ),),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: value4,
                        onChanged: (String newValue) {
                          setState(() {
                            value4 = newValue;
                            if (value4=="Best"){data.quality=3;}
                            else if (value4=="Regular"){data.quality=2;}
                            else if (value4=="No Preference"){data.quality=1;}  //ADD TO DATABASE
                            else{data.quality=0;}
                          });
                        },
                        items: <String>["Select...", "Best", "Regular", "No Preference"]
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      bottomNavigationBar: BottomAppBar(
        child: FlatButton(
            child: Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              sessionIdPost();                                                   //POST DATABASE TO SERVER
              if (value2 != "Select..." && value3 != "Select..." && value4 != "Select...") {
                Navigator.push(context,MaterialPageRoute(builder: (context) => ShareLinkPage(data:data)),);
              } else {
                Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please select preferences!"),
                      duration: Duration(seconds: 2),
                    ));
              }
            }
        ),
      ),
    );
  }
}

class ShareLinkPage extends StatelessWidget {
  final PrefData data;
  ShareLinkPage({this.data,});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Share the Link!"),
//        backgroundColor: Colors.black,
      ),
      body: ShareLinkWidget(data: data),
    );
  }
}

class ShareLinkWidget extends StatefulWidget {
  final PrefData data;
  ShareLinkWidget({this.data});
  @override
  ShareLinkState createState() => ShareLinkState(data: data);
}

class ShareLinkState extends State<ShareLinkWidget> {
  final PrefData data;
  ShareLinkState({this.data});

  Future<List<dynamic>> getMembers() async {

    String sessID = data.sessionid;
    String address = globalurl();

    try{

      http.Response response = await http.get('$address/session/$sessID');
      // http.Response response = await http.get('$address/session/$sessID'); //use this when session id can be generated
      int statusCode = response.statusCode;
      String body = response.body;
      print(response.statusCode);
      
      if (statusCode != 200){
        Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text("Oops! Server Error 404"),
              duration: Duration(seconds: 2),
            ));
      }

      else{
        
        print("GET REQUEST SUCCESSFUL/FAILED WITH STATUSCODE: $statusCode");
        print("SERVER SAYS: $body");
        Map<String, dynamic> memberDatajsonVersion = jsonDecode(body); //parse the data from server into a map<string,dynamic>
        List membersData = memberDatajsonVersion["users"];
        //extract the list of user detail maps into a list
        List<Placemark> myplace = await Geolocator().placemarkFromCoordinates(data.lat,data.long); //get the name of the place where user is at right now
        Map<String,String> placeNameMap = {"username": myplace[0].thoroughfare.toString() }; //add the place name as a value to the key "username" to a new map
        for (Map<String, dynamic> mapcontent in membersData) { // for every user detail map packet in the main list
          print(mapcontent);
          if (mapcontent["lat"] != null && mapcontent["long"] != null && mapcontent["identifier"] != null){

//            List<Placemark> place = await Geolocator().placemarkFromCoordinates(double.parse(mapcontent["lat"]), double.parse(mapcontent["long"])); //use the lat long values to find the placename

            List<Placemark> place = await Geolocator().placemarkFromCoordinates(mapcontent["lat"], mapcontent["long"]); //use the lat long values to find the placename
            placeNameMap[mapcontent["identifier"].toString()] = place[0].thoroughfare.toString(); // add the placename to the map with the key being the name of the user
          }
          else{placeNameMap[mapcontent["identifier"].toString()] = "ERRROR";}
        }
        membersData.add(placeNameMap);
        print("membersData-> $membersData");
        return membersData;
      }
    }

    catch(e){print("Get-session-details Failed with error: $e");}

  }

  Future<List<Map<String, dynamic>>> getMembersFAKE() async {

    await Future.delayed(Duration(milliseconds: 1000));

    List<Map<String, dynamic>> membersData = [
      {
        "lat": 37.4219983, 
        "long": -122.084, 
        "metrics": {
          "quality": 3, 
          "speed": 3
        }, 
        "transport_mode": "Driving", 
        "username": "username"
      }, 
      {
        "identifier": "Philip", 
        "lat": 1.2848664, 
        "long": 103.8244263, 
        "metrics": {
          "quality": 5, 
          "speed": 5
        }, 
        "transport_mode": "Driving"
      },
      {
        "identifier": "Julia", 
        "lat": 1.2848664, 
        "long": 103.8244263, 
        "metrics": {
          "quality": 5, 
          "speed": 5
        }, 
        "transport_mode": "Public Transport"
      },
      {
        "identifier": "Joel", 
        "lat": 1.2848664, 
        "long": 103.8244263, 
        "metrics": {
          "quality": 5, 
          "speed": 5
        }, 
        "transport_mode": "Public Transport"
      },
      {
        "identifier": "Veda", 
        "lat": 1.2848664, 
        "long": 103.8244263, 
        "metrics": {
          "quality": 5, 
          "speed": 5
        }, 
        "transport_mode": "Walking"
      },
      {
        "username" : "Jalan Bukit Merah",
        "Philip" : "Serangoon Gardens",
        "Julia" : "Potong Pasir",
        "Joel" : "Hougang",
        "Veda" : "Upper Changi",
      },
    ];
    return membersData;
  }

  @override
  Widget build(BuildContext context) {
    //Share and make meet up buttons section
    Widget listSection = Container(
      child: 
      FutureBuilder(
        future: getMembers(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          print(snapshot);
          if(snapshot.data == null){
            return 
            Expanded(
              child:
              Container(
                child: Center(
                  child: Text("Loading...")
                )
              )
            );
          } else {
            return 
            Expanded(
              child:
              ListView.builder(
                itemCount: snapshot.data.length-1,
                itemBuilder: (BuildContext context, int index) {
                  Map<String,dynamic> myMap = snapshot.data[snapshot.data.length-1];
                  if (index == 0){
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: AssetImage("images/mouseAvatar.jpg"),),
                      title: Text(data.username),
                      subtitle: Text(snapshot.data[index]["transport_mode"].toString()),
                      trailing: Text(myMap["username"].toString())
                    );
                  }
                  return ListTile(
                    leading: CircleAvatar(backgroundImage: AssetImage("images/mouseAvatar.jpg"),),
                    title: Text(snapshot.data[index]["identifier"].toString()),
                    subtitle: Text(snapshot.data[index]["transport_mode"].toString()),
                    trailing: Text(myMap[snapshot.data[index]["identifier"]].toString()),
                  );
                },
              )
            );
          }
        },
      ),
    );

    Widget buttonSection = Container(
      height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 5.0),
              child: ButtonTheme(
                height: 35,
                child: FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                  color: Colors.amber,
                  textColor: Colors.black,
                  onPressed: () async => await _shareText(),
                  child: Text("Share"),
                ),
              ),
            )
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 15.0),
              child: ButtonTheme(
                minWidth: 180,
                height: 35,
                child: FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                  color: Colors.amber,
                  textColor: Colors.black,
                  onPressed: () {
                    Navigator.push(context,MaterialPageRoute(builder: (context) => MapSample(data:data)),);
                  },
                  child: Text("Create Meetup!"),
                ),
              ),
            ),
          )
        ],
      ) ,
    );

    return Scaffold(
      body: Column(
        children:[
          Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 15.0, right: 15.0, bottom: 5.0),
            child: TextField(
              controller: TextEditingController(text:data.link),
              decoration: InputDecoration(
                  labelText: "Tap here for link",
                  border: OutlineInputBorder()
              ),
            ),
          ),
          buttonSection,
          listSection
        ],
      ),
    );
  }

  Future<void> _shareText() async {
    try {
      Share.text('Link', data.link, 'text/plain');
    } catch (e) {
      print('error: $e');
    }
  }

}


class MapSample extends StatefulWidget {
  final PrefData data;
  MapSample({this.data});
  @override
  State<MapSample> createState() => MapSampleState(data:data);
}

class MapSampleState extends State<MapSample> {
  final PrefData data;
  MapSampleState({this.data});
  Completer<GoogleMapController> _controller = Completer();
  List<Polyline> polylines = [];
  List<Marker> markers = [];


  //Create the get request function
  Future<Map<String, dynamic>> _getCalculate() async {
    String id = data.sessionid;
    String address = globalurl();
    // final result = await http.get("$address/session/$id/calculate");
    final result = await http.get("$address/session/$id/calculate");
    if (result.statusCode != 200 || result.statusCode != 302) {
      Map<String, dynamic> results = jsonDecode(result.body);
      print(results);
      print(results['possible_locations']);
      return results;
    } else {
      // throw ("Error getting results with statusCode " + result.statusCode.toString());
      Map<String, dynamic> results = jsonDecode(result.body);
      print(results);
      print(results['possible_locations']);
      return results;
    }
  }

  static final CameraPosition _kSingapore = CameraPosition(
    target: LatLng(1.3385253,103.8),
    zoom: 10,
  );

  //Build the map
  GoogleMap displayMap() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _kSingapore,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      polylines: Set<Polyline>.of(polylines),
      markers: Set<Marker>.of(markers),
    );
  }

  //Make a list for the different colors
  List<Color> colors = <Color>[
    Colors.blue,
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.pink
  ];

  //Create a polyline from array
  Polyline _makeLine(List<dynamic> latitude, List<dynamic> longtitude, int polylineid) {
    List<LatLng> latLngList = [];
    for (var i = 0; i < latitude.length; i++) {
      // print(latitude[i]);
      // print(longtitude[i]);
      latLngList.add(LatLng(latitude[i],longtitude[i]));
    }
    return Polyline(
      polylineId: PolylineId(polylineid.toString()),
      color: colors[polylineid%5],
      width: 5,
      points: latLngList
    );
  }

  //Make a function that makes a widget appear to show the current selection


  //Place a marker
  Marker _makeMarker(LatLng location, int markerid) {
    return Marker(
      markerId: MarkerId(markerid.toString()),
      position: location,
      consumeTapEvents: false,
    );
  }

  //Drawing the map lines
  Future<void> _drawRoutes(String locationName, Map<String,dynamic> data) async {
    print('Now showing routes for ' + locationName);
    print(data[locationName]);
    List<Polyline> polylineContainer = [];
    List<Marker> markerContainer = [];
    int lineIterator = 0;
    double destinationLat = 0;
    double destinationLong = 0;
    LatLng destinationLatLng;
    for (String key in data[locationName].keys) {
        var latitude = data[locationName][key]['latitude'];
        var longtitude = data[locationName][key]['longtitude'];
        // print(latitude);
        // print(longtitude);
        polylineContainer.add(_makeLine(latitude,longtitude,lineIterator));
        lineIterator++;
        
        destinationLong = data[locationName][key]['restaurant_x'];
        destinationLat = data[locationName][key]['restaurant_y'];
        
        destinationLatLng = LatLng(destinationLat,destinationLong);
        
        print(destinationLatLng);
        markerContainer.add(_makeMarker(destinationLatLng, lineIterator));

      }
    //Draw routes
    setState(() {
      print("111111111111111111111111111111");
      print(markerContainer.length.toString());
      _locationName = locationName;
      _destinationLat = destinationLat;
      _destinationLong = destinationLong;

      visibility = true;
      polylines = polylineContainer;
      markers = markerContainer;
    });

    //Center the map on the appropriate location
    final CameraPosition _endDestination = CameraPosition(
      bearing: 0,
      target: destinationLatLng,
      tilt: 0,
      zoom: 14);


    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_endDestination));

  }

  //Build the listview
  FutureBuilder<Map<String,dynamic>> displayPossibleOptions() {
    //Make a helper function for each button of the listview
    Card _tile(String locationName, Map<String,dynamic> data) => Card(
      child: FlatButton(
        padding: EdgeInsets.all(0.1),
        onPressed: (){
          //Place the functionality for showing the route here
          _drawRoutes(locationName, data);
        },
        child: ListTile(
          title: Text(locationName.toString())
        )
      )
     
    );

    List<Color> colorsForLoad = [
      Colors.red,
      Colors.green,
      Colors.indigo,
      Colors.pinkAccent,
      Colors.blue
    ];
    List<dynamic> possibleLocations = [];
    Map<String,dynamic> datacopy = {};

    return FutureBuilder<Map<String,dynamic>>(
        future: _getCalculate(),
        builder: (context, snapshot) {
          if (snapshot.hasData && possibleLocations.length == 0) {  //save data oni
            possibleLocations = snapshot.data['possible_locations'];
            datacopy = snapshot.data;
            return ListView.builder(
              itemCount: possibleLocations.length,
              itemBuilder: (BuildContext context, int index) {
                print(possibleLocations);
                //Need to add in code to prevent nulls form appearing
                return _tile(possibleLocations[index], datacopy);
              },
            );
          }
          else if (possibleLocations.length != 0) {   //blast saved data
            return ListView.builder(
              itemCount: possibleLocations.length,
              itemBuilder: (BuildContext context, int index) {
                print(possibleLocations);
                //Need to add in code to prevent nulls form appearing
                return _tile(possibleLocations[index], datacopy);
              },
            );
          }
          else {
//            final List<dynamic> possibleLocations = snapshot.data['possible_locations'];
            return ColorLoader(colors: colorsForLoad, duration: Duration(milliseconds: 1200));
          }
        }
      );
  }

  //generate the necessary variables for display location details
  String _locationName = "";
  bool visibility = false;
  double _destinationLong = 0;
  double _destinationLat = 0;

  //Make a button that launches the google maps
  _launchGoogleMaps() async {
    String url = "https://www.google.com/maps/dir/?api=1&destination="+_destinationLat.toString()+","+_destinationLong.toString();
    if (await canLaunch(url)) {
    await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  //Make a widget to display the final location, as well as allow the user to go to google maps
  Visibility displayLocationDetails() {
    return Visibility(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: 
          <Widget>[
            ListTile(
              title: Center(
                child:Text(_locationName, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
              )
            ),
            ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: Text("SHOW IN MAPS"),
                    onPressed: () {
                      _launchGoogleMaps();
                    },
                  )
                ],
              )
          ],
        )
      ),
      visible: visibility,
    );
    
  }

  //Make a widget for the background objects, namely the map and the options
  Center displayBackground() {
    return Center( 
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child:displayMap(),
                    flex:5
                  ),
                  Expanded(
                    child:displayPossibleOptions(),
                    flex:1
                  )
                ]
                )
            )
          );
  }

  //Build the main widget
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(title: Text("Suggested Locations"),),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              displayBackground(),
              displayLocationDetails()
            ],
          )
        )
      );
    }
}
