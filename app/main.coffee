class GameTile
  constructor: (@document) ->
  cssClassList: ->
    {state: state} = @document
    "state-#{state}"
  inverseState: ->
    if @document.state is 'on'
      'off'
    else
      'on'
  update: (documentFragment) ->
    GameTileCollection.update @document._id, $set: documentFragment 

@.GameTileCollection = new Meteor.Collection 'GameTile',
  transform: (document) ->
    new GameTile document

@.createTestData = ->
  Meteor.call 'reset'
  for y in [1..10]
    for x in [1..10]
      GameTileCollection.insert {
        state: if Math.round(Math.random()) is 1 then 'on' else 'off'
        x: x
        y: y
      }

@.updateGameMatrix = ->
  for tile in GameTileCollection.find().fetch()
    newState = do ->
      {x: x, y: y} = tile.document
      neighbors = _.compact [
        GameTileCollection.findOne(
          x: x - 1 
          y: y
          state: 'on'
        )
        GameTileCollection.findOne(
          x: x + 1 
          y: y
          state: 'on'
        )
        GameTileCollection.findOne(
          x: x
          y: y - 1
          state: 'on'
        )
        GameTileCollection.findOne(
          x: x
          y: y + 1
          state: 'on'
        )
      ]
      switch neighbors.length
        when 0
          'off'
        when 2
          'on'
        when 3, 4
          'off'
    if tile.document.state isnt newState
      tile.update state: newState
  null

if Meteor.isServer
  Meteor.startup ->
 
    Meteor.methods
      reset: ->
        GameTileCollection.remove {}

    Meteor.publish 'GameTile', (selector) ->
      GameTileCollection.find(selector)    

    GameTileCollection.allow
      insert: ->
        true
      update: ->
        true
      remove: ->
        true

if Meteor.isClient
  Meteor.startup ->
    Meteor.subscribe 'GameTile', {}
    updateGameMatrixInterval = null
    Session.set 'automaton:isRunning', false
    Deps.autorun ->
      if Session.get 'automaton:isRunning'
        updateGameMatrixInterval = setInterval updateGameMatrix, 200
      else
        clearInterval updateGameMatrixInterval

