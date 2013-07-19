services = angular.module('gottaGo.services', ['ngResource'])

GGAppAPIUrl = "/api"

services.factory("Status", ($http) ->
	return $http({method:"GET", url: "/api/status"} )
)

services.factory("Que", ($http) ->
  return {
    'get' : (floor) -> $http({method:"GET", url: "/api/que/#{floor}"} )
    'post' : (floor, data) -> $http({method:"POST", url: "/api/que/#{floor}", data} )
  }
)
