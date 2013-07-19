'use strict';

angular.module('gottaGo.controllers', ['ngResource'])
.controller('GGMainCtrl', ($scope, Status, Que, roomNames, $timeout) ->
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

  Status.get().success((response) ->
    isDifferent(response)

    getQue()
  )

  setInterval( ->
    Status.get().success((response) ->
      isDifferent(response)

      getQue()
    )
  , 2000)

  isDifferent = (newData) ->
    if $scope.floorsArray.length is 0
      $scope.floorsArray = newData
      return

    for floor, floorIndex in $scope.floorsArray
      for room, roomIndex in floor
        if room.time isnt newData[floorIndex][roomIndex].time
          $scope.floorsArray = newData
          return


  $scope.addToQue = (floor, contact) ->
    Que.post(floor, {contact:contact}).success((response) ->
      $scope.notify[floor] = 'qued'
      getQue()
    )

)