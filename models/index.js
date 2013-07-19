// Generated by CoffeeScript 1.6.2
var config, crypto, defineModels;

crypto = require('crypto');

config = require('../config');

defineModels = function(mongoose, fn) {
  var Event, ObjectId, Que, Schema;

  Schema = mongoose.Schema;
  ObjectId = Schema.ObjectId;
  Event = new Schema({
    'floor': Number,
    'room': String,
    'time': {
      type: Date,
      "default": Date.now
    },
    'status': Number
  }, {
    toObject: {
      virtuals: true,
      getters: true
    },
    toJSON: {
      virtuals: true,
      getters: true
    }
  });
  Event.virtual('name').get(function() {
    return 'config.room.names[this.floor + this.room]';
  });
  Event.pre('save', function(next, save) {
    this.timestamp_ms = this.time.getTime();
    return next();
  });
  Que = new Schema({
    'floor': Number,
    'contact': {
      type: String,
      match: /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    },
    'time': {
      type: Date,
      "default": Date.now
    },
    'status': Number
  });
  mongoose.model('Event', Event);
  mongoose.model('Que', Que);
  return fn();
};

exports.defineModels = defineModels;
