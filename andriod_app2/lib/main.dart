import 'dart:convert';
import 'GoogleSignIn.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;

String globalurl(){
//   String serverAddress = "http://192.168.194.178:5000";
//   String serverAddress = "http://169.254.158.154:5000";
//  String serverAddress = "http://ec2-3-16-181-51.us-east-2.compute.amazonaws.com:5000";
  String serverAddress = "http://ec2-3-14-68-232.us-east-2.compute.amazonaws.com:5000";
  return serverAddress;
}

void main() => runApp(MyApp());


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
        '/': (context) => GoogleSignInPage(),
      },
    );
  }
}
class GoogleSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class CheckNetworkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: Connectivity().onConnectivityChanged,
            builder: (BuildContext ctxt,
                AsyncSnapshot<ConnectivityResult> snapShot) {
              if (!snapShot.hasData) return CircularProgressIndicator();
              var result = snapShot.data;
              switch (result) {
                case ConnectivityResult.none:
                  print("Internet servie unavailable");
                  return Center(child: Text("No Internet Connection!"));
                case ConnectivityResult.mobile:
                case ConnectivityResult.wifi:
                  return HomeScreen();
                default:
                  return Center(child: Text("No Internet Connection!"));
              }
            })
    );
  }
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
  bool invalidLink = false;
  static String name;
  static String sessionlink;
  final data = PrefData(username:"",activityType: "",lat: 0,long: 0,link:"",transportMode: "",speed: 0, quality: 0,sessionid: '');
  final textController  = TextEditingController();
  final idTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  saveMyLocation() async{
    var location = Location();
    LocationData currentLocation = await location.getLocation();
    data.lat = currentLocation.latitude;
    data.long = currentLocation.longitude;
    print("User Location Data");
    print("${data.lat},${data.long}");
    Map<String,double> mycoordinates = {"mylat":data.lat, "mylong":data.long};
    List<Placemark> myplacemark = await Geolocator().placemarkFromCoordinates(data.lat,data.long);
    Placemark placeMark = myplacemark[0];
    String name = myplacemark[0].thoroughfare.toString();
    String locality = placeMark.locality;
    data.userplace = "${name}, ${locality}";
    print(data.userplace);
  }

  @override
  void dispose() {
    textController.dispose();
    idTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Logo and start messages
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
        Padding(
          padding: const EdgeInsets.only(left: 33.0, right: 33.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: FlatButton(
                  onPressed: () {
                    saveMyLocation();
                    if (textController.text != "") {
                      name = textController.text;
                      data.username = name;
                      Navigator.push(context,MaterialPageRoute(builder: (context) => MeetingType(data : data)),);
//                      dispose();
                    } else {
                      name = "Host";
                      data.username = name;
                      Navigator.push(context,MaterialPageRoute(builder: (context) => MeetingType(data : data)),);
//                      Scaffold.of(context).showSnackBar(
//                          SnackBar(
//                            content: Text("Please enter your username!"),
//                            duration: Duration(seconds: 2),
//                          ));
                    }},
                  child: _buildButtonColumn(Colors.black, Icons.arrow_right, 'Get Started!'),
                  color: Colors.amber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 33.0, right: 33.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FlatButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          if (textController.text != "") {
                            name = textController.text;
                            return _buildEnterID(name);
                          } else {
                            name = "Anonymouse";
                            return _buildEnterID(name);
                          }
                        }
                    );
                  },
                  child: _buildButtonColumn(Colors.black, Icons.add, 'Join Meetup'),
                  color: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 3, right: 3),
                child: Text(""),
              ),
              Expanded(
                  child: FlatButton(
                    onPressed: () {
                      if (textController.text != "") {
                        Navigator.push(context,MaterialPageRoute(builder: (context) => ShareLinkPage(data : data)),);
//                      dispose();
                      } else {
                        Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text("There is no ongoing session!"),
                              duration: Duration(seconds: 2),
                            ));
                      }},
                    child: _buildButtonColumn(Colors.black, Icons.autorenew, 'My Meetup'),
                    color: Colors.lightBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  )
              )
            ],
          ),
        ),
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
                    hintText: "Name (Optional)"
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
//      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.9,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        Icon(icon, color: color),
      ],
    );
  }

  //Helper method to build AlertDialog for entering Session ID
  AlertDialog _buildEnterID(String name) {
    return AlertDialog(
      title: Text("Paste Link"),
      content: Row(
        children: <Widget>[
          Expanded(
              child: Form(
                key: formKey,
                child: TextFormField(
                  controller: idTextController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Session Link"
                  ),
                  onChanged: (value) {
                    sessionlink = value;
                  },
                  validator: (value) {
                    if (value.isEmpty || invalidLink){
                      return "Invalid Link";
                    }
                    return null;
                  },
                ),
              )
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Join!"),
          onPressed: () async {
            String checkingLink = sessionlink.replaceAll(new RegExp(r'/get_details'), '');
            print(checkingLink);
            http.Response response = await http.get(checkingLink);
            await Future.delayed(Duration(milliseconds: 400));
            String body = response.body;
            Map<String, dynamic> DatajsonVersion = jsonDecode(body); //parse the data from server into a map<string,dynamic>

            if (DatajsonVersion.containsKey("error")) {invalidLink = true;}

            if (formKey.currentState.validate() && !invalidLink) {

              data.username = name;
              data.link = sessionlink;
              data.sessionid = data.linkParser(sessionlink);
              print("TEST: ${data.dataMap}");

              Navigator.push(context,MaterialPageRoute(builder: (context) => CustomizationPage(data : data)),);

            } else {
              print("Validate: ${formKey.currentState.validate()}");
            }
          },
        )
      ],
    );
  }


}