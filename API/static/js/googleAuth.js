class Auth {
    constructor() {

        // Initialize Firebase
        this.firebaseConfig = {
            apiKey: "AIzaSyAJ__NSxJn-qEqWrHAVnH1duusK1rJPqx4",
            authDomain: "meetup-mouse-265200.firebaseapp.com",
            databaseURL: "https://meetup-mouse-265200.firebaseio.com",
            projectId: "meetup-mouse-265200",
            storageBucket: "meetup-mouse-265200.appspot.com",
            messagingSenderId: "1052519191030",
            appId: "1:1052519191030:web:90909ba515c20d766377d7",
            measurementId: "G-FP46EYMK63"
        };
        
        firebase.initializeApp(this.firebaseConfig);
        //firebase.analytics();
        console.log("Firebase initialized!");

        //Check if the user is signed in
        firebase.auth().onAuthStateChanged(function(user) {
            if (user) {
              var isAnonymous = user.isAnonymous;
              if (isAnonymous) {
                // Create sign in button
                var btn = document.createElement("BUTTON");
                btn.style = 'font-family: Patrick Hand SC;font-size:2vw;margin-left:45%';
                btn.onclick = function() {
                  // Redirect to correct page; Pending users, Pending swipes or Confirmed
                  window.location.href = '/loginPage';
                }
                btn.innerHTML = "Sign In";
                document.getElementById('loginStatusButton').appendChild(btn);
              } else {
                // Create sign out button
                var btn = document.createElement("BUTTON");
                btn.style = 'font-family: Patrick Hand SC;font-size:2vw;margin-left:45%';
                btn.onclick = function() {
                  firebase.auth().signOut().then(function() {
                    console.log("Signed out")
                    // Sign-out successful.
                  }).catch(function(error) {
                    // An error happened.
                  });
                  window.location.reload(true);
                }
                btn.innerHTML = "Sign Out";
                document.getElementById('loginStatusButton').appendChild(btn);
              }
            } else {
                firebase.auth().signInAnonymously().catch(function(error) {
                  // Handle Errors here.
                  var errorCode = error.code;
                  var errorMessage = error.message;
                  // ...
                });
            }
          });
    }
}

let auth = new Auth()