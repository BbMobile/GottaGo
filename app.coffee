express = require('express')
mongoose = require('mongoose')
mongoStore = require('connect-mongodb')
routes = require('./routes')
http = require('http')
path = require('path')
models = require('./models')
config = require('./config')

# api = require('./routes/api')

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
	app.Que = Que = mongoose.model('Que')
	db = mongoose.connect(app.set('db-uri'))
)



# Routes

# serve index and view partials
app.get('/', routes.index)
app.get('/partials/:name', routes.partials)

# Private API
app.post('/api/event', (req, res) ->
	params = req.body

	event = new Event(
		{
			'floor': params.floor
			'room': params.room
			'status': params.status
		}
	)
	event.save( (err) ->
		if err?
			res.statusCode = 400
			res.send("Error")
		else
			res.statusCode = 200
			res.send("OK")
	)
)


# Angular API
# app.get('/api/name', api.name)
app.get('/api/status', (req, res) ->
	statusArray = []

	for floor, index in config.floors
		floorArray = []
		Event.findOne({'floor' : floor, 'room' : 'a' }, {}, {sort: { 'time' : -1 }}).exec( (err, event) ->
			if err?
				res.statusCode = 400
				return res.send("Error")

			floorArray.push( event )
		)

		Event.findOne({'floor' : floor, 'room' : 'b' }, {}, {sort: { 'time' : -1 }}).exec( (err, event) ->
			if err?
				res.statusCode = 400
				return res.send("Error")

			floorArray.push( event )
			statusArray.push( floorArray )

			if index is config.floors.length
				res.statusCode = 200
				res.send( statusArray )
		)



)

app.get('/api/que/:floor', (req, res) ->
	Que.findOne({'floor' : req.params.floor, 'status' : 1 }, {}, {sort: { 'time' : -1 }}).exec( (err, que) ->
		if err?
			res.statusCode = 400
			return res.send("Error")

		res.statusCode = 200
		res.send(que)
	)
)

app.post('/api/que/:floor', (req, res) ->
	params = req.body
	floor = req.params.floor

	que = new Que(
		{
			'floor': floor
			'status': 1
			'contact': params.email || params.phone
		}
	)

	que.save( (err) ->
		if err?
			res.statusCode = 400
			res.send("Error")
		else
			res.statusCode = 200
			res.send("OK")
	)
)


# redirect all others to the index (HTML5 history)
app.get('(!public)*', routes.index)




http.createServer(app).listen(app.get('port'), ->
  console.log("Express server listening on port " + app.get('port'))
)