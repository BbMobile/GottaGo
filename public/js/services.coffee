services = angular.module('gottaGo.services', ['ngResource'])

GGAppAPIUrl = "/api"

services.factory("Status", ($http) ->
	return {
    'get' : -> $http({method:"GET", url: "/api/status"} )
  }
)

services.factory("Que", ($http) ->
  return {
    'get' : (floor) -> $http({method:"GET", url: "/api/que/#{floor}"} )
    'post' : (floor, data) -> $http({method:"POST", url: "/api/que/#{floor}", data} )
  }
)


# Demonstrate how to register services
# In this case it is a simple value service.
services.factory('socket', ($rootScope) ->
  #socket = window.io.connect('http://localhost:8080');
  socket = window.io.connect('http://gottago.medu.com:8080');
  return {
    on: (eventName, callback) ->
      socket.on(eventName, ->
        args = arguments
        $rootScope.$apply( ->
          callback.apply(socket, args)
        )
      )
    ,
    emit: (eventName, data, callback) ->
      socket.emit(eventName, data, ->
        args = arguments
        $rootScope.$apply( ->
          if callback
            callback.apply(socket, args)

        )
      )

  }
)