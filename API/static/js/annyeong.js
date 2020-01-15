var host_address_port = location.protocol+'//'+location.hostname+(location.port ? ':'+location.port: '');
//Get the session id from the pathname
var session_id = "/davidTest";

function submitbutton() {
  var input = document.getElementById('userInput').value;
//  console.log(input);
//  inputData = userInput.serializeArray();
  displayFunction();
  //console.log("Meow.")

  function displayFunction() {
    $.ajax({
      type: 'POST',
      url: host_address_port + session_id,
      data: JSON.stringify(input),
      contentType:'application/json',
      success: function (response_data) {
          console.log("running redirect")
  //window.location.href='results_display' //form submission
      }
    })
  }
}

document.getElementById ("submitbutton").addEventListener ("click", submitbutton);
