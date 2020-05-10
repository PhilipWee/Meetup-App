library meetupmouse.globals;
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

String serverAddress = "http://ec2-3-14-68-232.us-east-2.compute.amazonaws.com:5000";

String userLocationName = "";

Map<String,dynamic> tempData = {
  "meetupname" : "",
  "meetingType": 0,
  "sessionid" : 0,
  "link" : "",
  "username" : "",
  "userplace" : "",
  "lat" : 0.0,
  "long" : 0.0,
  "transportMode" : "",
  "quality" : 0,
  "price" : 0,
};

Map<String,dynamic> userGoogleData = {
  "name" : 0,
};

void saveMyLocationName() async{
  var location = Location();
  LocationData currentLocation = await location.getLocation();
  double mylat = currentLocation.latitude;
  double mylong = currentLocation.longitude;
  print("User's Current Coordinates: $mylat,$mylong");
//  Map<String,double> mycoordinates = {"mylat":mylat, "mylong":mylong};
  List<Placemark> myplacemark = await Geolocator().placemarkFromCoordinates(mylat,mylong);
  Placemark placeMark = myplacemark[0];
  String name = myplacemark[0].thoroughfare.toString();
  String locality = placeMark.locality;
  String myLocationName = "$name, $locality";
  print("User's Current Location $myLocationName." );
  userLocationName = myLocationName;
}