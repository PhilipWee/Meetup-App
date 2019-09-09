import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class PrefData {
  String transportMode;
  String speed;
  String quality;
  String body;
  PrefData({this.transportMode, this.quality, this.speed,});

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
        '/updating_list': (context) => UpdatingList(post: fetchUpdatingList()),
        // '/updating_list': (context) => UpdatingList(),
        '/final_result': (context) => PickYourPlace(),
        '/map_layout': (context) => MapLayout(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  final data = PrefData(transportMode: "0", speed: "0", quality: "0");
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
                data.speed = "Fast";
                Navigator.push(context,MaterialPageRoute(builder: (context) => RatingsReviews(data: data)),);
                }
            ),
            FlatButton(
              child: Text('Regular'),
              onPressed: () {
                data.speed = "Regular";
                Navigator.push(context,MaterialPageRoute(builder: (context) => RatingsReviews(data: data)),);
              }
            ),
            FlatButton(
              child: Text('Anything'),
              onPressed: () {
                data.speed = "Anything";
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
                data.quality = "Best";
                Navigator.push(context,MaterialPageRoute(builder: (context) => ConfirmPreference(data: data)),);
                }
            ),
            FlatButton(
              child: Text('Regular'),
              onPressed: () {
                data.quality = "Regular";
                Navigator.push(context,MaterialPageRoute(builder: (context) => ConfirmPreference(data: data)),);
                }
            ),
            FlatButton(
              child: Text('Anything'),
              onPressed: () {
                data.quality = "Anything";
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
  // final Future<PostData> post;
  final PrefData data;
  // ConfirmPreference({Key key, this.post, this.data,}) : super(key: key);
  ConfirmPreference({Key key, this.data,}) : super(key: key);
  static final createposturl = 'http://192.168.194.210:5000/session/123456';
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
                ListTile(title: Text(data.quality)),
                ListTile(title: Text(data.speed))
              ]
            )
          ),
          FlatButton(
            child: Text('Confirm'),
            onPressed: 
            () async{
              Navigator.pushNamed(context, '/share_link');
              // PostData newPost = new PostData(
              //   lat: 1.340595,
              //   long: 103.963153,
              //   quality: data.quality,
              //   speed: data.speed,
              //   transportmode: data.transportMode
              // );
              // PostData p = await createPost(createposturl,body: newPost.toMap());
              // print(p.transportmode);
            }
          ),
        ]
      )
    );
  }
}

class ShareLink extends StatelessWidget {
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
            FlatButton(
              child: Text('Copy Link'),
              //copy the link to the clipboard on pressed
              onPressed: () {Navigator.pushNamed(context, '/updating_list');}
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

  final Future<GetMemberList> post;
  UpdatingList({Key key, this.post}) : super(key: key);

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
            Container(                          //member 1
              padding: EdgeInsets.all(20),
              child: FutureBuilder<GetMemberList>(
                future: post,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.member1);  
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                },
              )
            ),
            Container(                          //member 2
              padding: EdgeInsets.all(20),
              child: FutureBuilder<GetMemberList>(
                future: post,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.member2);  
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                },
              )
            ),
            Container(                          //member 3
              padding: EdgeInsets.all(20),
              child: FutureBuilder<GetMemberList>(
                future: post,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.member3);  
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                },
              )
            ),
            FlatButton(
              child: Text('Make My Meetup!'),
              onPressed: () {Navigator.pushNamed(context, '/final_result');}
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

Future<GetMemberList> fetchUpdatingList() async {
  final response = await http.get('http://192.168.194.210:5000/'); 
  if (response.statusCode == 200) {
    return GetMemberList.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}

class GetMemberList {
  final String member1;
  final String member2;
  final String member3;


  GetMemberList({this.member1, this.member2, this.member3,});

  factory GetMemberList.fromJson(Map<String, dynamic> json) {
    return GetMemberList(
      member1: json['member1'],
      member2: json['member2'],
      member3: json['member3'],
    );
  }
}

// class PostData {

//   final double lat;
//   final double long;
//   final String quality;
//   final String speed;
//   final String transportmode;
//   PostData({this.lat, this.long, this.quality, this.speed, this.transportmode,});
 
//   factory PostData.fromJson(Map<String, dynamic> json) {
//     return PostData(
//       lat: json['long'],
//       long: json['lat'],
//       quality: json['quality'],
//       speed: json['speed'],
//       transportmode: json['transport_mode'],
//     );
//   }
//   Map toMap() {
//     var map = new Map<String, dynamic>();
//     map["lat"] = lat;
//     map["long"] = long;
//     map["quality"] = quality;
//     map["speed"] = speed;
//     map["transport_mode"] = transportmode;
//     return map;
//   }
// }

// Future<PostData> createPost(String url, {Map body}) async {
//   return http.post(url, body: body).then((http.Response response) {
//     final int statusCode = response.statusCode;
 
//     if (statusCode < 200 || statusCode > 400 || json == null) {
//       throw new Exception("Error while fetching data");
//     }
//     return PostData.fromJson(json.decode(response.body));
//   });
// }
