//=================================== CAROUSEL =================================
var user_uid, confirmed_place_index;

class Carousel {

	constructor(element) {
		this.reachedLastCard = false;
		this.result_details;

		//TODO: Get the user uuid
		this.uuid = user_uid;
		console.log("HELLO! " + this.uuid);

		this.curIndex = -1;
		//Get the url depending on where the server is hosted
		this.base_url = window.location.origin;
		this.socket = io(this.base_url)

		//Join a session
		this.session_id = document.location.pathname.split('/')[2]
		this.socket.emit('join', { 'room': this.session_id })

		//Double check that there is an acknowledgement for joining
		this.socket.on('join_ack', (data) => {
			//handle the data
			console.log(data)
		})

		//Connect the socket to listen for errors
		this.socket.on("Error", (data) => {
			console.log(data)
		})

		//temp session_id for testing
		this.session_id = window.location.pathname.split('/')[2]

		var results_url = this.base_url + '/session/' + this.session_id + '/results';
		var details_url = this.base_url + '/session/' + this.session_id;

		var that = this;
		// Get the location data for the particular session id
		$.getJSON(results_url, function (result) {
			that.display_location_details(result);
		}).catch(function (error) {
			console.log('Unable to get results, Error: ' + error)
		})

		// Get the user data for the particular session id
		$.getJSON(details_url, function (result) {
			that.display_meetup_details(result);
		}).catch(function (error) {
			console.log('Unable to get meetup details, Error: ' + error)
		})

		this.board = element

		// add first card programmatically
		this.push()

		// handle gestures
		this.handle()

	}

	display_meetup_details(result) {
		var host_uuid = result['host_uuid'];
		//confirmed_place_index = result['confirmed_place_index'];

		var meetup_title = document.getElementById("meetup_title");
		meetup_title.innerHTML = result['meetup_name'];

		var that = this;
		result['users'].forEach(member_details => {
			let list_element = that.create_member_list_element(member_details, host_uuid)
			$('#meetup_members_title').after(list_element);
		})
		console.log(result)
		//Change the meetup name
		//Update the members list
	}

	create_member_list_element(member_details, host_uuid) {
		var src;
		var username = member_details['username']
		if (member_details['uuid'] == host_uuid) {
			src = '"/static/mouseAvatar1.png"'
		} else {
			src = '"/static/mouseAvatar2.png"'
		}
		//Start creating the element
		var list_item = document.createElement('a')
		list_item.classList.add('list-group-item', 'list-group-item-action')
		list_item.href = "#"
		list_item.innerHTML = `
			<div class="row">
				<div class="col-4">
					<img class="img-fluid" src=${src} />
				</div>
				<div class="col-8 pl-0">
					${username}
				</div>
			</div>
		`
		return list_item
	}

	display_location_details(result) {
		this.result_details = result;
		console.log(this.result_details)
		//push the next two cards
		// this.push()
		// this.push()
		//update each card, etc
	}

	handle() {

		// list all cards
		this.cards = this.board.querySelectorAll('.swipeCard')     // this.cards is a list

		// get top card
		this.topCard = this.cards[this.cards.length - 1]        // top card element

		// get next card
		this.nextCard = this.cards[this.cards.length -
			2]

		// if at least one card is present
		if (this.cards.length > 0) {

			// set default top card position and scale
			this.topCard.style.transform =
				'translateX(-50%) translateY(-50%) rotate(0deg) rotateY(0deg) scale(1)'

			// destroy previous Hammer instance, if present
			if (this.hammer) this.hammer.destroy()

			//Don't do anything if its the last card
			if (this.reachedLastCard == false) {
				// listen for tap and pan gestures on top card
				this.hammer = new Hammer(this.topCard)           // Hammer constructor
				this.hammer.add(new Hammer.Tap())
				this.hammer.add(new Hammer.Pan({
					position: Hammer.position_ALL, threshold: 0
				}))

				// pass events data to custom callbacks
				this.hammer.on('tap', (e) => { this.onTap(e) })
				this.hammer.on('pan', (e) => { this.onPan(e) })
			};


		}

	}

	checkDirection(posX) {

		// -> Event: 'swipe_details'
		// Sample Data: {'sessionID': 123456,
		// 			'swipeIndex': 5,
		// 			'userIdentifier':'abc123',
		// 			'selection':'true'/'false'}
		// Use case: Emitted by user whenever swiping

		var socket = io();

		var data = {
			'sessionID': this.session_id,
			'swipeIndex': this.curIndex,
			'userIdentifier': this.uuid
		}
		console.log(data)
		if (posX > 0) {
			data['selection'] = true
		}
		else if (posX < 0) {
			data['selection'] = false
		}

		socket.emit('swipe_details', data);

		//Update the other details depending on the index
		this._update_other_details(this.curIndex);

	}

	_update_other_details(indexToDisplay) {
		var location_name = this.result_details['possible_locations'][indexToDisplay]
		var location_details = this.result_details[location_name]
		var img_urls = location_details['pictures'].slice(1,4)
		var rating = location_details['rating']
		rating = rating == 'nan' ? 3 : parseFloat(rating)
		var price = location_details['price']
		price = price == 'nan' ? 'Unknown' : price
		var writeup = location_details['writeup']
		$('#additional_images').empty();
		//Update each of the images
		img_urls.forEach((img_url) => {
			$('#additional_images').append(`
			<div class="row mb-2">
				<img class="img-fluid"
					src="${img_url}">
			</div>
			`)
		})
		//Update the location name
		$('#location_name').text(location_name)
		//Update the number of stars
		const starTotal = 5;
		const starPercentage = (rating / starTotal) * 100;
		const starPercentageRounded = `${(Math.round(starPercentage / 10) * 10)}%`;
		document.querySelector(`.stars-inner`).style.width = starPercentageRounded;
		//Update the price
		$('#price_div').text(price)
		//Update the writeup
		$('#writeup_div').text(writeup)
		// console.log(indexToDisplay)
		// console.log(location_name)
		// console.log(img_urls)
		// console.log(rating)
		// console.log(price)
		// console.log(writeup)
	}

	onTap(e) {

		// get finger position on top card
		let propX = (e.center.x - e.target.getBoundingClientRect().left) / e.target.clientWidth

		// get degree of Y rotation (+/-15 degrees)
		let rotateY = 15 * (propX < 0.05 ? -1 : 1)

		// change the transition property
		this.topCard.style.transition = 'transform 100ms ease-out'

		// rotate
		this.topCard.style.transform =
			'translateX(-50%) translateY(-50%) rotate(0deg) rotateY(' + rotateY + 'deg) scale(1)'

		// wait transition end
		setTimeout(() => {
			// reset transform properties
			this.topCard.style.transform =
				'translateX(-50%) translateY(-50%) rotate(0deg) rotateY(0deg) scale(1)'
		}, 100)

	}

	onPan(e) {

		if (!this.isPanning) {

			this.isPanning = true

			// remove transition properties
			this.topCard.style.transition = null
			if (this.nextCard) this.nextCard.style.transition = null

			// get top card coordinates in pixels
			let style = window.getComputedStyle(this.topCard)
			let mx = style.transform.match(/^matrix\((.+)\)$/)
			this.startPosX = mx ? parseFloat(mx[1].split(', ')[4]) : 0
			this.startPosY = mx ? parseFloat(mx[1].split(', ')[5]) : 0

			// get top card bounds
			let bounds = this.topCard.getBoundingClientRect()

			// get finger position on top card, top (1) or bottom (-1)
			this.isDraggingFrom =
				(e.center.y - bounds.top) > this.topCard.clientHeight / 2 ? -1 : 1

		}

		// calculate new coordinates
		let posX = e.deltaX + this.startPosX
		let posY = e.deltaY + this.startPosY

		// get ratio between swiped pixels and the axes
		let propX = e.deltaX / this.board.clientWidth
		let propY = e.deltaY / this.board.clientHeight

		// get swipe direction, left (-1) or right (1)
		let dirX = e.deltaX < 0 ? -1 : 1

		// calculate rotation, between 0 and +/- 45 deg
		let deg = this.isDraggingFrom * dirX * Math.abs(propX) * 45

		// calculate scale ratio, between 95 and 100 %
		let scale = (95 + (5 * Math.abs(propX))) / 100

		// move top card
		this.topCard.style.transform =
			'translateX(' + posX + 'px) translateY(' + posY + 'px) rotate(' + deg + 'deg) rotateY(0deg) scale(1)'

		// scale next card
		if (this.nextCard) this.nextCard.style.transform =
			'translateX(-50%) translateY(-50%) rotate(0deg) rotateY(0deg) scale(' + scale + ')'

		if (e.isFinal) {

			this.isPanning = false

			let successful = false

			// set back transition properties
			this.topCard.style.transition = 'transform 200ms ease-out'
			if (this.nextCard) this.nextCard.style.transition = 'transform 100ms linear'

			// check threshold
			if (propX > 0.25 && e.direction == Hammer.DIRECTION_RIGHT) {

				successful = true
				// get right border position
				posX = this.board.clientWidth

			} else if (propX < -0.25 && e.direction == Hammer.DIRECTION_LEFT) {

				successful = true
				// get left border position
				posX = - (this.board.clientWidth + this.topCard.clientWidth)

			} else if (propY < -0.25 && e.direction == Hammer.DIRECTION_UP) {

				successful = false
				// get top border position
				posY = - (this.board.clientHeight + this.topCard.clientHeight)

			}

			if (successful) {

				// throw card in the chosen direction
				this.checkDirection(propX)
				this.topCard.style.transform =
					'translateX(' + posX + 'px) translateY(' + posY + 'px) rotate(' + deg + 'deg)';

				// wait transition end
				setTimeout(() => {
					// remove swiped card
					this.board.removeChild(this.topCard)
					// add new card
					this.push()
					// handle gestures on new top card
					this.handle()
				}, 200)

			} else {

				// reset cards position
				this.topCard.style.transform =
					'translateX(-50%) translateY(-50%) rotate(0deg) rotateY(0deg) scale(1)'
				if (this.nextCard) this.nextCard.style.transform =
					'translateX(-50%) translateY(-50%) rotate(0deg) rotateY(0deg) scale(0.95)'

			}

		}

	}

	push() {


		let card = document.createElement('div')

		card.classList.add('swipeCard')

		var url;
		var location_name;
		var first_pic_url;
		//Determine the picture to use
		if (this.curIndex == -1) {
			url = '/static/swipeLeftRight.png'
		} else if (this.curIndex >= this.result_details['possible_locations'].length) {
			//TODO fix dont have result details yet bug
			this.reachedLastCard = true;
			url = '/static/pleaseWait.png'
		} else {
			location_name = this.result_details['possible_locations'][this.curIndex]
			url = this.result_details[location_name]['pictures'][0]

		}

		card.style.backgroundImage = `url('${url}')`;

		if (this.board.firstChild) {
			this.board.insertBefore(card, this.board.firstChild)
		} else {
			this.board.append(card)
		}

		this.curIndex++;

	}
}




class Auth {

    constructor() {

        // Initialize Firebase
        this.firebaseConfig = {
            apiKey: "AIzaSyAJ__NSxJn-qEqWrHAVnH1duusK1rJPqx4",
            authDomain: "meetup-mouse-265200.firebaseapp.com",
            databaseURL: "https://meetup-mouse-265200.firebaseio.com",
            projectId: "meetup-mouse-265200",
            storageBucket: "meetup-mouse-265200.appspot.com",
            messagingSenderId: "1052519191030",
            appId: "1:1052519191030:web:90909ba515c20d766377d7",
            measurementId: "G-FP46EYMK63"
        };

        firebase.initializeApp(this.firebaseConfig);
        //firebase.analytics();
        console.log("Firebase initialized!");

        //Check if the user is signed in
        firebase.auth().onAuthStateChanged(function(user) {
            if (user) {
							user_uid = user.uid;

							let board = document.querySelector('#board')

							let carousel = new Carousel(board)

              var isAnonymous = user.isAnonymous;
              if (isAnonymous) {
                // Create sign in button
                var btn = document.createElement("BUTTON");
                btn.style = 'font-family: Patrick Hand SC;font-size:2vw;margin-left:45%';
                btn.onclick = function() {
                  // Redirect to correct page; Pending users, Pending swipes or Confirmed
                  window.location.href = '/loginPage';
                }
                btn.innerHTML = "Sign In";
                document.getElementById('loginStatusButton').appendChild(btn);
              } else {
                // Create sign out button
                var btn = document.createElement("BUTTON");
                btn.style = 'font-family: Patrick Hand SC;font-size:2vw;margin-left:45%';
                btn.onclick = function() {
                  firebase.auth().signOut().then(function() {
                    console.log("Signed out")
                    // Sign-out successful.
                  }).catch(function(error) {
                    // An error happened.
                  });
                  window.location.reload(true);
                }
                btn.innerHTML = "Sign Out";
                document.getElementById('loginStatusButton').appendChild(btn);
              }
            } else {
                firebase.auth().signInAnonymously().catch(function(error) {
                  // Handle Errors here.
                  var errorCode = error.code;
                  var errorMessage = error.message;
                  // ...
                });
            }
          });
    }
}

let auth = new Auth()
