var host_address_port = location.protocol+'//'+location.hostname+(location.port ? ':'+location.port: '')

function getLocation() {
    navigator.geolocation.getCurrentPosition(success, error, options);
    console.log('test')
    
};

function success(pos) {
    var crd = pos.coords;
    lat = crd.latitude;
    lng = crd.longitude;
    $('#lat').val(lat);
    $('#lng').val(lng);
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
    var latituder = document.getElementById('lat').value;
    var longituder = document.getElementById('lng').value;
    meetupForm = $('#meetupData')
    meetupData = meetupForm.serializeArray()
    console.log(meetupData)
    newFunction(); //form submission
    function newFunction() {
        $.ajax({
            type: 'POST',
            url: host_address_port + '/session/123456',
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