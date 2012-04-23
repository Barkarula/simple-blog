# Module dependencies.
express = require 'express'
site = require './routes/site'
blog = require './routes/blog' 

# Configuration
app = module.exports = express.createServer()

app.configure -> 
  app.set 'views', __dirname + '/views'
  app.set 'datapath', __dirname + '/data'
  app.set 'view engine', 'jade'
  #app.use express.logger() # logs HTTP requests
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + '/public')

app.error (err, req, res, next) ->
  console.log "Custom error hit"
  console.dir err
  res.render '500.jade', { status: 500, message: "TBD" }

app.configure 'development', -> 
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', ->
  app.use express.errorHandler()

# Routes
app.get '/', site.home
app.get '/about', site.about
app.get '/blog/edit/:url?', blog.edit
app.post '/blog/edit/:url?', blog.save
app.get '/blog/:url?', blog.view

app.get '*', site.notFound

# Fire it up!
app.listen 3000, ->
  console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env

