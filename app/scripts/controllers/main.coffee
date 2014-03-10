'use strict'

getDics = ($scope, $http) ->
  $scope.searching = true
  $scope.resultNA = false
  params = {}
  if $scope.tdnize
    params = name: $scope.word
  else
    params = tdn: $scope.word
  $http.get('/api/tdnizer',
    params: params
  ).success (dics) ->
    $scope.dics = dics
    if dics.length is 0
      $scope.resultNA = true
    $scope.searching = false

angular.module('tdnizerApp').controller('MainCtrl', ($scope, $http) ->
  $scope.word = ''
  $scope.tdnize = true
  $scope.dics = []
  $scope.resultNA = true
  wordPrev = ''
  tdnizePrev = func = null

  $scope.switchTdnize = ->
    if $scope.tdnize
      angular.element('#input--word').attr('placeholder', '多田野')
    else
      angular.element('#input--word').attr('placeholder', 'tdn')
    $scope.search()

  $scope.search = ->
    if $scope.word is ''
      $scope.resultNA = true
      $scope.dics = []
    else if $scope.word and wordPrev isnt $scope.word or tdnizePrev isnt $scope.tdnize
      clearTimeout func
      func = setTimeout ->
        getDics $scope, $http
      , 300
    wordPrev = $scope.word
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
