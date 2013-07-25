// Generated by CoffeeScript 1.6.2
var Event, FloorStats, Que, Visits, app, config, eventLogger, express, io, mail, models, mongoStore, mongoose, nodemailer, path, routes, smtpTransport;

express = require('express');

mongoose = require('mongoose');

mongoStore = require('connect-mongodb');

routes = require('./routes');

path = require('path');

models = require('./models');

config = require('./config');

nodemailer = require("nodemailer");

eventLogger = require("./event-logger");

app = express();

Event = null;

FloorStats = null;

Visits = null;

Que = null;

app.configure(function() {
  app.set('port', process.env.PORT || config.server.port);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.bodyParser());
  app.use(express.cookieParser());
  app.use(express.session({
    store: mongoStore(app.set('db-uri')),
    secret: 'topsecret'
  }));
  app.use(express.logger({
    format: '\x1b[1m:method\x1b[0m \x1b[33m:url\x1b[0m :response-time ms'
  }));
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express["static"](path.join(__dirname, 'public')));
  app.use(function(err, req, res, next) {
    console.log(err);
    return res.send(404, "FUCK 4-0-4");
  });
  return app.use(function(req, res) {
    console.log("Page not found 404");
    return res.send(404, "FUCK 4-0-4");
  });
});

app.configure('development', function() {
  app.set('db-uri', config.db.URL);
  app.use(express.errorHandler({
    dumpExceptions: true
  }));
  return app.set('view options', {
    pretty: true
  });
});

app.configure('test', function() {
  app.set('db-uri', config.db.URL);
  return app.set('view options', {
    pretty: true
  });
});

app.configure('production', function() {
  return app.set('db-uri', config.db.URL);
});

models.defineModels(mongoose, function() {
  var db;

  app.Event = Event = mongoose.model('Event');
  app.FloorStats = FloorStats = mongoose.model('FloorStats');
  app.Visits = Visits = mongoose.model('Visits');
  app.Que = Que = mongoose.model('Que');
  return db = mongoose.connect(app.set('db-uri'));
});

io = require('socket.io').listen(app.listen(app.get('port'), function() {
  return console.log("Express server listening on port " + app.get('port'));
}));

app.get('/', routes.index);

app.get('/partials/:name', routes.partials);

app.post('/api/event', function(req, res) {
  var event, mailOptions, mailto, params;

  params = req.body;
  mailOptions = {
    from: "So You Gotta Go <soYouGottaGo@gottaGo.medu.com>",
    bcc: "",
    subject: "A Bathroom on the " + params.floor + "nd floor is available!!",
    text: "A Bathroom on the " + params.floor + "nd is available!! "
  };
  mailto = [];
  event = new Event({
    'floor': params.floor,
    'room': params.room,
    'status': params.status
  });
  io.sockets.emit('event', event);
  if (parseInt(event.status) === 0) {
    Que.find({
      'floor': event.floor
    }, {}, {
      sort: {
        'time': -1
      }
    }).exec(function(err, que) {
      var person, _i, _len;

      if (err != null) {
        return false;
      }
      for (_i = 0, _len = que.length; _i < _len; _i++) {
        person = que[_i];
        mailto.push("<" + person.contact + ">");
      }
      mailOptions.bcc = mailto.join(",");
      mailOptions.text = "A Bathroom on the " + event.floor + "nd is available!! \n ";
      if (mailto.length > 1) {
        mailOptions.text += "This message was sent to " + mailto.length + " humans. SO HURRY!";
      }
      mail(mailOptions, function(err) {});
      Que.find().remove();
      return io.sockets.emit('que', {
        floor: event.floor,
        count: 0
      });
    });
  }
  return eventLogger.logEvent(event, req, res, Event, FloorStats, Visits);
});

smtpTransport = nodemailer.createTransport("SMTP", {
  service: "medu",
  host: "mail1.medu.com"
});

mail = function(mailOptions, callback) {
  return smtpTransport.sendMail(mailOptions, function(error, response) {
    if (error) {
      console.log(error);
      callback(error);
    } else {
      console.log("Message sent: " + response.message);
      callback();
    }
    return smtpTransport.close();
  });
};

app.post('/api/que/:floor', function(req, res) {
  var floor, params, que;

  params = req.body;
  floor = req.params.floor;
  que = new Que({
    'floor': floor,
    'status': 1,
    'contact': params.contact
  });
  return que.validate(function(validationErr) {
    return que.save(function(err) {
      if (err != null) {
        res.statusCode = 400;
        return res.send({
          message: "Invalid Email"
        });
      } else {
        Que.count({
          floor: floor
        }, function(err, count) {
          if (count == null) {
            count = 0;
          }
          return io.sockets.emit('que', {
            floor: floor,
            count: count
          });
        });
        res.statusCode = 200;
        return res.send("OK");
      }
    });
  });
});

app.get('(!public)*', routes.index);

io.sockets.on('connection', function(socket) {
  var floor, floorArray, index, queObj, statusArray, _i, _len, _ref, _results;

  statusArray = [];
  queObj = {};
  _ref = config.floors;
  _results = [];
  for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
    floor = _ref[index];
    floorArray = [];
    _results.push(Event.findOne({
      'floor': floor,
      'room': 'a'
    }, {}, {
      sort: {
        'time': -1
      }
    }).exec(function(err, eventA) {
      if (err != null) {
        res.statusCode = 400;
        return res.send("Error");
      }
      floorArray.push(eventA);
      return Event.findOne({
        'floor': floor,
        'room': 'b'
      }, {}, {
        sort: {
          'time': -1
        }
      }).exec(function(err, eventB) {
        if (err != null) {
          res.statusCode = 400;
          return res.send("Error");
        }
        floorArray.push(eventB);
        statusArray.push(floorArray);
        return Que.count({
          floor: floor
        }, function(err, count) {
          if (count == null) {
            count = 0;
          }
          queObj[floor] = count;
          console.log(floor, count, queObj);
          if (index === config.floors.length) {
            return FloorStats.aggregate({
              "$group": {
                _id: "$floor",
                requests: {
                  $sum: 1
                },
                averagedur: {
                  $avg: "$duration"
                }
              }
            }, function(err, res) {
              var today;

              if (err) {
                return handleError(err);
              }
              today = new Date().getDate();
              return Visits.aggregate({
                $match: {
                  day: {
                    $gt: today - 1
                  }
                }
              }, {
                "$group": {
                  _id: "$room",
                  requests: {
                    $sum: 1
                  }
                }
              }, {
                $sort: {
                  _id: 1
                }
              }, function(err, res2) {
                return Visits.aggregate({
                  "$group": {
                    _id: "$hour",
                    requests: {
                      $sum: 1
                    }
                  }
                }, {
                  $sort: {
                    requests: -1
                  }
                }, function(err, res3) {
                  var hour, reqPerHourObj, _j, _len1, _ref1, _ref2, _ref3, _ref4;

                  reqPerHourObj = {};
                  for (_j = 0, _len1 = res3.length; _j < _len1; _j++) {
                    hour = res3[_j];
                    reqPerHourObj[hour._id] = hour.requests;
                  }
                  reqPerHourObj.top = (_ref1 = res3[0]) != null ? _ref1.requests : void 0;
                  return io.sockets.emit('init', {
                    floorsArray: statusArray,
                    queObj: queObj,
                    stats: {
                      reqPerHour: reqPerHourObj,
                      averageDur: (_ref2 = res[0]) != null ? _ref2.averagedur : void 0,
                      a: {
                        todayVisits: (_ref3 = res2[0]) != null ? _ref3.requests : void 0
                      },
                      b: {
                        todayVisits: (_ref4 = res2[1]) != null ? _ref4.requests : void 0
                      }
                    }
                  });
                });
              });
            });
          }
        });
      });
    }));
  }
  return _results;
});
