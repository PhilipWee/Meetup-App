// results_display

const xhr = new XMLHttpRequest();
var host_address_port = location.protocol+'//'+location.hostname+(location.port ? ':'+location.port: '')
var session_id = window.location.pathname.split('/')[2]
const url = host_address_port + '/session/' + session_id + '/results';
xhr.open("GET", url);
xhr.send();
xhr.onreadystatechange = (e) => {
  if (xhr.readyState == 4) {
    result = xhr.responseText
    result = JSON.parse(result)
    var list_of_restaurant_names = result['possible_locations']
    for (i in list_of_restaurant_names) (function(i){
      // debugger
      btn = document.createElement("BUTTON");
      btn.innerHTML = String(list_of_restaurant_names[i]);
      btn.id = "location_modifier" + String(list_of_restaurant_names[i])
      // btn.addEventListener('click', function(i) {return {location_modifier}(i)});
      btn.onclick = function() {
        location_modifier(list_of_restaurant_names[i])
      }
      // btn.onclick = function() {
      //   location_modifier(btn.innerHTML)
      // }
      // console.log(btn_arr[i])
      document.getElementById('buttons_div').appendChild(btn)
      // console.log(btn_arr[i])
      // document.getElementById(btn_arr[i].id).onclick = function() {
      //   location_modifier(btn_arr[i].innerHTML)
      //   console.log('yaaaaaaaaaa')
      //   console.log(btn_arr[i].innerHTML)
      // }
      })(i);

      // MADE CHANGES
      //retrieveUsers();
      var checkHost = document.getElementById('checkIfHost').textContent;
      if (displayCalculateButton(checkHost) == true) {
        calcButton = document.createElement("BUTTON");
        calcButton.innerHTML = "Everyone's here, Calculate Results!";
        calcButton.onclick = "calculateButton()";

        document.getElementById('calculateButton_div').appendChild(calcButton);
      }

    //var y;
    // for (y in list_of_restaurant_names) {
    //   var btn = document.createElement("BUTTON");
    //   btn.innerHTML = String(list_of_restaurant_names[y]);
    //   btn.id = "location_modifier" + String(list_of_restaurant_names[y])
    //   document.getElementById('buttons_div').appendChild(btn)
    //   document.getElementById(btn.id).addEventListener("click", function () {
    //     location_modifier(), false
    //   });}

    // MADE CHANGES START
    function retrieveUsers() {
      jQuery.getJSON(
          host_address_port + '/session/' + session_id,
          function (data) {
            var allUsers = data["users"];
            for (i in allUsers) {
              console.log(allUsers[i]);

            }
          })
    }

    function displayCalculateButton(check_host) {
      if (check_host == 'True') {
        return true;
      } else {
        return false;
      }
    }

    function calculateButton() {
      window.location.href = session_id + "/calculate";
    }
    // MADE CHANGES END

    function location_modifier(location_name) {
      console.log(location_name)

      path_arr = []
      Object.entries((result[String(location_name)])).forEach(([key, value]) => {
//        console.log(key)
//        console.log(value)
//        console.log(value['latitude'])
//        console.log(value['longtitude'])
        var path = [];
        for (var i = 0; i < value['latitude'].length; i++) {
          path.push(new google.maps.LatLng(value['latitude'][i], value['longtitude'][i]));
        }
        path_arr.push(path)
      })



      var map;

      function initialize() {
        var map = new google.maps.Map(document.getElementById("map"), {
          zoom: 12,
          center: path_arr[0][path_arr[0].length - 1]
        })

        mapTypeId: google.maps.MapTypeId.ROADMAP

        color = ["#FF0000", "#0000FF"]



        var z;
        for (z in path_arr) {
        var starting_markers = new google.maps.Marker({ position: path_arr[z][0], map: map})};

        var destination_marker = new google.maps.Marker({ position: path_arr[0][path_arr[0].length - 1], map: map})

 //       console.log(path_arr)
        var i = 0;
        for (x of path_arr) {
//          console.log(x)
          var line = new google.maps.Polyline({
            path: x,
            strokeColor: color[i],
            strokeOpacity: 1.0,
            strokeWeight: 3,
            geodesic: true,
            map: map

          })

          i++;
        };

      };
      initialize()
    }




    //google.maps.event.addDomListener(window, 'load', initialize);//

  }
}


function jayson() {
$(document).ready(function(){

    $.getJSON(host_address_port + '/session/' + session_id, function(data) {

      var allUsers = data["users"];
      for (i in allUsers) {
        console.log(Object.keys(allUsers[i]));
        user_details = Object.keys(allUsers[i])

if (user_details.includes('identifier')) {

  user = document.createElement("div")
  user.class = 'row'
  user.id = 'row_num'
  // document.body.appendChild(user)

  user.append((String(allUsers[i]['identifier'] + ', the mouse is travelling by ')))
  user.append(' ' + (String(allUsers[i]['transport_mode'] + '. . . . . . . . . . . . . . . . . . . ')))
  }
else {
  user = document.createElement("div")
  user.class = 'row'
  user.id = 'row_num'
  user.append((String(allUsers[i]['username'] + ', the host mouse is travelling by ')))
  user.append(' ' + (String(allUsers[i]['transport_mode'] + '. . . . . . . . . . . . . . . . . . . ')))


  }
  $('#map').append(user)

          }
})})}
