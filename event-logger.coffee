# a little helper function
occupationsPerHour = (floor, room) ->
  d = new Date();
  return {
      floor : floor,
      room: room,
      year: d.getUTCFullYear(),
      month: d.getUTCMonth(),
      day : d.getUTCDate(),
      hour: d.getUTCHours(),
  }

getStartOfOccupation = (event, Event, callback) ->
  Event.findOne({'floor' : event.floor, 'room' : event.room, 'status' : 1 }, {}, {sort: { 'time' : -1 }}).exec( (err, event) ->
    if err?
      return false

    callback( event.time )
  )

exports.logEvent = (event, req, res, Event, FloorStats, Visits) ->
  event.save( (err) ->
    if err?
      res.statusCode = 400
      res.send("Error")
    else
      res.statusCode = 200
      res.send(event)

  )

  if parseInt(event.status) is 1
    FloorStats.update(
      occupationsPerHour(event.floor, event.room),
      {$inc: { occupations: 1 }},
      {upsert: true}, (err) ->

    )
  else
    getStartOfOccupation(event, Event, (response) ->
      endOfOccupation = event.time
      startOfOccupation = response

      diff = new Date(endOfOccupation - startOfOccupation).getTime()
      timeObject = occupationsPerHour(event.floor, event.room)

      FloorStats.update(
        timeObject,
        {$inc: { duration: diff }},
        {upsert: true}, (err) ->

      )

      visitData = timeObject
      visitData.duration = diff

      visit = new Visits( visitData )

      visit.save()

    )






  # # 24 hour summary 'Hello' on 2011-4-21
  # for(i = 0; i < 24; i++) {
  #     //careful: days (1-31), month (0-11) and hours (0-23)
  #     stats = db.pagestats.findOne({ page: 'Hello', year: 2011, month: 3, day : 21, hour : i})
  #     if(stats) {
  #         print(i + ': ' + stats.views + ' views')
  #     } else {
  #         print(i + ': no hits')
  #     };
  # }