import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'main.dart';
import 'Globals.dart' as globals;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

//  final FirebaseAuth _auth = FirebaseAuth.instance;
//  final GoogleSignIn googleSignIn = GoogleSignIn();

  /////////////////////////////////////////////////////////////////////// [FUNCTIONS]
  @override
  void initState(){
    super.initState();
    try{globals.auth.currentUser().then((user) => userExists(user));}
    catch(error){print("there is some weird error");}
  }
  successfulCallBack(string){
    if(string==null){
      throw PlatformException;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return CheckNetworkPage();
        },
      ),
    );
  }
  void userExists(user){
    if(user==null) {
      print("user doesn't exist");
    }
    else {
      globals.uuid = user.uid;
      globals.username = user.displayName;
      globals.profileurl = user.photoUrl;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return CheckNetworkPage();
          },
        ),
      );
    }
  }
  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Whoops! Something went wrong."),
          content: new Text("Please try logging in with Google Sign In again."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount = await globals.googleSignIn
          .signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final FirebaseUser user = (await globals.auth.signInWithCredential(
          credential)).user;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await globals.auth.currentUser();
      assert(user.uid == currentUser.uid);
      globals.uuid = user.uid;
      globals.username = user.displayName;
      globals.profileurl = user.photoUrl;
      print('this is complete');
      return ('this is complete');
    } on PlatformException catch (error){
      throw(error);
    }
  }

  /////////////////////////////////////////////////////////////////////// [WIDGETS]

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromRGBO(247, 147, 30, 1),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage("images/app_logo.png"), height: 350),
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
        signInWithGoogle().then((value)=>this.successfulCallBack(value)).catchError((error) =>{
          this._showDialog()
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