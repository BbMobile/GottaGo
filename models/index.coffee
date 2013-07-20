crypto = require('crypto')
config = require('../config')

defineModels = (mongoose, fn) ->
  Schema = mongoose.Schema
  ObjectId = Schema.ObjectId


  # Model: Event

  Event = new Schema({
    'floor': Number
    'room': String
    'time': {type: Date, default: Date.now}
    'status': Number
  },
  {
    toObject: { virtuals: true, getters:true }
    toJSON: { virtuals: true, getters:true }
  })

  Event.virtual('name').get( ->
    return 'config.room.names[this.floor + this.room]'
  )
  Event.pre('save', (next, save) ->
    this.timestamp_ms = this.time.getTime()
    next()
  )

  # Model: FloorStats

  FloorStats = new Schema({
    "year": Number
    "day": Number
    "hour": Number
    "month": Number
    "occupations": Number
    "duration": Number
    'floor': Number
    'room': String
  })


  # Model: Que

  Que = new Schema({
    'floor': Number
    'contact': {
      type: String
      match: ///
        ^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\
        ".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA
        -Z\-0-9]+\.)+[a-zA-Z]{2,}))$
      ///
    }
    'time': { type: Date, default: Date.now }
    'status': Number
  })

  # Document.virtual('id')
  #   .get(function() {
  #     return this._id.toHexString()
  #   })

  # Document.pre('save', function(next) {
  #   this.keywords = extractKeywords(this.data)
  #   next()
  # })


  mongoose.model('Event', Event)
  mongoose.model('FloorStats', FloorStats)
  mongoose.model('Que', Que)
  fn()

exports.defineModels = defineModels