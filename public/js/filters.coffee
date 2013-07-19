'use strict';

angular.module('gottaGo.filters', [])
  .filter('interpolate', (version) ->
    return (text) ->
      return String(text).replace(/\%VERSION\%/mg, version);
  )
  .filter('double',  ->
    return (input) ->
      return if input.toString().length < 2 then "0#{input}" else input
  )
