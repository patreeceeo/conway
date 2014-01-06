class ConwayCell
  constructor: (@document) ->
  cssClassList: ->
    {state: state} = @document
    "state-#{state}"      
  neighbors: (selector = {}) ->
    {x: x, y: y} = @document
    wrap = (v, min = 1, max = 20) ->
      Math.max(min, Math.min(v, max))
    lx = wrap x - 1
    rx = wrap x + 1
    uy = wrap y - 1
    dy = wrap y + 1

    Conway.cellCollection.find _.extend selector,
      $or: [
        {
          x: $in: [lx, x, rx]
          y: uy
        }
        {
          x: $in: [lx, x, rx]
          y: dy
        }
        {
          x: $in: [lx, rx]
          y: y
        }
      ]
  inverseState: ->
    if @document.state is 'on'
      'off'
    else
      'on'
  clone: ->
    new ConwayCell @document
  update: (documentFragment) ->
    Conway.cellCollection.update @document._id, $set: documentFragment 

this.Conway ?= {}

_.defaults Conway,
  geometry:
    width: 20
    height: 20
  cellCollection: new Meteor.Collection 'ConwayCell',
    transform: (document) ->
      new ConwayCell document
  cellCollectionPatch: new Meteor.Collection 'ConwayCellPatch',
    transform: (document) ->
      new ConwayCell document
  createFixtureRandom: ->
    Meteor.call 'reset', =>
      for y in [1..@geometry.height]
        for x in [1..@geometry.width]
          doc = {
            state: if Math.round(Math.random()) is 1 then 'on' else 'off'
            x: x
            y: y
          }
          Conway.cellCollection.insert doc
  createFixtureEmpty: ->
    Meteor.call 'reset', =>
      for y in [1..@geometry.height]
        for x in [1..@geometry.width]
          doc = {
            state: 'off'
            x: x
            y: y
          }
          Conway.cellCollection.insert doc
  updateCell: (cell) -> 
    cell

@updateCells = (opinions = {}) ->
  for cell in Conway.cellCollection.find().fetch()
    oldState =
    if _.isObject cell.document.state
      _.clone cell.document.state
    else 
      cell.document.state

    cell = Conway.updateCell?(cell)
    cell.document.target_id = cell.document._id
    if not _.isEqual oldState, cell.document.state
      Conway.cellCollectionPatch.insert _(cell.document).omit '_id'
  Meteor.call 'applyPatch', opinions.finished

@applyPatch = ->
  for patch in Conway.cellCollectionPatch.find().fetch()
    {x: x, y: y, state: state} = patch.document
    # Conway.cellCollection.update {x: x, y: y}, $set: state: state
    Conway.cellCollection.update patch.document.target_id, $set: state: state
  Conway.cellCollectionPatch.remove {}


if Meteor.isServer
  Meteor.startup -> 
    Meteor.methods
      reset: (selector = {}) ->
        Conway.cellCollection.remove selector
        Conway.cellCollectionPatch.remove selector
      applyPatch: ->
        global.applyPatch()

    Meteor.publish 'ConwayCell', (selector) ->
      Conway.cellCollection.find(selector)    

    always = -> true
    everything = insert: always, update: always, remove: always
    Conway.cellCollection.allow everything
    Conway.cellCollectionPatch.allow everything

if Meteor.isClient
  Meteor.startup ->
    Meteor.subscribe 'ConwayCell', {}
    updateCellsInterval = null
    Session.set 'automaton:isRunning', false
    Deps.autorun ->
      if Session.get 'automaton:isRunning'
        finished = true 
        fn = ->
          if finished
            finished = false
            updateCells finished: ->
              finished = true
        updateCellsInterval = setInterval fn, 200
      else
        clearInterval updateCellsInterval

 

