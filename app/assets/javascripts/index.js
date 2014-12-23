
var express = require('express');
var app = express();
var pg = require('pg');
var routes = require('./routes');
var logger = require('./logger');

app.set('port', (process.env.PORT || 5000));
app.use(logger);

app.get('/', routes.index);
app.get('/db', routes.db);

// Set /public as our static content dir
app.use(express.static(__dirname + "/public/"));

app.listen(app.get('port'), function() {
  console.log("Node app is running at localhost:" + app.get('port'));
});

