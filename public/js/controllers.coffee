'use strict';

angular.module('gottaGo.controllers', ['ngResource'])
.controller('GGMainCtrl', ($scope, Status, Que, roomNames) ->
  $scope.floorsArray = []
  $scope.que = []
  $scope.floor = {}
  $scope.notify = {}

  $scope.milliseconds = (stamp) ->
    debugger;
    return Date.parse(stamp).getTime()

  $scope.getRoomNames = (floor, room) ->
    return roomNames[floor+room]

  getQue = ->
    $scope.que = []

    for floor in $scope.floorsArray
      Que.get(floor[0].floor).success((response) ->
        $scope.que.push(response.length)
      )

  $scope.floorsArray = Status.success((response) ->
    $scope.floorsArray = response

    getQue()

  )


  $scope.addToQue = (floor, contact) ->
    Que.post(floor, {contact:contact}).success((response) ->
      $scope.notify[floor] = 'qued'
      getQue()
    )

)