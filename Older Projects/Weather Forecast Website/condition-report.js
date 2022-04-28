var express = require('express');
var request = require('request'); 
var path = require('path');

var app = express();
var handlebars = require('express-handlebars').create({defaultLayout:'main'});

app.engine('handlebars', handlebars.engine);
app.set('view engine', 'handlebars');
app.set('port', 9892);

// Include CSS
app.use(express.static(path.join(__dirname, '/public')));
 
// Allow POST requests with both xwww and json formats
var bodyParser = require('body-parser');
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

/* Home Page Code */
app.get('/',function(req,res){
   
  res.render('home')
});

app.get('/weather-data',function(req,res,next){
  
  // Stormglass Weather Data  
  var lat = req.query.lat;
  var lon = req.query.lon;
  var context = {};
  if (lat == null || lon == null) {
     context.metaData = ["No location defined, go to the Location Finder page"];
     context.skiData = [{"time":0,"airTemp":0,"snowDepth":0,"windSpeed":0,"windDir":0}];
     res.render('weather', context)
  } else {	
     
    var params = ['airTemperature', 'snowDepth', 'windDirection', 'windSpeed'];
    request({
       "url":"https://api.stormglass.io/v2/weather/point?lat=" + lat + "&lng=" + lon + "&params=" + params,
       "method":"GET",
       "headers":{
         "Authorization":"d2345d8a-2054-11eb-a5cd-0242ac130002-d2345e16-2054-11eb-a5cd-0242ac130002"
       }
    }, function(err, response, body){
      if (response.statusCode >= 200 && response.statusCode <400 ) { 
        data = JSON.parse(body);
        context.metaData = [];
        context.skiData = [];
        context.metaData.push("Start of data: " + data.meta.start);
        context.metaData.push("End of data: " + data.meta.end);
        context.metaData.push("Lattitude of location: " + data.meta.lat.toPrecision(4));
        context.metaData.push("Longitude of location: " + data.meta.lng.toPrecision(4));
        for (i in data.hours){
          if (i >= 100) {break};
          context.skiData.push({'time': data.hours[i].time.substring(0, 16),
                                'airTemp': JSON.stringify(data.hours[i].airTemperature.noaa),
	            	        'snowDepth': JSON.stringify(data.hours[i].snowDepth.noaa),
        		        'windSpeed': JSON.stringify(data.hours[i].windSpeed.noaa),
			        'windDir': JSON.stringify(data.hours[i].windDirection.noaa)});
        };
      
        res.render('weather', context);
      } else {
        if(response){
          console.log(response.statusCode);
        }
        next(err);
      }
    });
  }  
}); 

app.get('/surf-data', function(req,res){
  
  // Stormglass Weather Data  
  var lat = req.query.lat;
  var lon = req.query.lon;
  var params = ['airTemperature', 'swellDirection', 'swellHeight', 'swellPeriod', 'waterTemperature', 'windDirection', 'windSpeed'];
  var context = {};
  if (lat == null || lon == null) {
    context.metaData = ["No location defined, go to the Location Finder page"];
    context.surfData = [{'airTemperature':0, 'swellDirection':0, 'swellHeight':0, 'swellPeriod':0, 'waterTemperature':0, 'windDirection':0, 'windSpeed':0}];
    res.render('surf-data', context);
  } else {
    request({
      "url":"https://api.stormglass.io/v2/weather/point?lat=" + lat + "&lng=" + lon + "&params=" + params,
      "method":"GET",
      "headers":{
        "Authorization":"d2345d8a-2054-11eb-a5cd-0242ac130002-d2345e16-2054-11eb-a5cd-0242ac130002"
      }
    }, function(err, response, body){
      if (response.statusCode >= 200 && response.statusCode <400 ) { 
        data = JSON.parse(body);
        context.metaData = [];
        context.surfData = [];
        context.metaData.push("Start of data: " + data.meta.start);
        context.metaData.push("End of data: " + data.meta.end);
        context.metaData.push("Lattitude of location: " + data.meta.lat.toPrecision(4));
        context.metaData.push("Longitude of location: " + data.meta.lng.toPrecision(4));
        for (i in data.hours){
          if (i >= 100) {break}
	  context.surfData.push({'time': data.hours[i].time.substring(0, 16),
                                 'airTemp': JSON.stringify(data.hours[i].airTemperature.noaa),
        		         'swellDir': JSON.stringify(data.hours[i].swellDirection.noaa),
        		         'swellHeight': JSON.stringify(data.hours[i].swellHeight.noaa),
        		         'swellPeriod': JSON.stringify(data.hours[i].swellPeriod.noaa),
        		         'waterTemp': JSON.stringify(data.hours[i].waterTemperature.noaa),
        		         'windDir': JSON.stringify(data.hours[i].windDirection.noaa),
        		         'windSpeed': JSON.stringify(data.hours[i].windSpeed.noaa)});
        };
     
        res.render('surf-data', context);
      } else {
        if(response){
          console.log(response.statusCode);
        }
      }
    });
  }  
});

app.get('/location-page', function(req, res){
  res.render('location-page')
});

// Download the OregonMap image
app.get('/download-map', function(req, res){
  res.download(__dirname + '/public/images/OregonMap.jpg', 'OregonMap.jpg');
})

// Link to MagicSeaweed
app.get('/magic-seaweed', function(req, res){
  res.status(301).redirect("https://www.magicseaweed.com")
}) 

// Link to NOAA Weather
app.get('/weather-link', function(req, res){
  res.status(301).redirect("https://forecast.weather.gov/MapClick.php?lat=45.3308&lon=-121.7111")
})

app.use(function(req,res){
  res.status(404);
  res.render('404');
   
});

app.use(function(err, req, res, next){
  console.error(err.stack);
  res.type('plain/text');
  res.status(500);
  res.render('500');
});

app.listen(app.get('port'), function(){
  console.log('Express started on http://localhost:' + app.get('port') + '; press Ctrl-C to terminate.');
});
