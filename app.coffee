# Module dependencies.
express = require 'express'
path = require 'path'
ejs = require 'ejs'
http = require 'http'

{Logger} = require './util/logger'
siteRoutes = require './routes/siteRoutes'
blogRoutes = require './routes/blogRoutes'
logRoutes = require './routes/logRoutes'
authRoutes = require './routes/authRoutes'

app = express()


# Configuration
app.configure -> 
  app.set 'port', process.env.PORT || 3000
  app.set 'views', path.join(__dirname, 'views')
  app.set 'datapath', path.join(__dirname, 'data')

  # Configure view engine options
  ejs.open = '{{'
  ejs.close = '}}'
  app.set 'view engine', 'ejs'

  app.use express.favicon()
  app.use express.logger('dev')

  app.use express.bodyParser()
  app.use express.methodOverride()

  app.use express.cookieParser('your secret here')
  app.use express.session()

  # static handler must come before app.router!
  app.use express.static path.join(__dirname, 'public')   

  app.use app.router


# app.error (err, req, res, next) ->
#   Logger.error err
#   res.render '500.ejs', { status: 500, message: "TBD" }


app.configure 'development', -> 
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })


app.configure 'production', ->
  app.use express.errorHandler()


# Application settings
# TODO: make showDrafs depending on user logged in
app.set "dataOptions", { 
  dataPath: __dirname + "/data"
  createDataFileIfNotFound: false
  showDrafts: app.settings.env isnt "production" 
}


# Routes
app.get '/', siteRoutes.home
app.get '/about', siteRoutes.about

app.get '/blog/new', blogRoutes.editNew
app.post '/blog/new', blogRoutes.saveNew

app.get '/blog/edit/:topicUrl', blogRoutes.edit
app.post '/blog/save/:id', blogRoutes.save

app.get '/blog/list', blogRoutes.viewAll

app.get '/blog/rss', blogRoutes.rssList

# Switch to viewRecent when blog list gets too long
app.get '/blog', blogRoutes.viewAll

app.get '/blog/:topicUrl', blogRoutes.viewOne

app.get '/logs/current', logRoutes.viewCurrent
app.get '/logs/:logDate', logRoutes.viewSpecific
app.get '/logs/', logRoutes.viewCurrent
 
app.get '/login/:key', authRoutes.loginConfirm
app.get '/login', authRoutes.loginGet
app.post '/login', authRoutes.loginPost

app.get '/logout', authRoutes.logout

app.get '*', siteRoutes.notFound

# Fire it up!
server = http.createServer(app)
port = app.get('port')
server.listen port, ->
  address = "http://localhost:#{port}"
  Logger.info "Express server listening on #{address} in #{app.settings.env} mode"
