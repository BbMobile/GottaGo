express = require('express')
mongoose = require('mongoose')
mongoStore = require('connect-mongodb')
routes = require('./routes')
path = require('path')
models = require('./models')
config = require('./config')
nodemailer = require("nodemailer")
eventLogger = require("./event-logger")


app = express()

Event = null
FloorStats = null
Visits = null
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
	app.FloorStats = FloorStats = mongoose.model('FloorStats')
	app.Visits = Visits = mongoose.model('Visits')
	app.Que = Que = mongoose.model('Que')
	db = mongoose.connect(app.set('db-uri'))
)




io = require('socket.io').listen(app.listen(app.get('port'), ->
  console.log("Express server listening on port " + app.get('port'))
))




# Routes

# serve index and view partials
app.get('/', routes.index)
app.get('/partials/:name', routes.partials)


# Private API
app.post('/api/event', (req, res) ->
	params = req.body

	# setup e-mail data with unicode symbols
	mailOptions = {
	    from: "So You Gotta Go <soYouGottaGo@gottaGo.medu.com>", # sender address
	    bcc: "", # list of receivers
	    subject: "A Bathroom on the #{params.floor}nd floor is available!!", # Subject line
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

	io.sockets.emit('event', event);

	# Unlocked is 0
	if parseInt(event.status) is 0

	  Que.find({'floor' : event.floor }, {}, {sort: { 'time' : -1 }}).exec( (err, que) ->
	    if err?
	      return false

	    for person in que
	      mailto.push("<#{person.contact}>")

	    mailOptions.bcc = mailto.join(",")
	    mailOptions.text = "A Bathroom on the #{event.floor}nd is available!! \n " # plaintext body

	    if mailto.length > 1
	      mailOptions.text += "This message was sent to #{mailto.length} humans. SO HURRY!"

	    mail(mailOptions, (err) ->

	    )

	    Que.find().remove()
	    io.sockets.emit('que', {floor:event.floor,count:0})
	  )

	eventLogger.logEvent(event, req, res, Event, FloorStats, Visits, ->
		pushAnalytics()
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
				Que.count({floor:floor}, (err, count = 0) ->
					io.sockets.emit('que', {floor:floor,count:count})
				)

				res.statusCode = 200
				res.send("OK")
		)
	)

)


# redirect all others to the index (HTML5 history)
app.get('(!public)*', routes.index)



io.sockets.on('connection', (socket) ->
	# Angular API
	statusArray = [ #all floors
		[ #2nd Floor
		],
		[ #3rd floor
		]
	]
	queObj = {}
	checklistObject = {}

	Event.aggregate(
		{$group:
			{_id :{floor: '$floor', room: '$room', status:'$status'}, time: {$max: '$time'} } }, {$sort: {time: -1}}, {$project: {floor:"$_id.floor", room:"$_id.room", status:"$_id.status", time:"$time"}
		}, (err, currentStatusArray) ->
			###
			[ { _id: { floor: 2, room: 'b', status: 0 },
			    time: Fri Aug 02 2013 13:39:34 GMT-0700 (PDT) },
			  { _id: { floor: 2, room: 'b', status: 1 },
			    time: Fri Aug 02 2013 13:39:14 GMT-0700 (PDT) },
			  { _id: { floor: 2, room: 'a', status: 1 },
			    time: Fri Aug 02 2013 13:39:01 GMT-0700 (PDT) },
			  { _id: { floor: 3, room: 'a', status: 0 },
			    time: Wed Jul 31 2013 16:37:17 GMT-0700 (PDT) },
			  { _id: { floor: 3, room: 'a', status: 1 },
			    time: Wed Jul 31 2013 16:36:55 GMT-0700 (PDT) },
			  { _id: { floor: 2, room: 'a', status: 0 },
			    time: Fri Jul 26 2013 11:00:36 GMT-0700 (PDT) } ]

			###

			for roomEvent in currentStatusArray
				if not checklistObject[roomEvent.floor + roomEvent.room]
					statusArrayIndex = if roomEvent.floor is 2 then 0 else 1
					floorArrayIndex = if roomEvent.room is 'a' then 0 else 1
					checklistObject[roomEvent.floor + roomEvent.room] = true
					statusArray[statusArrayIndex].splice( floorArrayIndex, 0, roomEvent )

			console.log(statusArray)

			for floor, index in config.floors
				Que.count({floor:floor}, (err, count = 0) ->
					queObj[floor] = count
					console.log(floor, count ,queObj)

					if index is config.floors.length
						# send the new user their name and a list of users

						pushAnalytics()

						io.sockets.emit('init',
							{
								floorsArray: statusArray
								queObj: queObj
							}
						)
				)

	)

	# for floor, index in config.floors
	# 	floorArray = []
	# 	Event.findOne({'floor' : floor, 'room' : 'a' }, {}, {sort: { 'time' : -1 }}).exec( (err, eventA) ->
	# 		if err?
	# 			res.statusCode = 400
	# 			return res.send("Error")

	# 		floorArray.push( eventA )

	# 		Event.findOne({'floor' : floor, 'room' : 'b' }, {}, {sort: { 'time' : -1 }}).exec( (err, eventB) ->
	# 			if err?
	# 				res.statusCode = 400
	# 				return res.send("Error")

	# 			floorArray.push( eventB )
	# 			statusArray.push( floorArray )

	# 			Que.count({floor:floor}, (err, count = 0) ->
	# 				queObj[floor] = count
	# 				console.log(floor, count ,queObj)

	# 				if index is config.floors.length
	# 					# send the new user their name and a list of users

	# 					pushAnalytics()

	# 					io.sockets.emit('init',
	# 						{
	# 							floorsArray: statusArray
	# 							queObj: queObj
	# 						}
	# 					)

	# 			)

	# 		)
	# 	)
)


pushAnalytics = ->
	Visits.aggregate(
		{ $match : { duration : { $gt : 20000, $lt : 3600000 } } },
		{ "$group": { _id: "$floor", averagedur: { $avg: "$duration"}}},
		{$sort: {_id: 1} }
	, (err, res) ->
		if err
			return handleError(err)


		date = new Date()
		today = date.getDate()
		month = date.getMonth()

		Visits.aggregate(
			{ $match : { floor: 2, day : { $gt : today - 1 }, month: month } },
			{ $match : { duration : { $gt : 20000, $lt : 3600000 } } },
			{ "$group": { _id: "$room", requests: { $sum:1} } },
			{$sort: {_id: 1} }
		, (err, res2) ->

			Visits.aggregate(
				{ $match : { duration : { $gt : 20000, $lt : 3600000 } } },
				{ "$group": { _id: "$hour", requests: { $sum:1} } }, {$sort: {requests:-1} }
			, (err, res3) ->

				reqPerHourObj = {}

				for hour in res3
					reqPerHourObj[hour._id] = hour.requests

				reqPerHourObj.top = res3[0]?.requests

				io.sockets.emit('analytics',
					{
						stats:
							{
								reqPerHour: reqPerHourObj
								averageDur:res[0]?.averagedur,
								a:
									{
										todayVisits: res2[0]?.requests
									}
								b:
									{
										todayVisits: res2[1]?.requests
									}
							}
					}
				)
			)

		)
	)