'use strict'

angular.module('gottaGo.filters', [])
  .filter('interpolate', (version) ->
    return (text) ->
      return String(text).replace(/\%VERSION\%/mg, version)
  )
  .filter('double',  ->
    return (input) ->
      return if input.toString().length < 2 then "0#{input}" else input
  )
  .filter('ms', ->
    return (s) ->
      addZ = (n) ->
        return if n<10 then '0' + n else '' + n

      ms = s % 1000
      s = (s - ms) / 1000
      secs = s % 60
      s = (s - secs) / 60
      mins = s % 60
      hrs = (s - mins) / 60

      return addZ(hrs) + ':' + addZ(mins) + ':' + addZ(secs) #+ '.' + ms
  )
