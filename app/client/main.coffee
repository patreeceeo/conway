
this.Conway ?= {}

_.extend Conway,
  cellCollection: []
  cellCollectionPatch: []
  cellCollectionDependency: new Deps.Dependency
  persistentCellCollection: new Meteor.Collection 'ConwayCell',
    transform: (document) ->
      new Conway.Cell document
  createFixture: (options) ->
    Meteor.call 'createFixture', options
  updateCell: (cell) ->
  getCell: (id) ->
    new Conway.Cell _(@cellCollection).findWhere _id: id
  getCells: ->
    @cellCollectionDependency.depend()
    @cellCollection
  play: ->
    Session.set 'playing', true
    Meteor.call 'play'
  pause: ->
    Session.set 'playing', false
    Meteor.call 'pause'
  isPlaying: ->
    Session.get('playing')
  save: ->
    Meteor.call 'save', @cellCollection

@addToPatch = (doc, newState) ->
  cellPatch =
    applyTo: doc._id
    state: newState

  Conway.cellCollectionPatch.push cellPatch

@updateCells = (opinions = {}) ->
  for doc in Conway.cellCollection
    cell = new Conway.Cell doc
    newState = Conway.getNextCellState? doc,
      liveNeighbors: cell.neighbors(state: alive: true)
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



Meteor.startup ->
  Meteor.subscribe 'ConwayCell', {}
  updateCellsIntervalID = null
  Conway.play()
  Deps.autorun ->
    if Conway.isPlaying()
      updateCellsIntervalID = setInterval updateCells, 100
    else
      clearInterval updateCellsIntervalID

  getIndexFromId = (id) ->
    getXY = (id) ->
      for s in id.split(',')
        parseInt s
    getIndex = (x, y) ->
      y * Conway.geometry.width + x
    getIndex.apply(null, getXY(id))
  Conway.persistentCellCollection.find().observeChanges
    changed: (id, fields) ->
      unless Conway.isPlaying()
        _.extend Conway.cellCollection[getIndexFromId(id)], fields
        Conway.cellCollectionDependency.changed()
    added: (id, fields) ->
      # TODO: does fields include id?
      doc = _.extend {}, fields, _id: id
      Conway.cellCollection[Conway.cellCollection.length] = doc
      Conway.cellCollectionDependency.changed()
    removed: (id, fields) ->
      index = getIndexFromId(id)
      Conway.cellCollection.splice(index, 1)
      Conway.cellCollectionDependency.changed()



 

