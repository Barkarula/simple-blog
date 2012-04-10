
/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes'); // aka ./routes/index.js

var app = module.exports = express.createServer();

// Configuration
app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('datapath', __dirname + '/data');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
});

app.configure('production', function(){
  app.use(express.errorHandler());
});

// Routes
app.get('/', routes.blog.index);
app.get('/about', routes.blog.about);
app.get('/blog/:id?', routes.blog.blog);

app.get('*', function(req, res){
  res.render('404.jade', 
  	{ status: 404, message: 'Page not found' });
});

app.listen(3000, function(){
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
});
