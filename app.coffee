express = require('express')
mongoose = require('mongoose')
mongoStore = require('connect-mongodb')
routes = require('./routes')
http = require('http')
path = require('path')
models = require('./models')
config = require('./config')
nodemailer = require("nodemailer")


# api = require('./routes/api')

app = express()

Event = null
Que = null


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

app.get('/api/mail', (req, res) ->
	console.log(req, res)

	Que.find({'floor' : event.floor, 'status' : 1 }, {}, {sort: { 'time' : -1 }}).exec( (err, que) ->
		if err?
			return false
		console.log(que)
		for person in que
			mailto.push("<#{person.contact}>")

		mailOptions.to = mailto.join(",")
		mailOption.text = "A Bathroom on the #{event.floor}nd is available!! \n " # plaintext body

		if mailto.length > 1
			mailOption.text += "This message was sent to #{mailto.length} humans. SO HURRY!"

		mail(mailOptions, (err) ->

		)
	)
	res.statusCode = 200
	res.send( statusArray )
)

# Private API
app.post('/api/event', (req, res) ->
	params = req.body

	# setup e-mail data with unicode symbols
	mailOptions = {
	    from: "So You Gotta Go <soYouGottaGo@gottaGo.medu.com>", # sender address
	    to: "", # list of receivers
	    subject: "A Bathroom on the #{params.floor}nd is available!!", # Subject line
	    text: "A Bathroom on the #{params.floor}nd is available!! " # plaintext body
	    # html: "<b>Hello world ✔</b>" # html body
	}
	mailto = []

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

			# Unlocked is 0
			if event.status = 0
				Que.find({'floor' : event.floor, 'status' : 1 }, {}, {sort: { 'time' : -1 }}).exec( (err, que) ->
					if err?
						return false

					for person in que
						mailto.push("<#{person.contact}>")

					mailOptions.to = mailto.join(",")
					mailOption.text = "A Bathroom on the #{event.floor}nd is available!! \n " # plaintext body

					if mailto.length > 1
						mailOption.text += "This message was sent to #{mailto.length} humans. SO HURRY!"

					mail(mailOptions, (err) ->

					)
				).remove()
	)


)

# create reusable transport method (opens pool of SMTP connections)
smtpTransport = nodemailer.createTransport("SMTP",{
    service: "medu",
    host: "mail1.medu.com"
})


mail = (mailOptions, callback) ->

	# send mail with defined transport object
	smtpTransport.sendMail(mailOptions, (error, response) ->
    if error
      console.log(error)
      callback(error)
    else
      console.log("Message sent: " + response.message)
      callback()

    # if you don't want to use this transport object anymore, uncomment following line
    smtpTransport.close() # shut down the connection pool, no more messages
	)


# Angular API
# app.get('/api/name', api.name)
app.get('/api/status', (req, res) ->
	statusArray = []

	for floor, index in config.floors
		floorArray = []
		Event.findOne({'floor' : floor, 'room' : 'a' }, {}, {sort: { 'time' : -1 }}).exec( (err, event) ->
			console.log(event)
			if err?
				res.statusCode = 400
				return res.send("Error")

			floorArray.push( event )
		)

		Event.findOne({'floor' : floor, 'room' : 'b' }, {}, {sort: { 'time' : -1 }}).exec( (err, event) ->
			console.log(event)
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
	Que.find({'floor' : req.params.floor, 'status' : 1 }, {}, {sort: { 'time' : -1 }}).exec( (err, que) ->
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
			'contact': params.contact
		}
	)

	que.validate( (validationErr) ->
		que.save( (err) ->
			if err?
				res.statusCode = 400
				res.send({message:"Invalid Email"})
			else
				res.statusCode = 200
				res.send("OK")
		)
	)

)


# redirect all others to the index (HTML5 history)
app.get('(!public)*', routes.index)




http.createServer(app).listen(app.get('port'), ->
  console.log("Express server listening on port " + app.get('port'))
)