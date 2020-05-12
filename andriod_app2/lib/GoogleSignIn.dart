import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'main.dart';
import 'Globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

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

    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    print("user " + user.uid + " is connected to firebase.");
    globals.uuid = user.uid;

    try {
      QuerySnapshot docs = await Firestore.instance.collection('userData').where('uid',isEqualTo: user.uid).getDocuments();
      if (!docs.documents[0].exists){
        Firestore.instance.collection('userData').document(user.uid).setData({
          'activityType': 'activityType',
          'lat': 0.0,
          'long': 0.0,
          'link': 'link',
          'price': 0,
          'quality': 'No Preference',
          'sessionId': "ABCDE",
          'transportMode': 'Public Transit',
          'userName': user.displayName,
          'uid': user.uid
        }).whenComplete(() =>
            print("created userData for " + user.displayName));
      }
      else{
        print("userData already exists.");

      }
    }on PlatformException{
      print("userData already exists.");
    }


    return 'signInWithGoogle succeeded: $user';

  }
  void signOutGoogle() async{
    await googleSignIn.signOut();
    print("User Sign Out");
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
        globals.saveMyLocationName();
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