class GameTile
  constructor: (@document) ->
  cssClassList: ->
    {state: state} = @document
    "state-#{state}"      
  neighbors: (selector = {}) ->
    {x: x, y: y} = @document
    GameTileCollection.find _.extend selector,
      $or: [
        {
          x: $in: [x - 1, x, x + 1]
          y: y - 1
        }
        {
          x: $in: [x - 1, x, x + 1]
          y: y + 1
        }
        {
          x: $in: [x - 1, x + 1]
          y: y
        }
      ]
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
@.ScratchGameTileCollection = new Meteor.Collection 'ScratchGameTile',
  transform: (document) ->
    new GameTile document

@.createTestData = ->
  Meteor.call 'reset', ->
    for y in [1..10]
      for x in [1..10]
        doc = {
          state: if Math.round(Math.random()) is 1 then 'on' else 'off'
          x: x
          y: y
        }
        GameTileCollection.insert doc
        ScratchGameTileCollection.insert doc

@.updateGameMatrix = ->
  for tile in GameTileCollection.find().fetch()
    {x: x, y: y, state: state} = tile.document
    newState = do ->
      neighbors = tile.neighbors(state: 'on').fetch()
      switch neighbors.length
        when 0, 1
          'off'
        when 2
          state
        when 3
          'on'
        else
          'off'
    Meteor.call 'updateScratch', {x: x, y: y}, $set: state: newState
  Meteor.call 'updateMatrixFromScratch'
  

if Meteor.isServer
  Meteor.startup ->
 
    Meteor.methods
      reset: (selector = {}) ->
        GameTileCollection.remove selector
      updateMatrixFromScratch: ->
        ScratchGameTileCollection.find().forEach (tile) ->
          {x: x, y: y, state: state} = tile.document
          GameTileCollection.update {x: x, y: y}, $set: state: state
      updateScratch: (selector, modifier) ->
        ScratchGameTileCollection.update selector, modifier


    Meteor.publish 'GameTile', (selector) ->
      GameTileCollection.find(selector)    

    GameTileCollection.allow
      insert: ->
        true
      update: ->
        true
      remove: ->
        true
    ScratchGameTileCollection.allow
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

