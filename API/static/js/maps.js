var map;
function initMap() {

    // 1.287828, 103.865900
     myLatLng = { lat: 1.587828, lng: 104.865900 }; //first position
     map = new google.maps.Map(document.getElementById('basicMap'), {
        center: myLatLng,
        zoom: 15})
        map.addListener('center_changed', function () {
           lat = map.getCenter().lat();
           long = map.getCenter().lng();
           $("#lat").val(lat);
           $("#long").val(long);
       });





     var defaultBounds = new google.maps.LatLngBounds(
        new google.maps.LatLng(1.233409,103.618691),
        new google.maps.LatLng(1.433855,104.063637));

     var options = {
         bounds: defaultBounds
     };

     var input = document.getElementById('pac-input');
     var autocomplete = new google.maps.places.Autocomplete(input, options
       );

		var marker = new google.maps.Marker({
			map : map
		});

    onPlacesChanged = function() {
        var places = autocomplete.getPlace();

    if (places.geometry) {
        map.panTo(places.geometry.location);
        //console.log('location changed! search bar works')
    }

         }

     autocomplete.addListener('place_changed', onPlacesChanged);

}
