var host_address_port = location.protocol + '//' + location.hostname + (location.port ? ':' + location.port : '')

function createMeetup() {
    window.location.href = '/session/create';
}

function homeButton() {
    var base_url = window.location.origin;
    location.replace(base_url);
}

function joinMeetup() {
    document.getElementById("inputSessionId").style.display = "inline";
    document.getElementById("enterSessionId").style.display = "inline";
}

function submitButton() {
    var sessionId = document.getElementById("inputSessionId").value;

    /* TO DO - Check if session id is valid from Database */

    window.location.href = '/session/' + sessionId + '/get_details';
}

function reportBug() {
    window.open("https://forms.gle/ua19qDgYCpuLWGJw9")
}

//function submitBugReport() {
// var bugReport = document.getElementById("inputReport").value;

//$.ajax({
//    type: 'POST',
//    url: host_address_port + '/',
//    data: JSON.stringify(bugReport),
//    contentType:'application/json',
//    success: function (response) {
//        if (response == "SENT!") {
//          alert("Your feedback has been received! Thank you (:")
//        }
//  window.location.href='results_display' //form submission


document.getElementById("homeButton").addEventListener("click", homeButton);