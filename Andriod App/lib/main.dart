import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';


void main() => runApp(MyApp());

class PrefData {
  String link;
  String transportMode;
  int speed;
  int quality;
  String body;
  PrefData({this.transportMode, this.quality, this.speed, this.link});

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/meeting_type': (context) => MeetingType(),
        '/examples': (context) => Examples(),
        '/transport_mode': (context) => TransportMode(),
        '/travel_speed': (context) => TravelSpeed(),
        '/ratings_reviews': (context) => RatingsReviews(),
        '/confirm_data': (context) => ConfirmPreference(),
        '/share_link': (context) => ShareLink(),
        // '/updating_list': (context) => UpdatingList(post: fetchUpdatingList()),
        '/updating_list': (context) => UpdatingList(),
        '/final_result': (context) => PickYourPlace(),
        '/map_layout': (context) => MapLayout(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  final data = PrefData(transportMode: "", speed: 0, quality: 0, link:"");
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
                //Navigator.pushNamed(context, '/meeting_type');
                }
            ),
            FlatButton(
              child: Text('Defaults'),
              onPressed: () {Navigator.pushNamed(context, '/examples');}
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

class Examples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Examples"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            FlatButton(
              child: Text('Custom'),
              onPressed: () {Navigator.pushNamed(context, '/meeting_type');}
            ),
            FlatButton(
              child: Text('Example1'),
              onPressed: () {Navigator.pushNamed(context, '/share_link');}
              
            ),
            FlatButton(
              child: Text('Example2'),
              onPressed: () {Navigator.pushNamed(context, '/share_link');}
              
            ),
            FlatButton(
              child: Text('Example3'),
              onPressed: () {Navigator.pushNamed(context, '/share_link');}
              
            ),
          ],
        )
        ),
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

  getUserLocation() async{
    var location = Location();
    LocationData currentLocation = await location.getLocation();
    double lat = currentLocation.latitude;
    double long = currentLocation.longitude;
    print("LAT = $lat, LONG = $long");
  }


  createSessionLink() async {
    int quality = data.quality;
    int speed = data.speed;
    String transportmode = data.transportMode;

    Map<String, String> headers = {"Content-type": "application/json"};
    // String url = 'http://192.168.194.210:5000/session/create'; //use at Phillip's house
    String url = 'http://192.168.194.228:5000/session/create'; //use at Stephen's house
    String json = '{"lat":1.359310,   "long":103.989343,   "quality":$quality,   "speed":$speed,    "transport_mode":$transportmode}';
    http.Response response = await http.post(url, headers:headers, body:json);
    int statusCode = response.statusCode; 
    String body = response.body;
    Map<String, dynamic> user = jsonDecode(body); //{sessionid: 123456}
    var sessionid = user['session_id'];
    data.link = "http://192.168.194.210:5000/session/$sessionid";
    print('Sharable link--> http://192.168.194.210:5000/session/$sessionid');
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
              getUserLocation();
              // Navigator.push(context,MaterialPageRoute(builder: (context) => ShareLink(data: data)),);
              
            }
          ),
        ]
      )
    );
  }
}

class ShareLink extends StatelessWidget {
  final PrefData data;
  ShareLink({this.data});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Share the Link!"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            Text(data.link),
            FlatButton(
              child: Text('Copy Link'),
              //copy the link to the clipboard on pressed
              onPressed: () {
                Navigator.pushNamed(context, '/updating_list');  
                Clipboard.setData(new ClipboardData(text: data.link));
                }
            ),
            FlatButton(
              child: Text('Save This setting'),
              //save the setting
              onPressed: () {Navigator.pushNamed(context, '/updating_list');}
            ),
            FlatButton(
              child: Text('Share'),
              //open app drawer and wait until item in drawer pressed
              onPressed: () {Navigator.pushNamed(context, '/updating_list');}
            ),
          ],
        )
        ),
      );
  }
}

class UpdatingList extends StatelessWidget {

  getMemberData() async {
  http.Response response = await http.get('http://192.168.194.210:5000/session/123456');
  int statusCode = response.statusCode;
  String json = response.body;
  print(statusCode);
  print(json);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Updating List"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            Container(                          //member 0
              padding: EdgeInsets.all(20),
              child: Text("You")
            ),
            FlatButton(
              child: Text('Make My Meetup!'),
              onPressed: () {
                Navigator.pushNamed(context, '/final_result');
                // getPositionName(1.284858,103.826318);
                getMemberData();
                }
            ),
          ],
        )
        ),
      );
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
              onPressed: () {Navigator.pushNamed(context, '/map_layout');},
            ),
            FlatButton(
              child: Text('*Tampines Hub*'),
              onPressed: () {Navigator.pushNamed(context, '/map_layout');},
            ),
            FlatButton(
              child: Text('*Tampines Mall*'),
              onPressed: () {Navigator.pushNamed(context, '/map_layout');},
            ),
            FlatButton(
              child: Text('*Tampines One*'),
              onPressed: () {Navigator.pushNamed(context, '/map_layout');},
            ),
            FlatButton(
              child: Text('*Tampines Eastpoint*'),
              onPressed: () {Navigator.pushNamed(context, '/map_layout');},
            ),
            FlatButton(
              child: Text('*Tampines Regional Library*'),
              onPressed: () {Navigator.pushNamed(context, '/map_layout');},
            ),
            FlatButton(
              child: Text('*White Sands*'),
              onPressed: () {Navigator.pushNamed(context, '/map_layout');},
            ),
            FlatButton(
              child: Text('*Downtown East*'),
              onPressed: () {Navigator.pushNamed(context, '/map_layout');},
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

