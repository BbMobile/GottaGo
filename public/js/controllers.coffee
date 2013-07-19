'use strict';

angular.module('gottaGo.controllers', ['ngResource'])
.controller('GGMainCtrl', ($scope, Status, roomNames) ->
  $scope.floorsArray = []
  $scope.milliseconds = (stamp) ->
    debugger;
    return Date.parse(stamp).getTime()

  $scope.getRoomNames = (floor, room) ->
    return roomNames[floor+room]

  Status.success((response) ->
    $scope.floorsArray = response
  )

)