# Module dependencies.
express = require 'express'
siteRoutes = require './routes/siteRoutes'
blogRoutes = require './routes/blogRoutes' 
ejs = require 'ejs'

# Configuration
app = module.exports = express.createServer()

app.configure -> 
  app.set 'views', __dirname + '/views'
  app.set 'datapath', __dirname + '/data'

  # Configure view engine options
  ejs.open = '{{'
  ejs.close = '}}'
  app.set 'view engine', 'ejs'

  #app.use express.logger() # logs HTTP requests
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.static(__dirname + '/public') # must come before app.router!
  app.use app.router

app.error (err, req, res, next) ->
  console.log "Custom error hit"
  console.dir err
  res.render '500.ejs', { status: 500, message: "TBD" }

app.configure 'development', -> 
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', ->
  app.use express.errorHandler()

# Routes
app.get '/', siteRoutes.home
app.get '/about', siteRoutes.about

app.set "isReadOnly", if app.settings.env is "production" then true else false

if not app.settings.isReadOnly
  # Only enable edits when in development (local)
  # until I integrate an authentication process
  app.get '/blog/new', blogRoutes.editNew
  app.post '/blog/new', blogRoutes.saveNew

  app.get '/blog/edit/:topicUrl', blogRoutes.edit
  app.post '/blog/save/:id', blogRoutes.save

app.get '/blog/list', blogRoutes.viewAll

app.get '/blog', blogRoutes.viewRecent

app.get '/blog/:topicUrl', blogRoutes.viewOne

app.get '*', siteRoutes.notFound

# Fire it up!
app.listen process.env.PORT || 3000, ->
  address = "http://localhost:#{app.address().port}"
  console.log "Express server listening on #{address} in #{app.settings.env} mode"








