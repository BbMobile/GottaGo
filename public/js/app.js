// Generated by CoffeeScript 1.6.2
'use strict';angular.module('gottaGo', ['gottaGo.controllers', 'gottaGo.filters', 'gottaGo.services', 'gottaGo.directives', 'ngResource']).config(function($routeProvider, $locationProvider, $httpProvider) {
  $routeProvider.otherwise({
    redirectTo: '/'
  });
  $locationProvider.html5Mode(true);
  return $httpProvider.responseInterceptors.push(function($rootScope, $q) {
    return function(promise) {
      return promise.then(function(response) {
        return response;
      }, function(response) {
        var _ref;

        if (((_ref = response.data) != null ? _ref.message : void 0) != null) {
          $rootScope.error = response.data.message;
        } else {
          $rootScope.error = "Sorry there is a problem, please try again later.";
        }
        return $q.reject(response);
      });
    };
  });
}).value("roomNames", {
  '2a': 'Finckle',
  '2b': 'Einhorn'
});
