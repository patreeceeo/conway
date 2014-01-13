class ConwayCell
  constructor: (@document) ->
  cssClassList: ->
    {state: state} = @document
    "state-#{state}"      
  neighbors: (selector = {}) ->
    {x: x, y: y} = @document
    _(Conway.cellCollection).select (doc) ->
      {x: nx, y: ny, state: state} = doc

      isMe = x is nx and y is ny
      dx = Math.abs(x - nx)
      dy = Math.abs(y - ny)
 
      isNeighbor = 
        (dx <= 1 or dx is 20 - 1) and
        (dy <= 1 or dy is 20 - 1) and
        not isMe

      isNeighbor and state is 'on'
  inverseState: ->
    if @document.state is 'on'
      'off'
    else
      'on'
  clone: ->
    new ConwayCell @document
  update: (documentFragment) ->
    Conway.cellCollectionDependency.changed()
    _(@document).extend documentFragment

this.Conway ?= {}

_.defaults Conway,
  geometry:
    width: 20
    height: 20
  cellCollectionDependency: new Deps.Dependency
  cellCollection: []
  cellCollectionPatch: []
  persistentCellCollection: new Meteor.Collection 'ConwayCell',
    transform: (document) ->
      new ConwayCell document
  createFixtureRandom: ->
    @cellCollection = []
    for y in [1..@geometry.height]
      for x in [1..@geometry.width]
        @cellCollection.push
          _id: Random.id()
          state: if Math.round(Math.random()) is 1 then 'on' else 'off'
          x: x
          y: y
    @cellCollectionDependency.changed()
  createFixtureEmpty: ->
    @cellCollection = []
    for y in [1..@geometry.height]
      for x in [1..@geometry.width]
        @cellCollection.push
          _id: Random.id()
          state: 'off'
          x: x
          y: y
    @cellCollectionDependency.changed()
  updateCell: (cell) -> 
    changed: false
  getCell: (id) ->
    new ConwayCell _(@cellCollection).findWhere _id: id
  getCells: ->
    @cellCollectionDependency.depend()
    @cellCollection
  play: ->
    if Meteor.isClient
      Session.set 'playing', true
      Meteor.call 'play'
    else
      throw new Error 'play() should only be called from the client'
  pause: ->
    if Meteor.isClient
      Session.set 'playing', false
      Meteor.call 'pause'
    else
      throw new Error 'pause() should only be called from the client'
  isPlaying: ->
    Session.get('playing')


@addToPatch = (doc, newState) ->
  cellPatch =
    applyTo: doc._id
    state: newState

  Conway.cellCollectionPatch.push cellPatch

@updateCells = (opinions = {}) ->
  for doc in Conway.cellCollection
    cell = new ConwayCell doc
    newState = Conway.getNextCellState?(doc, liveNeighbors: cell.neighbors(state: 'on'))
    if not _.isEqual newState, doc.state
      @addToPatch doc, newState
  @applyPatch()

@applyPatch = ->
  docIndex = 0
  doc = null
  for cellPatch in Conway.cellCollectionPatch
    {applyTo: applyTo, state: newState} = cellPatch
    loop
      doc = Conway.cellCollection[docIndex++]
      break if doc?._id is applyTo
    doc.state = newState
  Conway.cellCollectionDependency.changed()
  Conway.cellCollectionPatch = []


if Meteor.isServer
  Meteor.startup => 
    @isRunning = false
    Meteor.methods
      reset: (selector = {}) ->
        Conway.cellCollection.remove selector
        Conway.cellCollectionPatch.remove selector
      applyPatch: ->
        global.applyPatch()
      pause: =>
        @isRunning = false
      play: =>
        @isRunning = true
        
    Meteor.publish 'ConwayCell', (selector) ->
      Conway.persistentCellCollection.find(selector)    

    always = -> true
    everything = insert: always, update: always, remove: always

    Conway.persistentCellCollection.allow everything

if Meteor.isClient
  Meteor.startup ->
    Meteor.subscribe 'ConwayCell', {}
    updateCellsIntervalID = null
    if Conway.cellCollection.length is 0
      Conway.createFixtureEmpty()
    Conway.pause()
    Deps.autorun ->
      if Conway.isPlaying()
        updateCellsIntervalID = setInterval updateCells, 100
      else
        clearInterval updateCellsIntervalID

 

