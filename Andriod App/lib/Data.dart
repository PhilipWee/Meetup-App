
class PrefData {
  String username;
  String activityType;
  double lat;
  double long;
  String link;
  String transportMode;
  int speed;
  int quality;
  String sessionid;
  int price;
  String userplace;

  //PrefData Constructor
  PrefData({this.username,this.transportMode, this.quality, this.speed, this.link,
    this.lat, this.long, this.activityType,this.sessionid,this.price,this.userplace});

  Map<String,dynamic> get dataMap {
    return {
      "sessionid" : sessionid,
      "link" : link,
      "username" : username,
      "userplace" : userplace,
      "lat" : lat,
      "long" : long,
      "transportMode" : transportMode,
      "speed" : speed,
      "quality" : quality,
      "price" : price,
    };
  }

  String linkParser (String link) {
    List<String> linkList = link.split("/");
    print(linkList);
    return linkList[4];
  }

}

