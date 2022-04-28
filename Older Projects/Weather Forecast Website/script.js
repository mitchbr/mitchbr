// Create the Map
mapboxgl.accessToken = 'pk.eyJ1IjoiYnJvd25taXQiLCJhIjoiY2tlb3RnaXA2MGYwMzJxbmlxZHluY3RncSJ9.nl7-Wek2XkPF-CZSvVSoUg';
var map = new mapboxgl.Map({
  container: 'map', // container id
  style: 'mapbox://styles/mapbox/streets-v11',
  center: [-121.7, 45.37], // starting position
  zoom: 9 // starting zoom
});
 
// Retrieve Lattitude and Longitude on a Click
map.on('click', function (e) {
  console.log(JSON.stringify(e.lngLat.lat));
  console.log(JSON.stringify(e.lngLat.lng));
  lat = JSON.stringify(e.lngLat.lat)
  lon = JSON.stringify(e.lngLat.lng)
  weatherSearch(lat, lon)
});


// Weather Search
function badWeatherSearch(){

  // Store the city and country or zip and country enter by the user
  var cityId = document.getElementById("city").value;
  var zipId = document.getElementById("zip").value;
  var countryId = document.getElementById("country").value;

  // Begin an asynchronous GET request
  var req = new XMLHttpRequest();
  if(cityId){
	req.open("GET", "http://api.openweathermap.org/data/2.5/weather?q=" + cityId + "," + countryId + "&appid=fa7d80c48643dfadde2cced1b1be6ca1", true);
  } else if(zipId){
    req.open("GET", "http://api.openweathermap.org/data/2.5/weather?zip=" + zipId + "," + countryId + "&appid=fa7d80c48643dfadde2cced1b1be6ca1", true);
  };                                                                                                                              
  var printResponse
  req.addEventListener('load',function(){
    if(req.status >= 200 && req.status < 400){
	  // Display the results if the response is good
	  var response = JSON.parse(req.responseText);
	  var responseCity = response.name;
	  var responseTemp = (response.main.temp - 273.15)*(9/5) + 32;
 	  printResponse = "The current temperature for " + responseCity + " is: " + responseTemp.toPrecision(4) + " F";
      document.getElementById("displayWeather").textContent = printResponse;
	} else {
	  printResponse = "Error in the request: " + req.status + " " + req.statusText;
      document.getElementById("displayWeather").textContent = printResponse;
    }});
  req.send(null);
  event.preventDefault();
};

// NOAA Weather Data
function weatherSearch(lat, lon){
  var req = new XMLHttpRequest();
  req.open("GET", "https://api.weather.gov/points/" + lat + "," + lon + "/forecast", true);
  req.addEventListener('load', function(){
    if(req.status >= 200 && req.status < 400){
       // Display the results if the response is good
       var response = JSON.parse(req.responseText);
 	   console.log(response)
    } else {
      printResponse = "Error in the request: " + req.status + " " + req.statusText;
    };
  });
  req.send(null);
  event.preventDefault();
};

