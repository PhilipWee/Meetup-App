import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'main.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'Globals.dart' as globals;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final FirebaseUser user = (await _auth.signInWithCredential(credential));

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded: $user';

  }
  void signOutGoogle() async{
    await googleSignIn.signOut();
    print("User Sign Out");
  }

  void saveMyLocationName() async{
    var location = Location();
    LocationData currentLocation = await location.getLocation();
    double mylat = currentLocation.latitude;
    double mylong = currentLocation.longitude;
    print("User's Current Coordinates: ${mylat},${mylong}");
    Map<String,double> mycoordinates = {"mylat":mylat, "mylong":mylong};
    List<Placemark> myplacemark = await Geolocator().placemarkFromCoordinates(mylat,mylong);
    Placemark placeMark = myplacemark[0];
    String name = myplacemark[0].thoroughfare.toString();
    String locality = placeMark.locality;
    String myLocationName = "${name}, ${locality}";
    print("User's Current Location ${myLocationName}." );
    globals.myLocationName = myLocationName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.deepOrange,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage("images/Mouse_copy.png"), height: 170),
              SizedBox(height: 50),
              _signInButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInButton() {
    return FlatButton(
      color: Colors.white,
      onPressed: () async {
        saveMyLocationName();
        signInWithGoogle().whenComplete(() {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) {
                return CheckNetworkPage();
              },
            ),
          );
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
//      highlightElevation: 0,
//      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("images/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black45
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}