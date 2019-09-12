import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/meeting_type': (context) => MeetingType(),
        '/transport_mode': (context) => TransportMode(),
        '/travel_speed': (context) => TravelSpeed(),
        '/ratings_reviews': (context) => RatingsReviews(),
        '/confirm_data': (context) => ConfirmPreference(),
        '/share_link': (context) => ShareLink(),
        '/updating_list': (context) => UpdatingList(),
        '/final_result': (context) => PickYourPlace(),
        '/map_layout': (context) => MapLayout(),
      },
    );
  }
}

class PrefData {
  double lat;
  double long;
  String link;
  String transportMode;
  int speed;
  int quality;
  String body;
  PrefData({this.transportMode, this.quality, this.speed, this.link, this.body, this.lat, this.long});
}

class HomeScreen extends StatelessWidget {
  final data = PrefData(transportMode: "", speed: 0, quality: 0, link:"");

  refreshServer() async {
    http.Response response = await http.get('http://192.168.194.228:5000/refresh');
    int statusCode = response.statusCode;
    String body = response.body;
    print("SERVER REFRESHED WITH STATUSCODE: $statusCode");
    print("SERVER SAYS: $body");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            FlatButton(
              child: Text('Custom'),
              onPressed: 
              () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => MeetingType(data : data)),); // send data to said screen and also go to the said screen
                // refreshServer();
                }
            ),
          ],
        )
        ),
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

    return ListView.builder(

      padding: EdgeInsets.zero,
      itemCount: custImgs.length,
      itemBuilder: (context, index) {
        return Card(
          child: FlatButton(
            padding: EdgeInsets.all(0.0),
            onPressed: (){

             Navigator.push(context,MaterialPageRoute(builder: (context) => TransportMode(data: data)),);

           },
           child:_buildCustomButton(custLabels[index], custImgs[index]) ,
          ),
        );
      },
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
        padding: const EdgeInsets.all(0.0),
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

class TransportMode extends StatelessWidget {
  final PrefData data;
  TransportMode({this.data});
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Mode of Transport"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            FlatButton(
              child: Text('Driving'),
              onPressed: () {
                data.transportMode = "Driving";
                Navigator.push(context,MaterialPageRoute(builder: (context) => TravelSpeed(data: data)),);
                }
            ),
            FlatButton(
              child: Text('Public Transport'),
              onPressed: () {
                data.transportMode = "Public Transport";
                Navigator.push(context,MaterialPageRoute(builder: (context) => TravelSpeed(data: data)),);
                }
            ),
            FlatButton(
              child: Text('Walk'),
              onPressed: () {
                data.transportMode = "Walk";
                Navigator.push(context,MaterialPageRoute(builder: (context) => TravelSpeed(data: data)),);
                }
            ),
          ],
        )
        ),
      );
  }
}

class TravelSpeed extends StatelessWidget {
  final PrefData data;
  TravelSpeed({this.data});
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("How fast do you need to get there?"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            FlatButton(
              child: Text('Fast'),
              onPressed: () {
                data.speed = 3;
                Navigator.push(context,MaterialPageRoute(builder: (context) => RatingsReviews(data: data)),);
                }
            ),
            FlatButton(
              child: Text('Regular'),
              onPressed: () {
                data.speed = 2;
                Navigator.push(context,MaterialPageRoute(builder: (context) => RatingsReviews(data: data)),);
              }
            ),
            FlatButton(
              child: Text('Anything'),
              onPressed: () {
                data.speed = 1;
                Navigator.push(context,MaterialPageRoute(builder: (context) => RatingsReviews(data: data)),);
              }
            ),
          ],
        )
        ),
      );
  }
}

class RatingsReviews extends StatelessWidget {
  final PrefData data;
  RatingsReviews({this.data});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ratings & Reviews "),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            FlatButton(
              child: Text('Best'),
              onPressed: () {
                data.quality = 3;
                Navigator.push(context,MaterialPageRoute(builder: (context) => ConfirmPreference(data: data)),);
                }
            ),
            FlatButton(
              child: Text('Regular'),
              onPressed: () {
                data.quality = 2;
                Navigator.push(context,MaterialPageRoute(builder: (context) => ConfirmPreference(data: data)),);
                }
            ),
            FlatButton(
              child: Text('Anything'),
              onPressed: () {
                data.quality = 1;
                Navigator.push(context,MaterialPageRoute(builder: (context) => ConfirmPreference(data: data)),);
                }
            ),
          ],
        )
        ),
      );
  }
}

class ConfirmPreference extends StatelessWidget {

  final PrefData data;
  ConfirmPreference({this.data});

  createSessionLink() async {
    var location = Location();
    LocationData currentLocation = await location.getLocation();
    data.lat = currentLocation.latitude;
    data.long = currentLocation.longitude;
    double lat = currentLocation.latitude;
    double long = currentLocation.longitude;
    int quality = data.quality;
    int speed = data.speed;
    String transportmode = data.transportMode;

    Map<String, String> headers = {"Content-type": "application/json"};
    String url = 'http://192.168.194.210:5000/session/create'; //server running on Philip's laptop
    // String url = 'http://192.168.194.228:5000/session/create'; //server running on Stephen's laptop
    String json = '{"lat":$lat,   "long":$long,   "quality":$quality,   "speed":$speed,    "transport_mode":"$transportmode"}';
    http.Response response = await http.post(url, headers:headers, body:json);
    int statusCode = response.statusCode;
    String body = response.body;
    print("POST REQUEST SUCCESSFUL/FAILED WITH STATUSCODE: $statusCode");
    print("SERVER SAYS: $body");
    Map<String, dynamic> sessionidjsonversion = jsonDecode(body); //{sessionid: 123456}
    var sessionid = sessionidjsonversion['session_id'];
    print("Transport Mode:$transportmode");
    print("Quality:$quality");
    print("Speed:$speed");
    // data.link = "http://192.168.194.228:5000/session/$sessionid";
    // print('Link Created--> http://192.168.194.228:5000/session/$sessionid');
    data.link = "http://192.168.194.210:5000/session/$sessionid";
    print('Link Created--> http://192.168.194.210:5000/session/$sessionid');
    }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirm Preferences?"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children : [
          Expanded(
            child:
            ListView(
              children: [
                ListTile(title: Text(data.transportMode)),
                ListTile(title: Text(data.quality.toString())),
                ListTile(title: Text(data.speed.toString())),
              ]
            )
          ),
          FlatButton(
            child: Text('Confirm'),
            onPressed: 
            () async{
              // createSessionLink();
              Navigator.push(context,MaterialPageRoute(builder: (context) => ShareLink(data: data)),);
              print("Details Confirmed!");
            }
          ),
        ]
      )
    );
  }
}

class ShareLink extends StatelessWidget {
  final snackBar = SnackBar(content: Text('Link Copied'),duration: Duration(seconds: 2));
  final PrefData data;
  ShareLink({this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Share the Link!"),
        backgroundColor: Colors.black,
      ),
      body:
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            Container(child: Text(data.link)),
            Builder(
              builder: (context) => FlatButton(
                child: Text('Copy Link'),
                onPressed: () {
                  Scaffold.of(context).showSnackBar(snackBar);
                  print("LINK COPIED");
                },
              ),
            ),
            FlatButton(
              child: Text('Now we wait...'),
              onPressed: () {
                Navigator.pushNamed(context, '/updating_list');
                // Navigator.push(context,MaterialPageRoute(builder: (context) => UpdatingList(data: data)),);
                }
            ),
          ],
        )
      )
    );
  }
}

class UpdatingList extends StatefulWidget {
  UpdatingList({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _UpdatingListState createState() => new _UpdatingListState();
}

class _UpdatingListState extends State<UpdatingList> {
  final PrefData data;
  _UpdatingListState({this.data});
// THIS IS WHAT THE SERVER RETURNS WHEN AFTER HTTP GET
// {
//   "users": [
//     {
//       "lat": 37.4219983, 
//       "long": -122.084, 
//       "metrics": {
//         "quality": 3, 
//         "speed": 3
//       }, 
//       "transport_mode": "Driving", 
//       "username": "username"
//     }, 
//     {
//       "identifier": "identifier", 
//       "lat": 1.2848664, 
//       "long": 103.8244263, 
//       "metrics": {
//         "quality": 5, 
//         "speed": 5
//       }, 
//       "transport_mode": "public"
//     }
//   ]
// }
  Future<List<Map<String, dynamic>>> getMembers() async {
    // http.Response response = await http.get('http://192.168.194.228:5000/session/123456');
    http.Response response = await http.get('http://192.168.194.210:5000/session/123456');
    int statusCode = response.statusCode;
    String body = response.body;
    print("GET REQUEST SUCCESSFUL/FAILED WITH STATUSCODE: $statusCode");
    print("SERVER SAYS: $body");
    Map<String, dynamic> memberDatajsonVersion = jsonDecode(body); //parse the data from server into a map<string,dynamic>
    List membersData = memberDatajsonVersion["users"];    //extract the list of user detail maps into a list
    List<Placemark> myplace = await Geolocator().placemarkFromCoordinates(data.lat,data.long); //get the name of the place where user is at right now
    Map<String,String> placeNameMap = {"username": myplace[0].thoroughfare.toString() }; //add the place name as a value to the key "username" to a new map
    for (Map<String, dynamic> mapcontent in membersData) { // for every user detail map packet in the main list
      List<Placemark> place = await Geolocator().placemarkFromCoordinates(mapcontent["lat"], mapcontent["long"]); //use the lat long values to find the placename and
      placeNameMap[mapcontent["identifier"].toString()] = place[0].thoroughfare.toString(); // add the placename to the map with the key being the name of the user
    }
    membersData.add(placeNameMap);
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
    print("Printing directly! $membersData");
    return membersData;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Participants"),
      ),
      body: Container(
          child: FutureBuilder(
            future: getMembersFAKE(),
            builder: (BuildContext context, AsyncSnapshot snapshot){
              print(snapshot);
              if(snapshot.data == null){
                return Container(
                  child: Center(
                    child: Text("Loading...")
                  )
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length-1,
                  itemBuilder: (BuildContext context, int index) {
                    Map<String,dynamic> myMap = snapshot.data[snapshot.data.length-1];
                    if (index == 0){
                      return ListTile(
                        leading: CircleAvatar(backgroundImage: AssetImage("images/mouseAvatar.jpg"),),
                        title: Text("You"),
                        subtitle: Text(snapshot.data[index]["transport_mode"]),
                        trailing: Text(myMap[snapshot.data[index]["username"]])
                      );
                    }
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: AssetImage("images/mouseAvatar.jpg"),),
                      title: Text(snapshot.data[index]["identifier"]),
                      subtitle: Text(snapshot.data[index]["transport_mode"]),
                      trailing: Text(myMap[snapshot.data[index]["identifier"]]),

                    );
                  },
                );
              }
            },
          ),
        ),
      );
  }
}



// class PickYourPlace extends StatelessWidget {

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Pick Your Place"),
//         backgroundColor: Colors.black,
//       ),
//       body: Center(
//         child: ListView(
//           children:[
//             FlatButton(
//               child: Text('*Changi City Point*'),
//               onPressed: () {Navigator.pushNamed(context, '/map_layout');},
//             ),
//             FlatButton(
//               child: Text('*Tampines Hub*'),
//               onPressed: () {Navigator.pushNamed(context, '/map_layout');},
//             ),
//             FlatButton(
//               child: Text('*Tampines Mall*'),
//               onPressed: () {Navigator.pushNamed(context, '/map_layout');},
//             ),
//             FlatButton(
//               child: Text('*Tampines One*'),
//               onPressed: () {Navigator.pushNamed(context, '/map_layout');},
//             ),
//             FlatButton(
//               child: Text('*Tampines Eastpoint*'),
//               onPressed: () {Navigator.pushNamed(context, '/map_layout');},
//             ),
//             FlatButton(
//               child: Text('*Tampines Regional Library*'),
//               onPressed: () {Navigator.pushNamed(context, '/map_layout');},
//             ),
//             FlatButton(
//               child: Text('*White Sands*'),
//               onPressed: () {Navigator.pushNamed(context, '/map_layout');},
//             ),
//             FlatButton(
//               child: Text('*Downtown East*'),
//               onPressed: () {Navigator.pushNamed(context, '/map_layout');},
//             ),
//           ],
//         )
//         ),
//       );
//   }
// }

// class MapLayout extends StatelessWidget {

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("*Tampines Mall*"),
//         backgroundColor: Colors.black,
//       ),
//       body: MapSample()
//       );
//   }
// }

// class MapSample extends StatefulWidget {
//   @override
//   State<MapSample> createState() => MapSampleState();
// }

// class MapSampleState extends State<MapSample> {
//   Completer<GoogleMapController> _controller = Completer();

//   static final CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(1.366960, 103.869424),
//     zoom: 14.4746,
//   );

//   static final CameraPosition _location = CameraPosition(
//       bearing: 0,
//       target: LatLng(1.366960, 103.869424),
//       tilt: 59.440717697143555,
//       zoom: 19.151926040649414);

//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       body: GoogleMap(
//         mapType: MapType.hybrid,
//         initialCameraPosition: _kGooglePlex,
//         onMapCreated: (GoogleMapController controller) {
//           _controller.complete(controller);
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _goToPosition,
//         label: Text('Lets\'s Go!'),
//         icon: Icon(Icons.fastfood),
//       ),
//     );
//   }

//   Future<void> _goToPosition() async {
//     final GoogleMapController controller = await _controller.future;
//     controller.animateCamera(CameraUpdate.newCameraPosition(_location));
//   }
// }