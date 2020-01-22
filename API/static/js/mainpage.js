var host_address_port = location.protocol+'//'+location.hostname+(location.port ? ':'+location.port: '')

function createMeetup() {
  window.location.href = '/session/create';
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
  document.getElementById("inputReport").style.display = "inline";
  document.getElementById('enterBugReport').style.display = "inline";
}

function submitBugReport() {
  var bugReport = document.getElementById("inputReport").value;

  $.ajax({
      type: 'POST',
      url: host_address_port + '/',
      data: JSON.stringify(bugReport),
      contentType:'application/json',
      success: function (response) {
          if (response == "SENT!") {
            alert("Your feedback has been received! Thank you (:")
          }
//  window.location.href='results_display' //form submission
          }
  })
}
