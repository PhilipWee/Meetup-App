//=================================== CAROUSEL =================================
class Carousel {

	constructor(element) {
		//TODO: Get the user uuid
		this.uuid = "TESTINGUUID"

		this.curIndex = 0;
		//Get the url depending on where the server is hosted
		this.base_url = window.location.origin;
		this.socket = io(this.base_url)

		//Join a session
		this.session_id = document.location.pathname.split('/')[2]
		this.socket.emit('join',{'room':this.session_id})

		//Double check that there is an acknowledgement for joining
		this.socket.on('join_ack', (data) => {
			//handle the data
			console.log(data)
		})

		//Connect the socket to listen for errors
		this.socket.on("Error",(data)=>{
			console.log(data)
		})

		//temp session_id for testing
		this.session_id = '008ab900-3838-11ea-bf52-06b6ade4a06c'

		var results_url = this.base_url + '/session/' + this.session_id + '/results';

		// Get the data for the particular session id
		$.getJSON(results_url,function(result){
			console.log(result)
		}).catch(function (error){
			console.log('Unable to get results, Error: ' + error)
		})

		this.board = element

    	// add first two cards programmatically
		this.push()
		this.push()

		// handle gestures
		this.handle()

	}

	handle() {

		// list all cards
		this.cards = this.board.querySelectorAll('.swipeCard')     // this.cards is a list

		// get top card
		this.topCard = this.cards[this.cards.length-1]        // top card element

		// get next card
		this.nextCard = this.cards[this.cards.length-
			2]

		// if at least one card is present
		if (this.cards.length > 0) {

			// set default top card position and scale
			this.topCard.style.transform =
				'translateX(-50%) translateY(-50%) rotate(0deg) rotateY(0deg) scale(1)'

			// destroy previous Hammer instance, if present
			if (this.hammer) this.hammer.destroy()

			// listen for tap and pan gestures on top card
			this.hammer = new Hammer(this.topCard)           // Hammer constructor
			this.hammer.add(new Hammer.Tap())
			this.hammer.add(new Hammer.Pan({
				position: Hammer.position_ALL, threshold: 0
			}))

			// pass events data to custom callbacks
			this.hammer.on('tap', (e) => { this.onTap(e) })
			this.hammer.on('pan', (e) => { this.onPan(e) })

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

		var data = {'sessionID':this.session_id,
				'swipeIndex':this.curIndex,
				'userIdentifier':this.uuid}
		console.log(data)
    	if (posX > 0) {
			data['selection'] = true
    	}
    	else if (posX < 0) {
			data['selection'] = false
		}

		socket.emit('swipe_details', data);

		this.curIndex++;
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

		card.style.backgroundImage =
			"url('https://picsum.photos/320/320/?random=" + Math.round(Math.random()*1000000) + "')"

		if (this.board.firstChild) {
			this.board.insertBefore(card, this.board.firstChild)
		} else {
			this.board.append(card)
		}

	}

}

let board = document.querySelector('#board')

let carousel = new Carousel(board)
