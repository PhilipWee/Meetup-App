var map;
function initMap() {
    // 1.287828, 103.865900
    myLatLng = { lat: 1.287828, lng: 103.865900 }; //first position
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