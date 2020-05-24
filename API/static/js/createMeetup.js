

var host_address_port = location.protocol+'//'+location.hostname+(location.port ? ':'+location.port: '');
//var session_id = window.location.pathname.split('/')[2]

navigator.geolocation.getCurrentPosition(success, error, options);

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
      LatLng = new google.maps.LatLng(crd.latitude, crd.longitude);
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

function objectifyForm(formArray) {//serialize data function

  var returnArray = {};
  for (var i = 0; i < formArray.length; i++){
    returnArray[formArray[i]['name']] = formArray[i]['value'];
  }
  return returnArray;
}

function submitbutton() {
  meetupForm = $('#createMeetup')
  //console.log(meetupForm);
  meetupData = objectifyForm(meetupForm.serializeArray());
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
  if (meetupData["meeting_type"] == "") {
    alert("Please choose the purpose of your meetup!");
  } else {
      if ($('#lat').val() == '') {
          alert("Please drag the map to select your location!");
      } else {
          newFunction();
      }
      function newFunction() {
          $.ajax({
              type: 'POST',
              url: host_address_port + '/session/create',
              data: JSON.stringify(meetupData),
              contentType:'application/json',
              success: function (response_data) {
                  console.log("Everything looks good!")
                  response = response_data['session_id'];
                  window.session_id = response;
                  document.getElementById('shareLink').value = host_address_port + '/session/' + response + '/get_details';
                  //window.location.href='results_display' //form submission
              },
              error: function(response_data) {
                console.log(response_data['responseText']);
              }
          })

          //console.log(JSON.stringify(meetupData));
        }
    }
}


  function copyLinkFunction() {
    /* Get the text field */
    var copyText = document.getElementById('shareLink');

    /* Select the text field */
    copyText.select();
    copyText.setSelectionRange(0, 99999); /* For mobile devices */

    /* Copy the text inside the field */
    document.execCommand("copy");

    /* Alert for the copied text */
    alert("Text copied to clipboard");
  }

  function createMeetupButton() {
    link = document.getElementById('shareLink').value;
    if (link == "") {
      alert("Click on submit to generate a shareable link first.");
    } else {
      window.location.href = window.session_id + '/results_display' + '?isHost=true';
    }
  }

function myFunction() {
  console.log('hello world')
  location.replace("https://www.w3schools.com")
}

document.getElementById ("submitbutton").addEventListener ("click", submitbutton);
