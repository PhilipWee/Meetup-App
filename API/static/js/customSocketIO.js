//Joining the socket
const socket = io('https://meetup-mouse.com')
//Join a session
socket.emit('join',{'room':'19820-8cn93-d32198jcds'})
//Receive data from the socket
socket.on('event', (data) => {
    //handle the data
    console.log(data)
})

