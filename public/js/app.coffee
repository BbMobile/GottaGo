'use strict';

# Declare app level module which depends on filters, and services

angular.module('gottaGo', [
  'gottaGo.controllers',
  'gottaGo.filters',
  'gottaGo.services',
  'gottaGo.directives',
  'ngResource'
])
.config( ($routeProvider, $locationProvider, $httpProvider) ->
  $routeProvider.
    otherwise({
      redirectTo: '/'
    });

  $locationProvider.html5Mode(true);

  #configure $http to show a login dialog whenever a 401 unauthorized response arrives
  $httpProvider.responseInterceptors.push( ($rootScope, $q) ->
    return (promise) ->
      return promise.then( (response) ->
            return response
          ,
          #error -> if 401 save the request and broadcast an event
          (response) ->
            if response.data?.message?
              $rootScope.error = response.message
            else
              $rootScope.error = "Sorry there is a problem, please try again later."

            return $q.reject(response)
          )
  )
)
.run( ( $rootScope ) ->
  $rootScope.getFavicon = ->
    if $rootScope.currentFloorArray?
      return "_#{$rootScope.currentFloorArray[0].status}_#{$rootScope.currentFloorArray[1].status}"
    else
      return ""
)
.value("roomNames", {
  '2a':'Finkle'
  '2b':'Einhorn'
  '3a':'Harry'
  '3b':'Llyod'
})