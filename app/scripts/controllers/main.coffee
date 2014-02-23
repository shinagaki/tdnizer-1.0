'use strict'

ajax = ($scope, $http) ->
  $scope.searching = true
  params = {}
  if $scope.tdnize
    params = tdn: $scope.query
  else
    params = name: $scope.query

  $http.get('/api/tdnizer',
    params: params
  ).success (dics) ->
    $scope.dics = dics
    $scope.searching = false

angular.module('tdnizerApp').controller('MainCtrl', ($scope, $http) ->
  $scope.query = ''
  $scope.tdnize = true
  $scope.dics = []
  queryPrev = ''
  tdnizePrev = func = null

  $scope.search = ->
    if queryPrev isnt $scope.query or tdnizePrev isnt $scope.tdnize
      clearTimeout func
      func = setTimeout ->
        ajax $scope, $http
      , 300
    queryPrev = $scope.query
    tdnizePrev = $scope.tdnizePrev
).filter('encodeURI', ->
  window.encodeURIComponent
).filter 'highlight', ->
  (text, search) ->
    if search or angular.isNumber(search)
      text = text.toString()
      search = search.toString()
      text.replace new RegExp(search, 'gi'), '<em>$&</em>'
    else
      text
