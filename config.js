// Generated by CoffeeScript 1.6.2
var currentEnv;

currentEnv = process.env.NODE_ENV || 'development';

exports.appName = "GottaGo";

exports.floors = [2];

exports.env = {
  production: false,
  staging: false,
  test: false,
  development: false
};

exports.env[currentEnv] = true;

exports.log = {
  path: __dirname + ("/var/log/app_" + currentEnv + ".log")
};

exports.server = {
  port: 9600,
  ip: '127.0.0.1'
};

if (currentEnv !== 'production' && currentEnv !== 'staging') {
  exports.enableTests = true;
  exports.server.ip = '0.0.0.0';
}

exports.db = {
  URL: "mongodb://localhost:27017/" + (exports.appName.toLowerCase()) + "_" + currentEnv
};
