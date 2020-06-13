session_id = window.location.pathname.split('/')[2]
base_url = window.location.origin;

document.getElementById("homeButton").addEventListener("click", homeButton);

//Get the current session details
var details_url = base_url + '/session/' + session_id;
var results_url = base_url + '/session/' + session_id + '/results';
document.getElementById('shareLink').value = details_url + '/get_details';

var host_uuid;

// Get Host UID
$.getJSON(details_url, function (result){
  display_meetup_details(result);
}).catch(function (error) {
  console.log('Unable to get meetup details, Error: ' + error)
})

var getParams = function (url) {
    var params = {};
    var parser = document.createElement('a');
    parser.href = url;
    var query = parser.search.substring(1);
    var vars = query.split('&');
    for (var i = 0; i < vars.length; i++) {
        var pair = vars[i].split('=');
        params[pair[0]] = decodeURIComponent(pair[1]);
    }
    return params;
};

var isHost = getParams(window.location.href)['isHost']
$(document).ready(function () {
    if (isHost == 'true') {
        //unhide the calculation button
        $('#calculation_button').show()
    } else {
        $('#calculation_button').hide()
    }
})


// Get the location data for the particular session id
$.getJSON(details_url, function (results) {
    generate_page(results)
}).catch(function (error) {
    console.log('Unable to get details, Error: ' + error)
})

function generate_page(results) {
    //Check if the location has been decided
    console.log(results)
    var session_status = results['session_status']
    results['users'].forEach(function (user) {
        add_user_to_list(user)
    })
    confirmed_place_index = results['confirmed_place_index']
    if (session_status == "pending_members") {

    } else if (session_status == "location_confirmed"){
        //unhide the location
        display_location_details(confirmed_place_index);
    }
}

function display_meetup_details(result) {
    host_uuid = result['host_uuid'];
    var meetup_title = document.getElementById("meetup_title");
    meetup_title.innerHTML = result['meetup_name'];
  }

function display_location_details(confirmed_place_index){
    $.getJSON(results_url, function (results) {
        location_name = results['possible_locations'][confirmed_place_index]
        location_details = results[location_name]
        console.log(location_details)

        var img_url = location_details['pictures'][0]
        var rating = location_details['rating']
        var address = location_details['address']
		rating = rating == 'nan' ? 3 : parseFloat(rating)
		// var price = location_details['price']
		// price = price == 'nan' ? 'Unknown' : price
		// var writeup = location_details['writeup']
        //Update the image
        $('#location_image').attr('src',img_url)
		//Update the location name
		$('#location_name').text(location_name)
		//Update the number of stars
		const starTotal = 5;
		const starPercentage = (rating / starTotal) * 100;
		const starPercentageRounded = `${(Math.round(starPercentage / 10) * 10)}%`;
		document.querySelector(`.stars-inner`).style.width = starPercentageRounded;
		//Update the price
		// $('#price_div').text(price)
		//Update the writeup
        // $('#writeup_div').text(writeup)
        //Update the address
        $('#address').text(address);

        $('#location_details_div').show()
    }).catch(function (error) {
        console.log('Unable to get details, Error: ' + error)
    })
}

function add_user_to_list(user) {
    let user_place = user['user_place'];
    let username = user['username'];
    let uuid = user['uuid'];

    if (uuid == host_uuid) {
      $('#user_details_div').append(`
          <div class='row'
          style='font-family: Patrick Hand SC; margin-top:1%;margin-left:2%;margin-right:2%;background-color: #FFFBF5;border-radius: 15px;'>

          <div class='col col-2'>
          <img style="height:100%;width:100%;margin-top:2%;" align=left src="/static/host-purple.png" alt="Avatar">
          </div>
          <div class='col' style='justify-content:left;align-items:left;' align=left>
          <p style='margin-top:2%;font-size: 1.5vw;justify-content:left;align-items:left;'>${user_place}</p>
          <p>${username}</p>
          </div>
          <!-- <div class='col col-2'>
          <button type='button' style='margin-top: 35%;'>
              Remove
          </button>

          </div> -->
      `)
    } else {
      $('#user_details_div').append(`
          <div class='row'
          style='font-family: Patrick Hand SC; margin-top:1%;margin-left:2%;margin-right:2%;background-color: #FFFBF5;border-radius: 15px;'>

          <div class='col col-2'>
          <img style="height:100%;width:100%;margin-top:2%;" align=left src="/static/member-yellow.png" alt="Avatar">
          </div>
          <div class='col' style='justify-content:left;align-items:left;' align=left>
          <p style='margin-top:2%;font-size: 1.5vw;justify-content:left;align-items:left;'>${user_place}</p>
          <p>${username}</p>
          </div>
          <!-- <div class='col col-2'>
          <button type='button' style='margin-top: 35%;'>
              Remove
          </button>

          </div> -->
      `)
    }

}

function homeButton() {
  var base_url = window.location.origin;
  location.replace(base_url);
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

//Set up the socketio for detecting additional members joining
socket = io(this.base_url)
socket.emit('join', { 'room': session_id })
socket.on('user_joined_room', (user) => {
    add_user_to_list(user)
})

$('#calculation_button').on('click', () => {
    // /session/<session_id>/calculate (GET)
    // -> If OAuth is provided, run the calculation
    // -> Redirect to results page
    let url = base_url + '/session/' + session_id + '/calculate';
    $.get(url,function(data,status){
        console.log("Data: " + data + "\nStatus: " + status);

    })
})



socket.on('calculation_result', (data) => {
    console.log(data)

    // -> Event: 'calculation_result'
    // Sample Data: {"info" : "done"}
    // Use case: Will be emitted when the calculation is completed
    if(data['info'] == 'done') {
        //Change to the card swipe page
        let url = base_url + '/session/' + session_id + '/swipe';
        console.log("Replacing URL.")
        location.href = url

    }
})

// socket.emit('calculation_done', {'session_id':'23ac04ff-a31b-11ea-9cb9-0209d5bc9eb8'})
