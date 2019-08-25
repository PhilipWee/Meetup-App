import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

//Okay i think i get how branches work alrdy

void main() => runApp(MyApp());

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
        '/share_link': (context) => ShareLink(),
        '/updating_list': (context) => UpdatingList(),
        '/final_result': (context) => PickYourPlace(),
        '/map_layout': (context) => MapLayout(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
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
              onPressed: () {Navigator.pushNamed(context, '/meeting_type');}
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
            onPressed: () {Navigator.pushNamed(context, '/transport_mode');}
          ),
          RaisedButton(
            child: Text('Group Outing'),
            onPressed: () {Navigator.pushNamed(context, '/transport_mode');}
          ),
          RaisedButton(
            child: Text('Group Meeting'),
            onPressed: () {Navigator.pushNamed(context, '/transport_mode');}
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
              onPressed: () {Navigator.pushNamed(context, '/travel_speed');}
            ),
            RaisedButton(
              child: Text('Public Transport'),
              onPressed: () {Navigator.pushNamed(context, '/travel_speed');}
            ),
            RaisedButton(
              child: Text('Walk'),
              onPressed: () {Navigator.pushNamed(context, '/travel_speed');}
            ),
          ],
        )
        ),
      );
  }
}

class TravelSpeed extends StatelessWidget {

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
              onPressed: () {Navigator.pushNamed(context, '/ratings_reviews');}
            ),
            RaisedButton(
              child: Text('Regular'),
              onPressed: () {Navigator.pushNamed(context, '/ratings_reviews');}
            ),
            RaisedButton(
              child: Text('Anything'),
              onPressed: () {Navigator.pushNamed(context, '/ratings_reviews');}
            ),
          ],
        )
        ),
      );
  }
}

class RatingsReviews extends StatelessWidget {

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
              onPressed: () {Navigator.pushNamed(context, '/share_link');}
            ),
            RaisedButton(
              child: Text('Regular'),
              onPressed: () {Navigator.pushNamed(context, '/share_link');}
            ),
            RaisedButton(
              child: Text('Anything'),
              onPressed: () {Navigator.pushNamed(context, '/share_link');}
            ),
          ],
        )
        ),
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
              //save the setting for the
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
              onPressed: () {Navigator.pushNamed(context, '/map_layout');},
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
      bearing: 192.8334901395799+180-10,
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
        icon: Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_location));
  }
}