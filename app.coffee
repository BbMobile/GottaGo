express = require('express')
mongoose = require('mongoose')
mongoStore = require('connect-mongodb')
routes = require('./routes')
http = require('http')
path = require('path')
models = require('./models')
config = require('./config')

api = require('./routes/api')

app = express()

Event = null


app.configure( ->

	app.set('port', process.env.PORT || config.server.port)
	app.set('views', __dirname + '/views')
	app.set('view engine', 'jade')

	app.use(express.favicon())
	app.use(express.bodyParser())
	app.use(express.cookieParser())

	app.use(express.session({ store: mongoStore(app.set('db-uri')), secret: 'topsecret' }))
	app.use(express.logger({ format: '\x1b[1m:method\x1b[0m \x1b[33m:url\x1b[0m :response-time ms' }))
	app.use(express.methodOverride())
	app.use(app.router)

	app.use(express.static(path.join(__dirname, 'public')))

	app.use((err, req, res, next) ->
	  #only handle `next(err)` calls
	  console.log(err)
	  res.send(404, "FUCK 4-0-4")
	)
	app.use((req, res) ->
	  console.log("Page not found 404")
	  res.send(404, "FUCK 4-0-4")
	)

	# app.use(require('less-middleware')({ src: __dirname + '/public' }))
)


app.configure('development', ->
  app.set('db-uri', config.db.URL)
  app.use(express.errorHandler({ dumpExceptions: true }))
  app.set('view options', {
    pretty: true
  })
)

app.configure('test', ->
  app.set('db-uri', config.db.URL)
  app.set('view options', {
    pretty: true
  })
)

app.configure('production', ->
  app.set('db-uri', config.db.URL)
)



# Models

models.defineModels(mongoose, ->
  app.Event = Event = mongoose.model('Event')
  db = mongoose.connect(app.set('db-uri'))
)



# Routes

# serve index and view partials
app.get('/', routes.index)
app.get('/partials/:name', routes.partials)

# Private API
app.post('/api/event', api.event)


# Angular API
# app.get('/api/name', api.name)


# redirect all others to the index (HTML5 history)
app.get('*', routes.index)




http.createServer(app).listen(app.get('port'), ->
  console.log("Express server listening on port " + app.get('port'))
)