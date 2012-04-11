
// Module dependencies.
var express = require('express');
var site = require('./routes/site'); 
var blog = require('./routes/blog'); 

// Configuration
var app = module.exports = express.createServer();
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
app.get('/', site.home);
app.get('/about', site.about);
app.get('/blog/:url?', blog.blog);

app.get('*', site.notFound);

// Fire it up!
app.listen(3000, function(){
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
});
