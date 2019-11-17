var host_address_port = location.protocol+'//'+location.hostname+(location.port ? ':'+location.port: '')
//Get the session id from the pathname
var session_id = window.location.pathname.split('/')[2]

function getLocation() {
    navigator.geolocation.getCurrentPosition(success, error, options);
    console.log('test')
    
};

function success(pos) {
    var crd = pos.coords;
    lat = crd.latitude;
    long = crd.longitude;
    $('#lat').val(lat);
    $('#long').val(long);
    LatLng = new google.maps.LatLng(crd.latitude, crd.longitude);
    map.setCenter(LatLng);
};

document.getElementById ("getlocation").addEventListener ("click", getLocation);



function error(err) {
    console.warn('ERROR(' + err.code + '): ' + err.message);
};

var options = {
    enableHighAccuracy: true,
    timeout: 5000,
    maximumAge: 0
};


function submitButton() {
    meetupForm = $('#meetupData')
    meetupData = meetupForm.serializeArray()
    if ($('#lat').val() == '') {
        alert("Please drag the map to select your location!")
    } else {
        newFunction(); //form submission
    }
    function newFunction() {
        $.ajax({
            type: 'POST',
            url: host_address_port + '/session/' + session_id,
            data: JSON.stringify(meetupData),
            contentType:'application/json',
            success: function (response_data) {
                alert("success");
            }          
        })
    }
};

document.getElementById ("submitbutton").addEventListener ("click", submitButton);

function redirect() {
    console.log("running redirect")
    window.location.href='results_display'
  };
  
  
  
  document.getElementById ("redirect").addEventListener ("click", redirect)