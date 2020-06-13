
//get details
var host_address_port = location.protocol+'//'+location.hostname+(location.port ? ':'+location.port: '')
//Get the session id from the pathname
var session_id = window.location.pathname.split('/')[2]


navigator.geolocation.getCurrentPosition(success, error, options);
console.log('geolocation works')


// Scipt for price preference slider
var values = ['No Preference', '$', '$$', '$$$', '$$$$'];
$('#pricePreference').change(function() {
    $('#priceValue').text(values[this.value]);
});

function success(pos) {
    var crd = pos.coords;
    lat = crd.latitude;
    long = crd.longitude;
    $('#lat').val(lat);
    $('#long').val(long);
    LatLng = new google.maps.LatLng(lat, long);
    map.setCenter(LatLng);
};





function error(err) {
    console.warn('ERROR(' + err.code + '): ' + err.message);
};

var options = {
    enableHighAccuracy: true,
    timeout: 5000,
    maximumAge: 0
};

function objectifyForm(formArray) { //serialize data function

  var returnArray = {};
  for (var i = 0; i < formArray.length; i++){
    returnArray[formArray[i]['name']] = formArray[i]['value'];
  }
  return returnArray;
}

function homeButton() {
  var base_url = window.location.origin;
  location.replace(base_url);
}

function submitButton() {

    meetupForm = $('#meetupData')
    meetupData = objectifyForm(meetupForm.serializeArray());;
    console.log(meetupData);

    var metrics = {"speed":parseInt(meetupData['speed']), "quality":parseInt(meetupData['quality']), "price":parseInt(meetupData['price'])}
    delete meetupData.speed;
    delete meetupData.quality;
    delete meetupData.price;
    meetupData["metrics"] = metrics;
    meetupData["lat"] = parseFloat(meetupData["lat"]);
    meetupData["long"] = parseFloat(meetupData["long"]);
    meetupData["user_place"] = "Singapore";
    meetupData["uuid"] = uid;
    if (isAnonymous == false) {
      meetupData["username"] = username;
    }

    console.log(meetupData);
    if ($('#lat').val() == '') {
        alert("Please use the map to select your location!")
    } else {
        newFunction();
    }
    function newFunction() {

        $.ajax({
            type: 'POST',
            url: host_address_port + '/session/' + session_id,
            data: JSON.stringify(meetupData),
            contentType:'application/json',
            success: function (response_data) {
                //console.log("Everything looks good!")
                window.location.href= 'results_display?isHost=false' //form submission
            },
            error: function(response_data) {
              console.log(response_data['responseText']);
            }
        })


    }

  };

document.getElementById ("submitbutton").addEventListener ("click", submitButton);
document.getElementById ("homeButton").addEventListener ("click", homeButton);
