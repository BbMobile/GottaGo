crypto = require('crypto')

defineModels = (mongoose, fn) ->
  Schema = mongoose.Schema
  ObjectId = Schema.ObjectId


  # Model: Event

  Event = new Schema({
    'floor': Number
    'room': String
    'time': { type: Date, default: Date.now }
    'status': String
  });

  # Document.virtual('id')
  #   .get(function() {
  #     return this._id.toHexString();
  #   });

  # Document.pre('save', function(next) {
  #   this.keywords = extractKeywords(this.data);
  #   next();
  # });




  mongoose.model('Event', Event);
  fn();

exports.defineModels = defineModels