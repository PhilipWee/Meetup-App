library meetupmouse.globals;
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'socketiohelper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth auth = FirebaseAuth.instance;

CustomSocketIO socketIO = CustomSocketIO(serverAddress);

//String serverAddress = "http://ec2-3-14-68-232.us-east-2.compute.amazonaws.com:5000";
//String serverAddress = "http://3.23.239.59:5000";
String serverAddress = "http://meetup-mouse.com:5000";

String uuid = "defaultUser";
String username = "defaultName";
String profileurl = "https://upload-icon.s3.us-east-2.amazonaws.com/uploads/icons/png/19339625881548233621-512.png";

String userLocationName = "defaultLocation";

bool isCreator = false;

Map<String, dynamic> tempMeetingDetails = {"meetup_name": "meetup_name", "meeting_type":"meeting_type"};

List<String> custLabels = [];
List<String> custImgs = [];
List<String> custStates = [];
List<String> sessionIDs = [];
List allData = [];

Map sessionData = {};
String sessionIdCarrier = "";
String sessionUrlCarrier = "";

///SESSION DATA SAMPLE
//{
//  host_uuid: NgBZTpHmO3X4xvm4msmMtku0wLz2,
//  meeting_type: outing,
//  meetup_name: ,
//  session_status: pending_members,
//  time_created: 2020-05-13 08:05:03.486923,
//  users: [
//    {
//    lat: 0.0,
//    long: 0.0,
//    metrics: {price: 0, quality: 1, speed: 0},
//    transport_mode: public,
//    user_place: Jalan Membina, Singapore,
//    username: defaultName,
//    uuid: NgBZTpHmO3X4xvm4msmMtku0wLz2
//    }
//  ]
//  sessionid : 12345678
//}

Map<String,dynamic> tempData = {

  "meetupname" : "Default Name",
  "meetingtype": "outing",
  "lat" : 0.0,
  "long" : 0.0,
  "username" : "",
  "userplace" : "",
  "transportmode" : "public",
  "quality" : 1,
  "price" : 1,
  "sessionid" : 01234567,
  "link" : "LinkNotUpdated",
  "joinlink": "",

//  "speed" :0,
}; ///////////////////////////////////////////////////////////////////////////////////////////////////////tempDATA


void resetempData() {
  tempData = {

    "meetupname" : "Default Name",

    "meetingtype": "outing",

    "lat" : 0.0,
    "long" : 0.0,
    "user_place" : "",

    "transportmode" : "public",
    "quality" : 1,
    "price" : 0,

    "sessionid" : 01234567,
    "link" : "CreationLinkNotUpdated",
    "joinlink": "JoinLinkNotUpdated",

//    "speed" :0, //not used anymore but just send anyway
  };
  print("tempData cache cleared!");
}

void saveMyLocationName() async{
  var location = Location();
  LocationData currentLocation = await location.getLocation();

  tempData["lat"] = currentLocation.latitude;
  tempData["long"] = currentLocation.longitude;
  print("Current Coordinates: ${tempData["lat"]},${tempData["long"]}");

  List<Placemark> myplacemark = await Geolocator().placemarkFromCoordinates(tempData["lat"],tempData["long"]);
  Placemark placeMark = myplacemark[0];
  String name = myplacemark[0].thoroughfare.toString();
  String locality = placeMark.locality;
  String myLocationName = "$name, $locality";
  print("Current Location $myLocationName." );

  userLocationName = myLocationName;
}

Future<String> getplacefromlatlong(double givenlat, double givenlong) async{
//  var location = Location();
//  LocationData currentLocation = await location.getLocation();
  double lat = givenlat;
  double long = givenlong;
  print("Member Coordinates: $lat,$long");
  List<Placemark> myplacemark = await Geolocator().placemarkFromCoordinates(lat,long);
  Placemark placeMark = myplacemark[0];
  String name = myplacemark[0].thoroughfare.toString();
  String locality = placeMark.locality;
  String memberLocationName = "$name, $locality";
  print("Member Location $memberLocationName." );
  return memberLocationName;
}

FakeData confirmedDetails;

class FakeData {
  String name;
  String address;
  String details;
  double rating;
  List images;

  FakeData({this.name, this.address, this.details, this.rating, this.images});

  Map<String,dynamic> get dataMap {
    return {
      "name" : name,
      "address" : address,
      "details" : details,
      "rating" : rating,
      "images" : images,
    };
  }
} //for swipe page

FakeData locationDetails = FakeData(
    name: "Fisherman's Wharf",
    address: "39 San Francisco Bay Area",
    details: "Fisherman's Wharf @ Pier 39, where you can find the most delicious clam chowder! Visit the old-fashioned arcade with only mechanical games while you are there as well!",
    rating: 4.6,
    images: ["https://irepo.primecp.com/2015/07/230563/Fishermans-Wharf-Clam-Chowder_ExtraLarge1000_ID-1117267.jpg?v=1117267",
      "https://cdn.britannica.com/13/77413-050-95217C0B/Golden-Gate-Bridge-San-Francisco.jpg",
      "https://www.mercurynews.com/wp-content/uploads/2018/10/SJM-L-WEEKENDER-1018-01.jpg",]);


//List swipeData = [
//  globals.fakeData(name: "",
//      address: "",
//      details: "Delicious burgers made by a sponge",
//      rating: 3.0,
//      images: ["https://marcusgohmarcusgoh.com/wp/wp-content/uploads/2017/03/GE-Maths00003.jpg",
//        "https://media.tenor.com/images/efb52cc0e4b02ac8c5d0d71e659df8f4/tenor.png",]),
//  globals.fakeData(name: "Singapore Zoo",
//      address: "123 Mandai Rd",
//      details: "Dining for the wild, experience what it's like to be the prey",
//      rating: 3.2,
//      images: ["https://blog.headout.com/wp-content/uploads/2018/10/Singapore-Zoo-Breakfast-With-Orangutans-e1539864638230-1200x900.jpg",
//        "https://pix10.agoda.net/hotelImages/9643334/-1/8a2bfba69eb9d639885182e5cc9e6c07.jpg"]),
//  globals.fakeData(name: "Chez Platypus",
//      address: "33 Tri-state Area Ave 1",
//      details: "MOM! Phineas and Ferb are running a restaurant!",
//      rating: 4.3,
//      images: ["https://vignette.wikia.nocookie.net/phineasandferb/images/0/0d/Chez_Platypus.jpg/revision/latest?cb=20090717044333",
//        "https://vignette.wikia.nocookie.net/phineasandferb/images/f/fd/Romance_at_last.jpg/revision/latest?cb=20120701091616"]),
//  globals.fakeData(name: "Fisherman's Wharf",
//      address: "39 San Francisco Bay Area",
//      details: "Fisherman's Wharf @ Pier 39, where you can find the most delicious clam chowder! Visit the old-fashioned arcade with only mechanical games while you are there as well!",
//      rating: 4.6,
//      images: ["https://irepo.primecp.com/2015/07/230563/Fishermans-Wharf-Clam-Chowder_ExtraLarge1000_ID-1117267.jpg?v=1117267",
//        "https://cdn.britannica.com/13/77413-050-95217C0B/Golden-Gate-Bridge-San-Francisco.jpg",
//        "https://www.mercurynews.com/wp-content/uploads/2018/10/SJM-L-WEEKENDER-1018-01.jpg",]),
//];

//List fakelistofmembers = [
//  {
//    "username" : "identifier",
//    "lat" : 0,
//    "long" : 0,
//    "transport_mode" : "driving",
//    "metrics" : {"speed":0, "quality":0, "price":0}
//  },
//  {
//    "username" : "Julia Chua",
//    "lat" : 1.332319,
//    "long" : 103.672113,
//    "transport_mode" : "Driving",
//    "metrics" : {"speed":0, "quality":0, "price":0}
//  },
//  {
//    "username" : "David Fan",
//    "lat" : 1.332319,
//    "long" : 103.672113,
//    "transport_mode" : "Driving",
//    "metrics" : {"speed":0, "quality":0, "price":0}
//  },
//];