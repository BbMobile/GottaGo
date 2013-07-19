###
# Private
###

exports.event = (req, res) ->
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


# exports.name = function (req, res) {
#   res.json({
#   	name: 'Bob'
#   });
# };