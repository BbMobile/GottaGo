services = angular.module('gottaGo.services', ['ngResource'])

GGAppAPIUrl = "/api"

services.factory("Status", ($http) ->
	return $http({method:"GET", url: "/api/status"} )
)
