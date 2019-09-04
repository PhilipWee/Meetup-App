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
  PrefData({this.transportMode, this.quality, this.speed});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Named Routes Demo',
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
            RaisedButton(
              child: Text('Custom'),
              onPressed: 
              () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => MeetingType(data : data)),);
                //Navigator.pushNamed(context, '/meeting_type');
                }
            ),
            RaisedButton(
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meeting Type"),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          RaisedButton(
            child: Text('Date'),
            onPressed: () {
              //Navigator.pushNamed(context, '/transport_mode');
              Navigator.push(context,MaterialPageRoute(builder: (context) => TransportMode(data: data)),);
            }
          ),
          RaisedButton(
            child: Text('Group Outing'),
            onPressed: () {
              //Navigator.pushNamed(context, '/transport_mode');
              Navigator.push(context,MaterialPageRoute(builder: (context) => TransportMode(data: data)),);
              }
          ),
          RaisedButton(
            child: Text('Group Meeting'),
            onPressed: () {
              //Navigator.pushNamed(context, '/transport_mode');
              Navigator.push(context,MaterialPageRoute(builder: (context) => TransportMode(data: data)),);
              }
          )
          
        ]
      )
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
            RaisedButton(
              child: Text('Custom'),
              onPressed: () {Navigator.pushNamed(context, '/meeting_type');}
            ),
            RaisedButton(
              child: Text('Example1'),
              onPressed: () {Navigator.pushNamed(context, '/share_link');}
              
            ),
            RaisedButton(
              child: Text('Example2'),
              onPressed: () {Navigator.pushNamed(context, '/share_link');}
              
            ),
            RaisedButton(
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
            RaisedButton(
              child: Text('Driving'),
              onPressed: () {
                //Navigator.pushNamed(context, '/travel_speed');
                data.transportMode = "Driving";
                Navigator.push(context,MaterialPageRoute(builder: (context) => TravelSpeed(data: data)),);
                }
            ),
            RaisedButton(
              child: Text('Public Transport'),
              onPressed: () {
                //Navigator.pushNamed(context, '/travel_speed');
                data.transportMode = "Public Transport";
                Navigator.push(context,MaterialPageRoute(builder: (context) => TravelSpeed(data: data)),);
                }
            ),
            RaisedButton(
              child: Text('Walk'),
              onPressed: () {
                //Navigator.pushNamed(context, '/travel_speed');
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
            RaisedButton(
              child: Text('Fast'),
              onPressed: () {
                //Navigator.pushNamed(context, '/ratings_reviews');
                data.speed = "Fast";
                Navigator.push(context,MaterialPageRoute(builder: (context) => RatingsReviews(data: data)),);
                }
            ),
            RaisedButton(
              child: Text('Regular'),
              onPressed: () {
                //Navigator.pushNamed(context, '/ratings_reviews');
                data.speed = "Regular";
                Navigator.push(context,MaterialPageRoute(builder: (context) => RatingsReviews(data: data)),);
              }
            ),
            RaisedButton(
              child: Text('Anything'),
              onPressed: () {
                //Navigator.pushNamed(context, '/ratings_reviews');
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
            RaisedButton(
              child: Text('Best'),
              onPressed: () {
                //Navigator.pushNamed(context, '/confirm_data');
                data.quality = "Best";
                Navigator.push(context,MaterialPageRoute(builder: (context) => ConfirmPreference(data: data)),);
                }
            ),
            RaisedButton(
              child: Text('Regular'),
              onPressed: () {
                // Navigator.pushNamed(context, '/confirm_data');
                data.quality = "Regular";
                Navigator.push(context,MaterialPageRoute(builder: (context) => ConfirmPreference(data: data)),);
                }
            ),
            RaisedButton(
              child: Text('Anything'),
              onPressed: () {
                // Navigator.pushNamed(context, '/confirm_data');
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
  final PrefData data;
  ConfirmPreference({this.data});
  @override
  Widget build(BuildContext context) {

    // var prefList = [data.transportMode , data.quality, data.speed];
    // String transportmodedata = data.transportMode;
    // String qualitydata = data.quality;
    // String speeddata = data.speed;

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
            // ListView.builder(
            //   itemCount: prefList.length,
            //   itemBuilder: (context, index) {
            //     return ListTile(
            //       title: Text(prefList[index]),
            //     );
            //   },
            // ),
          ),
          RaisedButton(
            child: Text('Confirm'),
            onPressed: 
            () {
              Navigator.pushNamed(context, '/share_link');}
              // send prefList to server
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
            RaisedButton(
              child: Text('Copy Link'),
              //copy the link to the clipboard on pressed
              onPressed: () {Navigator.pushNamed(context, '/updating_list');}
            ),
            RaisedButton(
              child: Text('Save This setting'),
              //save the setting
              onPressed: () {Navigator.pushNamed(context, '/updating_list');}
            ),
            RaisedButton(
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
        title: Text("Updating List."),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
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
            Container(                          //member 4
              padding: EdgeInsets.all(20),
              child: FutureBuilder<GetMemberList>(
                future: post,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.member4);  
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                },
              )
            ),
            Container(                          //member 5
              padding: EdgeInsets.all(20),
              child: FutureBuilder<GetMemberList>(
                future: post,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.member5);  
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                },
              )
            ),
            RaisedButton(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            RaisedButton(
              child: Text('*Changi City Point*'),
              onPressed: () {Navigator.pushNamed(context, '/map_layout');},
            ),
            RaisedButton(
              child: Text('*Tampines Hub*'),
              onPressed: () {Navigator.pushNamed(context, '/map_layout');},
            ),
            RaisedButton(
              child: Text('*Tampines Mall*'),
              onPressed: () {
                Navigator.pushNamed(context, '/map_layout');
                },
            )
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
  final response = await http.get('http://192.168.0.101:5000/'); 
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
  final String member4;
  final String member5;

  GetMemberList({this.member1, this.member2, this.member3, this.member4, this.member5});

  factory GetMemberList.fromJson(Map<String, dynamic> json) {
    return GetMemberList(
      member1: json['member1'],
      member2: json['member2'],
      member3: json['member3'],
      member4: json['member4'],
      member5: json['member5']
    );
  }
}


class PostPrefData {
  final String userId;
  final int id;
  final String title;
  final String body;
  PostPrefData({this.userId, this.id, this.title, this.body});
 
  factory PostPrefData.fromJson(Map<String, dynamic> json) {
    return PostPrefData(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
 
  Map toMap() {
    var map = new Map<String, dynamic>();
    map["userId"] = userId;
    map["title"] = title;
    map["body"] = body;
 
    return map;
  }
}

Future<GetMemberList> sendPrefData() async {
  final response = await http.get('http://192.168.0.101:5000/'); 
  if (response.statusCode == 200) {
    return GetMemberList.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}