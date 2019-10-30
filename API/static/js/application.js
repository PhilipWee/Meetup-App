const xhr = new XMLHttpRequest();
const url = 'http://127.0.0.1:5000/session/123456/results';
xhr.open("GET", url);
xhr.send();
xhr.onreadystatechange = (e) => {
  //  console.log(Http.responseText)
 // result = xhr.responseText
  if (xhr.readyState == 4) {
    result = xhr.responseText
    result = JSON.parse(result)
    var list_of_restaurant_names = result['possible_locations']
    for (i in list_of_restaurant_names) (function(i){
      // debugger
      btn = document.createElement("BUTTON")
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
    //var y;
    // for (y in list_of_restaurant_names) {
    //   var btn = document.createElement("BUTTON");              
    //   btn.innerHTML = String(list_of_restaurant_names[y]);       
    //   btn.id = "location_modifier" + String(list_of_restaurant_names[y])
    //   document.getElementById('buttons_div').appendChild(btn)
    //   document.getElementById(btn.id).addEventListener("click", function () {
    //     location_modifier(), false
    //   });}
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