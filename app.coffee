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

  ejs.open = '{{'
  ejs.close = '}}'
  app.set 'view engine', 'ejs'

  # Use this to render plain old HTML files through the JADE engine
  # but without substitutions
  # app.set 'view options', {layout: false}
  # app.register '.html', require('jade')

  # app.register '.html', require 'ejs'

  # options = {
  #   call: (scope, options) -> 
  #     return "xxx"
  #   compile: (str, options) -> 
  #     html = str
  #     return str
  #     # return (locals) -> 
  #       # return html.replace /\{([^}]+)\}/g, (_, name) -> locals[name]
  # }
  # app.register '.md', options

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
app.get '/', siteRoutes.home
app.get '/about', siteRoutes.about

app.get '/newblog', blogRoutes.newBlog
app.post '/newblog', blogRoutes.add

app.get '/blog/edit/:url?', blogRoutes.edit
app.post '/blog/edit/:url?', blogRoutes.save

app.get '/blog/:url?', blogRoutes.view

app.get '*', siteRoutes.notFound

# Fire it up!
app.listen 3000, ->
  console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env

