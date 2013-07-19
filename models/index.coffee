crypto = require('crypto')
config = require('../config')

defineModels = (mongoose, fn) ->
  Schema = mongoose.Schema
  ObjectId = Schema.ObjectId


  # Model: Event

  Event = new Schema({
    'floor': Number
    'room': String
    'time': { type: Date, default: Date.now }
    'status': Number
  },
  {
    toObject: { virtuals: true },
    toJSON: { virtuals: true }
  })

  Event.virtual('name').get( ->
    return 'config.room.names[this.floor + this.room]'
  )

  Que = new Schema({
    'floor': Number
    'contact': String
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
  mongoose.model('Que', Que)
  fn()

exports.defineModels = defineModels