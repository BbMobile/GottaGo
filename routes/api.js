// Generated by CoffeeScript 1.6.2
var models, mongoose;

models = require('../models');

mongoose = require('mongoose');

models.defineModels(mongoose, function() {
  var Event, db;

  Event = mongoose.model('Event');
  return db = mongoose.connect(app.set('db-uri'));
});

/*
# Private
*/


exports.event = function(req, res) {
  var event, params;

  params = req.body;
  event = new Event({
    'floor': params.floor,
    'room': params.room,
    'status': params.status
  });
  return event.save(function(err) {
    if (err != null) {
      res.statusCode = 400;
      return res.send("Error");
    } else {
      res.statusCode = 200;
      return res.send("OK");
    }
  });
};
