import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

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
  PrefData({this.username,this.transportMode, this.quality, this.speed, this.link, this.lat, this.long, this.activityType});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
      },
    );
  }
}

  refreshServer() async {
    http.Response response = await http.get('http://192.168.194.228:5000/refresh');
    int statusCode = response.statusCode;
    String body = response.body;
    print("SERVER REFRESHED WITH STATUSCODE: $statusCode");
    print("SERVER SAYS: $body");
  }

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.black,
        leading: Icon(Icons.home), 
      ),
      body: HomeUsernameWidget()
      );
  }

}

class HomeUsernameWidget extends StatefulWidget {
  @override
  HomeUsernameState createState() => HomeUsernameState();
}

class HomeUsernameState extends State<HomeUsernameWidget> {
  static String name;
  final data = PrefData(username:"",activityType: "",lat: 0,long: 0,link:"",transportMode: "",speed: 0, quality: 0,);
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
      margin: const EdgeInsets.only(left: 50.0, top: 50.0, right: 50.0),
      alignment: Alignment.center,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset(
              'images/MeetUp_Logo.png',
              scale: 3,
            ),
          ),
          Text(
            "Start Your Meetup!",
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );

    //Button Section
    Widget buttonSection = Container(
      height: 100.0,
      child: ButtonBar(
        alignment: MainAxisAlignment.spaceEvenly,
        children: [
          FlatButton(
            onPressed: () {
              refreshServer();
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
              }
            },
            child: _buildButtonColumn(Colors.black, Icons.arrow_forward, 'Get Started!'),
            color: Colors.amber,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          )
        ],
      ) ,
    );

    return Center(
        child: ListView(
          children:[
            welcomeSection,
            Padding(
              padding: const EdgeInsets.only(left: 50.0, top: 30.0, right: 50.0, bottom: 30.0),
              child: TextFormField(
                controller: textController,
                decoration: InputDecoration(
                    labelText: "Username"
                ),
              ),
            ),
            buttonSection
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
              fontWeight: FontWeight.w500,
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
    "Date",
    "Outing",
    "Meeting",
    "About Us"
    ];
  final List<String> custImgs = [
    "images/dateButton.jpg",
    "images/outingButton.jpg",
    "images/meetingButton.jpg",
    "images/MeetUp_Logo.png"
    ];

  @override
  //Creates a listview with buildCustomButtons inside
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Meetup Type"),
        backgroundColor: Colors.black,
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
        backgroundColor: Colors.black,
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
    // String url = 'http://192.168.194.210:5000/session/create'; //Philip's laptop
    String url = 'http://192.168.194.228:5000/session/create'; //Stephen's laptop
    String jsonpackage = '{"lat":$lat,   "long":$long,   "quality":$quality,   "speed":$speed,    "transport_mode":"$transportmode"}';
    print("jsonpackage $jsonpackage");
    http.Response response = await http.post(url, headers:headers, body:jsonpackage);

    //store returned string-map "{sessionid: 123456}"" into a String
    int statusCode = response.statusCode;
    String body = response.body;
    print("POST REQUEST SUCCESSFUL/FAILED WITH STATUSCODE: $statusCode");
    print("SERVER SAYS: $body");

    //decode the string-map
    Map<String, dynamic> sessionidjsonversion = jsonDecode(body);
    var sessionid = sessionidjsonversion['session_id'];
    print("Transport Mode:$transportmode");
    print("Quality:$quality");
    print("Speed:$speed");
    data.link = "http://192.168.194.228:5000/session/$sessionid"; //Stephen's laptop

    String tempvar = data.link;
    print('Link Created--> $tempvar'); //Stephen's laptop
    // data.link = "http://192.168.194.210:5000/session/$sessionid"; //Philip's laptop
    // print('Link Created--> http://192.168.194.210:5000/session/$sessionid'); // Philip's laptop
    return jsonpackage;
    }

  String value1 = "Select...";
  String value2 = "Select...";
  String value3 = "Select...";
  String value4 = "Select...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  width: 180,
                  padding: const EdgeInsets.only(left: 10.0, top: 8.0, right: 30.0, bottom: 8.0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.fastfood, color: Colors.black),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Activities", style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0
                        ),),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: value1,
                        onChanged: (String newValue) {
                          setState(() {
                            value1 = newValue;
                            data.activityType = newValue; //ADD TO DATABASE
                          });
                        },
                        items: <String>["Select...", "Lunch/Dinner", "Recreation", "Study"].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ) ,
                )
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  width: 180,
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
                Expanded(
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
                Container(
                  width: 180,
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
                Expanded(
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
                Container(
                  width: 180,
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
                Expanded(
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
              if (value1 != "Select..." && value2 != "Select..."
                  && value3 != "Select..." && value4 != "Select...") {
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
        backgroundColor: Colors.black,
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
    http.Response response = await http.get('http://192.168.194.228:5000/session/123456');
    // http.Response response = await http.get('http://192.168.194.210:5000/session/123456');
    int statusCode = response.statusCode;
    String body = response.body;
    print("GET REQUEST SUCCESSFUL/FAILED WITH STATUSCODE: $statusCode");
    print("SERVER SAYS: $body");
    Map<String, dynamic> memberDatajsonVersion = jsonDecode(body); //parse the data from server into a map<string,dynamic>
    List membersData = memberDatajsonVersion["users"];
    print(data.lat);
    print(data.long);  
    //extract the list of user detail maps into a list
    List<Placemark> myplace = await Geolocator().placemarkFromCoordinates(data.lat,data.long); //get the name of the place where user is at right now
    Map<String,String> placeNameMap = {"username": myplace[0].thoroughfare.toString() }; //add the place name as a value to the key "username" to a new map
    for (Map<String, dynamic> mapcontent in membersData) { // for every user detail map packet in the main list
      List<Placemark> place = await Geolocator().placemarkFromCoordinates(mapcontent["lat"], mapcontent["long"]); //use the lat long values to find the placename and
      if (mapcontent["identifier"] != null){
        placeNameMap[mapcontent["identifier"].toString()] = place[0].thoroughfare.toString(); // add the placename to the map with the key being the name of the user
      }
    }
    membersData.add(placeNameMap);
    print("membersData-> $membersData");
    return membersData;
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
                      title: Text("You"),
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
                    //TODO go to next page
                    print(data.link);
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

class PickYourPlace extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pick Your Place"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: ListView(
          children:[
            FlatButton(
              child: Text('*Changi City Point*'),
              onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context) => MapLayout()),);},
            ),
            FlatButton(
              child: Text('*Tampines Hub*'),
              onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context) => MapLayout()),);},
            ),
            FlatButton(
              child: Text('*Tampines Mall*'),
              onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context) => MapLayout()),);},
            ),
            FlatButton(
              child: Text('*Tampines One*'),
              onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context) => MapLayout()),);},
            ),
            FlatButton(
              child: Text('*Tampines Eastpoint*'),
              onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context) => MapLayout()),);},
            ),
            FlatButton(
              child: Text('*Tampines Regional Library*'),
              onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context) => MapLayout()),);},
            ),
            FlatButton(
              child: Text('*White Sands*'),
              onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context) => MapLayout()),);},
            ),
            FlatButton(
              child: Text('*Downtown East*'),
              onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context) => MapLayout()),);},
            ),
          ],
        )
        ),
      );
  }
}

class MapLayout extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("*Tampines Mall*"),
        backgroundColor: Colors.black,
      ),
      body: MapSample()
      );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(1.366960, 103.869424),
    zoom: 14.4746,
  );

  static final CameraPosition _location = CameraPosition(
      bearing: 0,
      target: LatLng(1.366960, 103.869424),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToPosition,
        label: Text('Lets\'s Go!'),
        icon: Icon(Icons.fastfood),
      ),
    );
  }

  Future<void> _goToPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_location));
  }
}

