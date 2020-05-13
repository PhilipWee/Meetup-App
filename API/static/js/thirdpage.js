
//Joining the socket
const socket = io('http://127.0.0.1:5000')
//Join a session
socket.emit('join',{'room':'008ab900-3838-11ea-bf52-06b6ade4a06c'})
//Receive data from the socket
socket.on('user_joined_room', (data) => {
    //handle the data
    console.log(data)
})


function myFunction() {
    var copyText = document.getElementById("myInput");
    copyText.select();
    copyText.setSelectionRange(0, 99999);
    document.execCommand("copy");
    
    var tooltip = document.getElementById("myTooltip");
    tooltip.innerHTML = "Copied: " + copyText.value;
  }
  
  function outFunc() {
    var tooltip = document.getElementById("myTooltip");
    tooltip.innerHTML = "Copy to clipboard";
  }