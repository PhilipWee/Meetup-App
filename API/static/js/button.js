var host_address_port = location.protocol+'//'+location.hostname+(location.port ? ':'+location.port: '')
//Get the session id from the pathname
var session_id = window.location.pathname.split('/')[2]


    navigator.geolocation.getCurrentPosition(success, error, options);
    console.log('test')
    


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


function submitButton() {
    meetupForm = $('#meetupData')
    meetupData = meetupForm.serializeArray()
    if ($('#lat').val() == '') {
        alert("Please drag the map to select your location!")
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
                console.log("running redirect")
    window.location.href='results_display' //form submission
            }          
        })
        
    }





  };
  
  document.getElementById ("submitbutton").addEventListener ("click", submitButton);
  
