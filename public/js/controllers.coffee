'use strict'

angular.module('gottaGo.controllers', ['ngResource'])
.controller('GGMainCtrl', ($rootScope, $scope, socket, Que, roomNames, $timeout) ->
  $scope.floorsArray = []
  $scope.que = []
  $scope.floor = {}
  $scope.notify = {}
  $scope.selectedFloor = 2

  $scope.changeSelectedFloor = ->
    $scope.selectedFloor = if $scope.selectedFloor is 2 then 3 else 2

  $scope.milliseconds = (stamp) ->
    return Date.parse(stamp).getTime()

  $scope.getRoomNames = (floor, room) ->
    return roomNames[floor + room]




  socket.on('init', (data) ->
    $scope.floorsArray = data.floorsArray
    $rootScope.currentFloorArray = $scope.floorsArray[ $scope.floorArrayIndex( $scope.selectedFloor ) ]
    $scope.que = data.queObj
  )

  socket.on('event', (data) ->
    for floor, floorIndex in $scope.floorsArray
      for room, roomIndex in floor
        if room.room is data.room and room.floor is data.floor
          $scope.floorsArray[floorIndex].splice(roomIndex, 1, data)
          $rootScope.currentFloorArray = $scope.floorsArray[ $scope.floorArrayIndex( $scope.selectedFloor ) ]

          return
  )

  $scope.$watch('selectedFloor', (newValue) ->
    $rootScope.currentFloorArray = $scope.floorsArray[ $scope.floorArrayIndex( newValue ) ]
  )

  socket.on('que', (data) ->
    $scope.que[data.floor] = data.count
    if data.count is 0
      $scope.notify[data.floor] = ''
  )

  socket.on('analytics', (data) ->
    $scope.stats = data.stats
  )


  $scope.addToQue = (floor, contact) ->
    Que.post(floor, {contact:contact}).success((response) ->
      $scope.notify[floor] = 'qued'
    )

  $scope.floorArrayIndex = (selectedFloor) ->
    return if selectedFloor is 2 then 0 else 1


)

