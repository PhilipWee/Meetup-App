// const Http = new XMLHttpRequest();
// const url='https://jsonplaceholder.typicode.com/posts';
// Http.open("GET", url);
// Http.send();

// Http.onreadystatechange = (e) => {
//   console.log(Http.responseText)
// };

function redirect() {
  console.log("running redirect")
  window.location.assign="templates/Geoloc.html"
};



document.getElementById ("redirect").addEventListener ("click", redirect)


