import 'package:flutter/material.dart';

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
            Text('Here are your locations:'),
            Text('Wee house @ Kensington Drive'),
            Text('KFC @ Tiong Bahru Plaza'),
            Text('NEX @ Serangoon')
          ],
        )
        ),
      );
  }
}

// class DateButton extends StatefulWidget {
//   DateButton({Key key}) : super(key: key);
//   @override
//   _DateButton createState() => _DateButton();
// }
// class _DateButton extends State<DateButton> {
//   String dateType = 'Fun!';
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: DropdownButton<String>(
//           value: dateType,
//           onChanged: (String newDateType) {
//             setState(() {
//               dateType = newDateType;
//             });
//           },
//           items: <String>['Fun!', 'Food', 'Study']
//               .map<DropdownMenuItem<String>>((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }

// class OutingButton extends StatefulWidget {
//   OutingButton({Key key}) : super(key: key);
//   @override
//   _OutingButton createState() => _OutingButton();
// }
// class _OutingButton extends State<OutingButton> {
//   String outingType = 'Fun!';
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: DropdownButton<String>(
//           value: outingType,
//           onChanged: (String newOutingType) {
//             setState(() {
//               outingType = newOutingType;
//             });
//           },
//           items: <String>['Fun!', 'Food', 'Study']
//               .map<DropdownMenuItem<String>>((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }

// class MeetingButton extends StatefulWidget {
//   MeetingButton({Key key}) : super(key: key);
//   @override
//   _MeetingButton createState() => _MeetingButton();
// }
// class _MeetingButton extends State<MeetingButton> {
//   String meetingType = 'Fun!';
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: DropdownButton<String>(
//         value: meetingType,
//         onChanged: (String newMeetingType) {
//           setState(() {
//             meetingType = newMeetingType;
//           });
//         },
//         items: <String>['Project', 'Food', 'Business']
//             .map<DropdownMenuItem<String>>((String value) {
//           return DropdownMenuItem<String>(
//             value: value,
//             child: Text(value),
//           );
//         }).toList(),
//       ),
//       );
//   }
// }

