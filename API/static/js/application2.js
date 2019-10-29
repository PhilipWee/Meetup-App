console.log('test1')


function submitButton() {
    var latituder = document.getElementById('lat').value;
    var longituder = document.getElementById('lng').value;
    meetupForm = $('#meetupData')
    meetupData = meetupForm.serializeArray()
    console.log(meetupData)
    newFunction(); //form submission
    alert("Form Submitted Successfully!")
    function newFunction() {
        $.ajax({
            type: 'POST',
            url: '127.0.0.1:5000',
            data: JSON.stringify(meetupData),
            contentType: 'application/json',
            success: function (response_data) {
                alert("success");
            }
        })
    };

    var map;
    function initMap() {
        myLatLng = { lat: 1.37, lng: 103.8 }; //first position
        map = new google.maps.Map(document.getElementById('basicMap'), {
            center: myLatLng,
            zoom: 14
        });
        map.addListener('center_changed', function () {
            lat = map.getCenter().lat();
            lng = map.getCenter().lng();
            $("#lat").val(lat);
            $("#lng").val(lng);
        });
    }
}